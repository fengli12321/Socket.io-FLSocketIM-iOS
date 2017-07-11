//
//  FLChatManager.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/10.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLChatManager.h"
#import "FLSocketManager.h"
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
    
    [self.delegateArray addObject:delegate];
}

- (void)removeDelegate:(id<FLChatManagerDelegate>)delegate {
    
    [self.delegateArray removeObject:delegate];
}

- (void)sendMessage:(FLMessageModel *)message {
    
}

#pragma mark - Private
- (void)addHandles {
    
    SocketIOClient *socket = [FLSocketManager shareManager].client;
    [socket onAny:^(SocketAnyEvent * _Nonnull event) {
        
        //        NSLog(@"%@==========????%@", event.event, event.items);
    }];
    
    [socket on:@"disconnect" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
        NSLog(@"确实断开连接了");
    }];
    [socket on:@"chat" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
        for (id<FLChatManagerDelegate> delegate in self.delegateArray) {
            
            if ([delegate respondsToSelector:@selector(chatManager:didReceivedMessage:)]) {
                FLMessageModel *message = [FLMessageModel yy_modelWithJSON:data.firstObject];
                if (message) {
                    [delegate chatManager:self didReceivedMessage:message];
                }
                
            }
        }
    }];
}

@end
