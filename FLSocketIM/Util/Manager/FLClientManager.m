//
//  FLClientManager.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/10.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLClientManager.h"
#import "FLBridgeDelegateModel.h"
#import "FLChatViewController.h"
#import "FLMessageModel.h"
#import "FLVideoChatViewController.h"
static FLClientManager *instance;

@interface FLClientManager ()

@property (nonatomic, strong) NSMutableArray *delegateArray;

@end
@implementation FLClientManager

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

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
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


#pragma mark - Public
- (void)addDelegate:(id<FLClientManagerDelegate>)delegate {
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

- (void)removeDelegate:(id<FLClientManagerDelegate>)delegate {
    
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


#pragma mark - Private
- (void)addHandles {
    
    SocketIOClient *socket = [FLSocketManager shareManager].client;
     
    // 收到消息
    [socket on:@"chat" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        

        if (ack.expected == YES) {
            
            [ack with:@[@"hello 我是应答"]];
        }

        
        FLMessageModel *message = [FLMessageModel yy_modelWithJSON:data.firstObject];
        
        NSData *fileData = message.bodies.fileData;
        if (fileData && fileData != NULL && fileData.length) {
            
            NSString *fileName = message.bodies.fileName;
            NSString *savePath = nil;
            switch (message.type) {
                case FLMessageImage:
                    savePath = [[NSString getFielSavePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"s_%@", fileName]];
                    break;
                case FlMessageAudio:
                    savePath = [[NSString getAudioSavePath] stringByAppendingPathComponent:fileName];
                    break;
                default:
                    savePath = [[NSString getFielSavePath] stringByAppendingPathComponent:fileName];
                    break;
            }
            
            
            message.bodies.fileData = nil;
            [fileData saveToLocalPath:savePath];
        }
        
        
        id bodyStr = data.firstObject[@"bodies"];
        if ([bodyStr isKindOfClass:[NSString class]]) {
            FLMessageBody *body = [FLMessageBody yy_modelWithJSON:[bodyStr stringToJsonDictionary]];
            message.bodies = body;
        }
        
        // 消息插入数据库
        [[FLChatDBManager shareManager] addMessage:message];
        
        // 会话插入数据库或者更新会话
        BOOL isChatting = [message.from isEqualToString:[FLClientManager shareManager].chattingConversation.toUser];
        [[FLChatDBManager shareManager] addOrUpdateConversationWithMessage:message isChatting:isChatting];
        
        
        // 本地推送，收到消息添加红点，声音及震动提示
        [FLLocalNotification pushLocalNotificationWithMessage:message];
        
        
        
        // 代理处理
        for (FLBridgeDelegateModel  *model in self.delegateArray) {
            
            id<FLClientManagerDelegate>delegate = model.delegate;
            if (delegate && [delegate respondsToSelector:@selector(clientManager:didReceivedMessage:)]) {
                
                if (message) {
                    [delegate clientManager:self didReceivedMessage:message];
                }
                
            }
        }
    }];
    
    // 视频通话请求
    [socket on:@"videoChat" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
        UIViewController *vc = [self getCurrentVC];
        NSDictionary *dataDict = data.firstObject;
        FLVideoChatViewController *videoVC = [[FLVideoChatViewController alloc] initWithFromUser:dataDict[@"from_user"] toUser:[FLClientManager shareManager].currentUserID type:FLVideoChatCallee];
        videoVC.chatType = [dataDict[@"chat_type"] integerValue];
        videoVC.room = dataDict[@"room"];
        [vc presentViewController:videoVC animated:YES completion:nil];
        FLLog(@"%@============", data);
    }];
    
    // 用户上线
    [socket on:@"onLine" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
        for (FLBridgeDelegateModel  *model in self.delegateArray) {
            
            id<FLClientManagerDelegate>delegate = model.delegate;
            if (delegate && [delegate respondsToSelector:@selector(clientManager:userOnline:)]) {
                
                [delegate clientManager:self userOnline:[data.firstObject valueForKey:@"user"]];
            }
        }
    }];
    
    // 用户下线
    [socket on:@"offLine" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
        for (FLBridgeDelegateModel  *model in self.delegateArray) {
            
            id<FLClientManagerDelegate>delegate = model.delegate;
            if (delegate && [delegate respondsToSelector:@selector(clientManager:userOffline:)]) {
                
                [delegate clientManager:self userOffline:[data.firstObject valueForKey:@"user"]];
            }
        }
    }];
    

    
    // 连接状态改变
    [socket on:@"statusChange" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
        FLLog(@"%ld========================状态改变", socket.status);
        for (FLBridgeDelegateModel  *model in self.delegateArray) {
            
            id<FLClientManagerDelegate>delegate = model.delegate;
            if (delegate && [delegate respondsToSelector:@selector(clientManager:didChangeStatus:)]) {
                
                [delegate clientManager:self didChangeStatus:socket.status];
            }
        }
    }];
}


//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]]){
        result = nextResponder;
    }
    else {
        result = window.rootViewController;
    }
    return result;
}

@end
