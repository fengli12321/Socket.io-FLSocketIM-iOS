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
            [self addHandles];
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
- (void)addDelegate:(id<FLChatManagerDelegate>)delegate {
    
    BOOL isExist = NO;
    for (FLBridgeDelegateModel *model in self.delegateArray) {
        
        if ([delegate isEqual:model.delegate]) {
            isExist = YES;
            break;
        }
    }
    if (!isExist) {
        FLBridgeDelegateModel *model = [[FLBridgeDelegateModel alloc] initWithDelegate:delegate];
        [self.delegateArray addObject:model];
    }
    
}

- (void)removeDelegate:(id<FLChatManagerDelegate>)delegate {
    
    NSArray *copyArray = [self.delegateArray copy];
    for (FLBridgeDelegateModel *model in copyArray) {
        if ([model.delegate isEqual:delegate]) {
            [self.delegateArray removeObject:model];
        }
        else if (!model.delegate) {
            [self.delegateArray removeObject:model];
        }
    }
}


- (FLMessageModel *)sendTextMessage:(NSString *)text toUser:(NSString *)toUser{
    
    FLMessageBody *messageBody = [[FLMessageBody alloc] init];
    messageBody.type = @"txt";
    messageBody.msg = text;
    FLMessageModel *message = [[FLMessageModel alloc] initWithToUser:toUser fromUser:[FLClientManager shareManager].currentUserID chatType:@"chat" messageBody:messageBody];
    [self sendMessage:message];
    return message;
}

- (FLMessageModel *)sendImgMessage:(NSData *)imgData toUser:(NSString *)toUser {
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
            [weakSelf sendMessage:message];
        }
    } withFailurBlock:^(NSError *error) {
        
        
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
- (void)sendMessage:(FLMessageModel *)message {
    
    id parameters = [message yy_modelToJSONObject];
    [[FLSocketManager shareManager].client emit:@"chat" with:@[parameters]];
}

- (void)addHandles {
    
    SocketIOClient *socket = [FLSocketManager shareManager].client;
    
    // 收到消息
    [socket on:@"chat" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
        for (FLBridgeDelegateModel  *model in self.delegateArray) {
            
            id<FLChatManagerDelegate>delegate = model.delegate;
            if (delegate && [delegate respondsToSelector:@selector(chatManager:didReceivedMessage:)]) {
                FLMessageModel *message = [FLMessageModel yy_modelWithJSON:data.firstObject];
                if (message) {
                    [delegate chatManager:self didReceivedMessage:message];
                }
                
            }
        }
    }];
    
    // 用户上线
    [socket on:@"onLine" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
        for (FLBridgeDelegateModel  *model in self.delegateArray) {
            
            id<FLChatManagerDelegate>delegate = model.delegate;
            if (delegate && [delegate respondsToSelector:@selector(chatManager:userOnline:)]) {
                
                [delegate chatManager:self userOnline:[data.firstObject valueForKey:@"user"]];
            }
        }
    }];
    
    [socket on:@"offLine" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
        for (FLBridgeDelegateModel  *model in self.delegateArray) {
            
            id<FLChatManagerDelegate>delegate = model.delegate;
            if (delegate && [delegate respondsToSelector:@selector(chatManager:userOffline:)]) {
                
                [delegate chatManager:self userOffline:[data.firstObject valueForKey:@"user"]];
            }
        }
    }];
}

@end
