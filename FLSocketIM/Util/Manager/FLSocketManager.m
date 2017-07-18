//
//  FLSocketManager.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/7.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLSocketManager.h"

static FLSocketManager *instance = nil;
@interface FLSocketManager ()

@end
@implementation FLSocketManager

#pragma mark - init
+ (instancetype)shareManager {
    
    return [[FLSocketManager alloc] init];
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super init];
    });
    return instance;
}

- (void)connectWithToken:(NSString *)token success:(void (^)())success fail:(void (^)())fail {
    
    
    NSURL* url = [[NSURL alloc] initWithString:BaseUrl];
    SocketIOClient* socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @NO, @"forcePolling": @YES, @"connectParams": @{@"auth_token" : token}}];

    // 连接超时时间设置为15秒
    [socket connectWithTimeoutAfter:15 withHandler:^{
        
        fail();
    }];
    
    // 监听一次连接成功
    [socket once:@"connect" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
        success();
    }];
    
    _client = socket;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    
    FLLog(@"==========fsafsa==========asfdsaf===========afsaf================");
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

@end
