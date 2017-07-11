//
//  FLChatManager.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/10.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLMessageModel.h"

@class FLChatManager;
@protocol FLChatManagerDelegate <NSObject>

@optional
- (void)chatManager:(FLChatManager *)manager didReceivedMessage:(FLMessageModel *)message;

@end
@interface FLChatManager : NSObject

+ (instancetype)shareManager;

- (void)addDelegate:(id<FLChatManagerDelegate>)delegate;

- (void)removeDelegate:(id<FLChatManagerDelegate>)delegate;

- (void)sendMessage:(FLMessageModel *)message;

@end
