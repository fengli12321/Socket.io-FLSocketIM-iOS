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
    [self saveMessageAndConversationToDBWithMessage:message];
    
    [self sendMessage:message statusChange:^{
        
        sendStatus(message);
    }];
    return message;
}

- (FLMessageModel *)sendImgMessage:(NSData *)imgData toUser:(NSString *)toUser sendStatus:(void (^)(FLMessageModel *message))sendStatus {
    
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [NSString creatUUIDString]];
    FLMessageBody *messageBody = [[FLMessageBody alloc] init];
    messageBody.type = @"img";
    messageBody.imgData = imgData;
    
    // 保存图片到本地沙河
    NSString *savePath = [[self getFielSavePath] stringByAppendingPathComponent:imageName];
    if ([self saveFile:imgData toPath:savePath]) {
        messageBody.locSavePath = savePath;
    }
    
    FLMessageModel *message = [[FLMessageModel alloc] initWithToUser:toUser fromUser:[FLClientManager shareManager].currentUserID chatType:@"chat" messageBody:messageBody];
    
    
    // 保存消息和会话到数据库
    [self saveMessageAndConversationToDBWithMessage:message];
    
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"auth_token"] = [FLClientManager shareManager].auth_token;
    dict[@"imageFileName"] = imageName;
    __weak typeof(self) weakSelf = self;
    [self uploadImageToSeverWithImageData:imgData successBlock:^(id response) {
        
        if ([response[@"code"] integerValue] > 0) {
            
            messageBody.imgUrl = response[@"data"];
            [weakSelf sendMessage:message statusChange:^{
                
                sendStatus(message);
            }];
        }
    } failurBlock:^(NSError *error) {
        
        // 上传失败
        message.sendStatus = FLMessageSendFail;
        sendStatus(message);
    } progress:nil];
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
    
    [self sendMessage:messsage statusChange:^{
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
    NSString *locImgPath = message.bodies.locSavePath;
    if (locImgPath.length) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        imageData = [fileManager contentsAtPath:locImgPath];
    }
    if (!imageData) {
        [FLAlertView showWithTitle:@"图片重发失败！" message:@"本地图片已不存在" cancelButtonTitle:@"确定" otherButtonTitles:nil andAction:nil andParentView:nil];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self uploadImageToSeverWithImageData:imageData successBlock:^(id response) {
        
        if ([response[@"code"] integerValue] > 0) {
            
            message.bodies.imgUrl = response[@"data"];
            [weakSelf sendMessage:message statusChange:^{
                
                sendStatus(message);
            }];
        }
    } failurBlock:^(NSError *error) {
        
        // 上传失败
        message.sendStatus = FLMessageSendFail;
        sendStatus(message);
    } progress:nil];
}

/**
 上传图片到服务器

 @param imageData 图片
 @param successBlock 成功
 @param failureBlock 失败
 @param progress 进度
 */
- (void)uploadImageToSeverWithImageData:(NSData *)imageData successBlock:(void(^)(id response))successBlock failurBlock:(void(^)(NSError *error))failureBlock progress:(void(^)(int64_t bytesProgress, int64_t totalBytesProgress))progress {
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"auth_token"] = [FLClientManager shareManager].auth_token;
    dict[@"imageFileName"] = [NSString stringWithFormat:@"%@.jpg", [NSString creatUUIDString]];
    [FLNetWorkManager ba_uploadImageWithUrlString:SendImgMsg_Url parameters:dict imageData:imageData withSuccessBlock:^(id response) {
        
        successBlock(response);
    } withFailurBlock:^(NSError *error) {
        
        failureBlock(error);
    } withUpLoadProgress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
        progress(bytesProgress, totalBytesProgress);
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

/** 获取文件保存路径 */
- (NSString *)getFielSavePath{
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    path = [path stringByAppendingPathComponent:@"FLFileSavePath"];
    BOOL isDir = false;
    BOOL isExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if (!(isDir && isExist)) {
        
        BOOL bCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (bCreateDir) {
            
            FLLog(@"文件路径创建成功");
        }
    }
    return path;
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
 @param statusChange 发送状态回调
 */
- (void)sendMessage:(FLMessageModel *)message statusChange:(void (^)())statusChange{
    
    id parameters = [message yy_modelToJSONObject];
    [[[FLSocketManager shareManager].client emitWithAck:@"chat" with:@[parameters]] timingOutAfter:5 callback:^(NSArray * _Nonnull data) {
        
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
