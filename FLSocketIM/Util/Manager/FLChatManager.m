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
    
    [self sendMessage:message fileData:nil isResend:NO statusChange:^{
        
        sendStatus(message);
    }];
    return message;
}
- (FLMessageModel *)sendLocationMessage:(CLLocationCoordinate2D)location locationName:(NSString *)locationName detailLocationName:(NSString *)detailLocationName toUser:(NSString *)toUser sendStatus:(void (^)(FLMessageModel *))sendStatus {
    
    FLMessageBody *messageBody = [[FLMessageBody alloc] init];
    messageBody.type = @"loc";
    messageBody.latitude = location.latitude;
    messageBody.longitude = location.longitude;
    messageBody.locationName = locationName;
    messageBody.detailLocationName = detailLocationName;
    FLMessageModel *message = [[FLMessageModel alloc] initWithToUser:toUser fromUser:[FLClientManager shareManager].currentUserID chatType:@"chat" messageBody:messageBody];

    [self sendMessage:message fileData:nil isResend:NO statusChange:^{
        
        sendStatus(message);
    }];
    return message;
}
- (FLMessageModel *)sendImgMessage:(NSData *)imgData toUser:(NSString *)toUser sendStatus:(void (^)(FLMessageModel *message))sendStatus {
    
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [NSString creatUUIDString]];
    FLMessageBody *messageBody = [[FLMessageBody alloc] init];
    messageBody.type = @"img";
    messageBody.fileName = imageName;
    // 保存图片到本地沙河
    NSString *savePath = [[NSString getFielSavePath] stringByAppendingPathComponent:imageName];
    [self saveFile:imgData toPath:savePath];
    
    FLMessageModel *message = [[FLMessageModel alloc] initWithToUser:toUser fromUser:[FLClientManager shareManager].currentUserID chatType:@"chat" messageBody:messageBody];
    
    [self sendMessage:message fileData:imgData isResend:NO statusChange:^{
        
        sendStatus(message);
    }];
    

    return message;
}

- (FLMessageModel *)sendAudioMessage:(NSString *)audioDataPath duration:(CGFloat)duration toUser:(NSString *)toUser sendStatus:(void (^)(FLMessageModel *))sendStatus {
    
    NSString *audioName = [audioDataPath lastPathComponent];
    FLMessageBody *messageBody = [[FLMessageBody alloc] init];
    messageBody.type = @"audio";
    messageBody.fileName = audioName;
    messageBody.duration = duration * 2;
    FLMessageModel *message = [[FLMessageModel alloc] initWithToUser:toUser fromUser:[FLClientManager shareManager].currentUserID chatType:@"chat" messageBody:messageBody];
    NSData *audioData = [NSData dataWithContentsOfFile:audioDataPath];
    
    
    
    [self sendMessage:message fileData:audioData isResend:NO statusChange:^{
        
        sendStatus(message);
    }];
    
    
    
    
    return message;

}

- (void)resendMessage:(FLMessageModel *)message sendStatus:(void (^)(FLMessageModel *))sendStatus {
    switch (message.type) {
        case FLMessageText:{
            [self resendTextMessage:message sendStatus:sendStatus];
            break;
        }
            
        case FLMessageImage:{
            [self resendImgMessage:message sendStatus:sendStatus];
            break;
        }
        
        case FLMessageLoc: {
            [self resendLocMessage:message sendStatus:sendStatus];
            break;
        }
            
        case FlMessageAudio: {
            [self resendAudioMessage:message sendStatus:sendStatus];
            break;
        }
        case FLMessageOther:{
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - Private

/**
 重发文本消息

 @param messsage 消息模型
 @param sendStatus 发送状态回调
 */
- (void)resendTextMessage:(FLMessageModel *)messsage sendStatus:(void (^)(FLMessageModel *))sendStatus {
    
    [self sendMessage:messsage fileData:nil isResend:YES statusChange:^{
        sendStatus(messsage);
    }];
}

/**
 重发图片消息

 @param message 消息模型
 @param sendStatus 发送状态回调
 */
- (void)resendImgMessage:(FLMessageModel *)message sendStatus:(void (^)(FLMessageModel *))sendStatus {
    
    
    NSData *imageData;
    NSString *locImgPath = [[NSString getFielSavePath] stringByAppendingPathComponent:message.bodies.fileName];
    if (locImgPath.length) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        imageData = [fileManager contentsAtPath:locImgPath];
    }
    if (!imageData) {
        [FLAlertView showWithTitle:@"图片重发失败！" message:@"本地图片已不存在" cancelButtonTitle:@"确定" otherButtonTitles:nil andAction:nil andParentView:nil];
        return;
    }
    [self sendMessage:message fileData:imageData isResend:YES statusChange:^{
        
        sendStatus(message);
    }];
   
}
/**
 重发定位消息
 
 @param message 消息模型
 @param sendStatus 发送状态回调
 */
- (void)resendLocMessage:(FLMessageModel *)message sendStatus:(void (^)(FLMessageModel *))sendStatus {
    
    [self sendMessage:message fileData:nil isResend:YES statusChange:^{
        sendStatus(message);
    }];
}


/**
 重发语音消息
 
 @param message 消息模型
 @param sendStatus 发送状态回调
 */
- (void)resendAudioMessage:(FLMessageModel *)message sendStatus:(void (^)(FLMessageModel *))sendStatus {
    
    NSData *audioData;
    NSString *locPath = [[NSString getAudioSavePath] stringByAppendingPathComponent:message.bodies.fileName];
    if (locPath.length) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        audioData = [fileManager contentsAtPath:locPath];
    }
    if (!audioData) {
        [FLAlertView showWithTitle:@"图片重发失败！" message:@"语音文件已不存在" cancelButtonTitle:@"确定" otherButtonTitles:nil andAction:nil andParentView:nil];
        return;
    }
    [self sendMessage:message fileData:audioData isResend:YES statusChange:^{
        
        sendStatus(message);
    }];
}



- (BOOL)saveFile:(NSData *)fileData toPath:(NSString *)savePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL saveSuccess = [fileManager createFileAtPath:savePath contents:fileData attributes:nil];
    if (saveSuccess) {
        FLLog(@"文件保存成功");
    }
    return saveSuccess;
}



/**
 保存消息和会话

 @param message 消息模型
 */
- (void)saveMessageAndConversationToDBWithMessage:(FLMessageModel *)message {
    
    message.sendtime = [[NSDate date] timeStamp];
    message.timestamp = [[NSDate date] timeStamp];
    if (![message.from isEqualToString:message.to]) {    // 发送给自己的消息不插入数据库，等到接收到自己的消息后再插入数据库
        // 消息插入数据库
        [[FLChatDBManager shareManager] addMessage:message];
    }
    
    
    // 数据库添加或者刷新会话
    [[FLChatDBManager shareManager] addOrUpdateConversationWithMessage:message isChatting:YES];
}


/**
 发送消息

 @param message 消息模型
 @param fileData 文件数据
 @param statusChange 发送状态回调
 */
- (void)sendMessage:(FLMessageModel *)message fileData:(NSData *)fileData isResend:(BOOL)isResend statusChange:(void (^)())statusChange{
    
    if (!isResend) { // 重发的消息不要保存
        // 保存消息和会话到数据库
        [self saveMessageAndConversationToDBWithMessage:message];
    }
    
    NSMutableDictionary *parameters;
    if (fileData && fileData.length) {
        NSDictionary *tempPara = [message yy_modelToJSONObject];
        NSDictionary *tempBody = tempPara[@"bodies"];
        parameters = [tempPara mutableCopy];
        NSMutableDictionary *body = [tempBody mutableCopy];
        body[@"fileData"] = fileData;
        parameters[@"bodies"] = body;
    }
    else {
        parameters = [message yy_modelToJSONObject];
    }
    [[[FLSocketManager shareManager].client emitWithAck:@"chat" with:@[parameters]] timingOutAfter:10 callback:^(NSArray * _Nonnull data) {
        
        FLLog(@"%@", data.firstObject);
        
        if ([data.firstObject isKindOfClass:[NSString class]] && [data.firstObject isEqualToString:@"NO ACK"]) {  // 服务器没有应答
            
            
            message.sendStatus = FLMessageSendFail;
            // 发送失败
            statusChange();
            
        }
        else {  // 服务器应答
            
            message.sendStatus = FLMessageSendSuccess;
            NSDictionary *ackDic = data.firstObject;
            message.timestamp = [ackDic[@"timestamp"] longLongValue];
            message.msg_id = ackDic[@"msg_id"];
            if (fileData) {
                NSDictionary *bodies = ackDic[@"bodies"];
                message.bodies.fileRemotePath = bodies[@"fileRemotePath"];
            }
            if (message.type == FLMessageLoc) {
                NSDictionary *bodiesDic = ackDic[@"bodies"];
                message.bodies.fileRemotePath = bodiesDic[@"fileRemotePath"];
            }
            
            // 发送成功
            statusChange();
            
        }
        // 更新消息
        [[FLChatDBManager shareManager] updateMessage:message];
        
        // 数据库添加或者刷新会话
        [[FLChatDBManager shareManager] addOrUpdateConversationWithMessage:message isChatting:YES];
    }];
    
    
}



@end
