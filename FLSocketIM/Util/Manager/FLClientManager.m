//
//  FLClientManager.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/10.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLClientManager.h"
#import "FLBridgeDelegateModel.h"
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
        

        FLMessageModel *message = [FLMessageModel yy_modelWithJSON:data.firstObject];
        id bodyStr = data.firstObject[@"bodies"];
        if ([bodyStr isKindOfClass:[NSString class]]) {
            FLMessageBody *body = [FLMessageBody yy_modelWithJSON:[bodyStr stringToJsonDictionary]];
            message.bodies = body;
        }
        
        // 消息插入数据库
        [[FLChatDBManager shareManager] addMessage:message];
        
        // 会话插入数据库或者更新会话
        [[FLChatDBManager shareManager] addOrUpdateConversationWithMessage:message];
        
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
    
//    // socket连接
//    [socket on:@"connect" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
//        
//        FLLog(@"%ld========================状态socket连接", socket.status);
//    }];
//    
//    // socket断开连接
//    [socket on:@"disconnect" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
//        
//        FLLog(@"%ld========================状态socket断开连接", socket.status);
//    }];
//    
//    // socket重新连接
//    [socket on:@"reconnect" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
//        
//        FLLog(@"%ld========================状态socket重新连接", socket.status);
//    }];
//    
//    // socket重连尝试
//    [socket on:@"reconnectAttempt" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
//        
//        FLLog(@"%ld========================状态socket重连尝试", socket.status);
//    }];
    
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

@end
