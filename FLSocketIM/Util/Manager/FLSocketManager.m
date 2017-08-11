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
    
    /**
     log 是否打印日志
     forceNew      这个参数设为NO从后台恢复到前台时总是重连，暂不清楚原因
     forcePolling  是否强制使用轮询
     reconnectAttempts 重连次数，-1表示一直重连
     reconnectWait 重连间隔时间
     connectParams 参数
     forceWebsockets 是否强制使用websocket, 解释The reason it uses polling first is because some firewalls/proxies block websockets. So polling lets socket.io work behind those.
     来源：https://github.com/socketio/socket.io-client-swift/issues/449
     */
    SocketIOClient* socket;
    if (!self.client) {
        socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @NO, @"forceNew" : @YES, @"forcePolling": @NO, @"reconnectAttempts":@(-1), @"reconnectWait" : @4, @"connectParams": @{@"auth_token" : token}, @"forceWebsockets" : @NO}];
    }
    else {
        socket = self.client;
        socket.engine.connectParams = @{@"auth_token" : token};
    }
    

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
