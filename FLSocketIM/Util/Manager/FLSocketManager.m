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
    SocketIOClient* socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @YES, @"forcePolling": @YES, @"connectParams": @{@"auth_token" : token}}];

    [socket connect];
    _client = socket;
    
    __block BOOL isConnect = false;
    [socket on:@"connect" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
        isConnect = true;
        success();
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (!isConnect) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_client disconnect];
                fail();
            });
        }
    });
}


+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

@end
