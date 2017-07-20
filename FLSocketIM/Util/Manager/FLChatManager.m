//
//  FLChatManager.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/10.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLChatManager.h"
#import "FLSocketManager.h"
#import "FLMessageModel.h"
#import "FLBridgeDelegateModel.h"
@import SocketIO;

static FLChatManager *instance = nil;

@interface FLChatManager ()

// 所有的代理
@property (nonatomic, strong) NSMutableArray *delegateArray;

@end
@implementation FLChatManager

#pragma mark - Lazy
- (NSMutableArray *)delegateArray {
    if (!_delegateArray) {
        _delegateArray = [NSMutableArray array];
    }
    return _delegateArray;
}

#pragma mark - init
+ (instancetype)shareManager {
    
    return [[self alloc] init];
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super init];
        
        if (instance) {
            
        }
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

#pragma mark - Public
- (FLMessageModel *)sendTextMessage:(NSString *)text toUser:(NSString *)toUser sendStatus:(void (^)(FLMessageModel *message))sendStatus{
    
    FLMessageBody *messageBody = [[FLMessageBody alloc] init];
    messageBody.type = @"txt";
    messageBody.msg = text;
    FLMessageModel *message = [[FLMessageModel alloc] initWithToUser:toUser fromUser:[FLClientManager shareManager].currentUserID chatType:@"chat" messageBody:messageBody];
    [self sendMessage:message statusChange:^{
        
        sendStatus(message);
    }];
    return message;
}

- (FLMessageModel *)sendImgMessage:(NSData *)imgData toUser:(NSString *)toUser sendStatus:(void (^)(FLMessageModel *message))sendStatus {
    FLMessageBody *messageBody = [[FLMessageBody alloc] init];
    messageBody.type = @"img";
    messageBody.imgData = imgData;
    FLMessageModel *message = [[FLMessageModel alloc] initWithToUser:toUser fromUser:[FLClientManager shareManager].currentUserID chatType:@"chat" messageBody:messageBody];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"auth_token"] = [FLClientManager shareManager].auth_token;
    dict[@"imageFileName"] = [NSString stringWithFormat:@"%@.jpg", [self timeSp]];
    __weak typeof(self) weakSelf = self;
    [FLNetWorkManager ba_uploadImageWithUrlString:SendImgMsg_Url parameters:dict imageData:imgData withSuccessBlock:^(id response) {
        
        if ([response[@"code"] integerValue] > 0) {
            
            messageBody.imgUrl = response[@"data"];
            [weakSelf sendMessage:message statusChange:^{
                
                sendStatus(message);
            }];
        }
    } withFailurBlock:^(NSError *error) {
        
        // 上传失败
        message.sendStatus = FLMessageSendFail;
        sendStatus(message);
    } withUpLoadProgress:nil];
    return message;
}

#pragma mark - Private
// 生成时间戳
- (NSString *)timeSp
{
    NSDate *datenow = [NSDate date];
    NSTimeZone *zone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    NSInteger interval = [zone secondsFromGMTForDate:datenow];
    NSDate *localeDate = [datenow  dateByAddingTimeInterval: interval];
    NSString *timeSp = [NSString stringWithFormat:@"%f", [localeDate timeIntervalSince1970]];
    return timeSp;
}
- (void)sendMessage:(FLMessageModel *)message statusChange:(void (^)())statusChange{
    
    id parameters = [message yy_modelToJSONObject];
//    [[FLSocketManager shareManager].client emit:@"chat" with:@[parameters]];
    
    [[[FLSocketManager shareManager].client emitWithAck:@"chat" with:@[parameters]] timingOutAfter:5 callback:^(NSArray * _Nonnull data) {
        
        FLLog(@"%@", data.firstObject);
        
        if ([data.firstObject isKindOfClass:[NSString class]] && [data.firstObject isEqualToString:@"NO ACK"]) {  // 服务器没有应答
            
            
            message.sendStatus = FLMessageSendFail;
            message.timestamp = [[NSDate date] timeStamp];
            // 发送失败
            statusChange();
            
            if (![message.from isEqualToString:message.to]) {    // 发送给自己的消息不插入数据库，等到接收到自己的消息后再插入数据库
                // 消息插入数据库
                [[FLChatDBManager shareManager] addMessage:message];
            }
        }
        else {  // 服务器应答
            
            message.sendStatus = FLMessageSendSuccess;
            NSDictionary *ackDic = data.firstObject;
            message.timestamp = [ackDic[@"timestamp"] longLongValue];
            message.msg_id = ackDic[@"msg_id"];
            // 发送成功
            statusChange();
            if (![message.from isEqualToString:message.to]) {    // 发送给自己的消息不插入数据库，等到接收到自己的消息后再插入数据库
                // 消息插入数据库
                [[FLChatDBManager shareManager] addMessage:message];
            }
        }
    }];
    
    
}



@end
