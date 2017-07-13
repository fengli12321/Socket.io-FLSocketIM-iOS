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

/**
 监听收到新消息

 @param manager 聊天管理类
 @param message 收到的消息模型
 */
- (void)chatManager:(FLChatManager *)manager didReceivedMessage:(FLMessageModel *)message;

/**
 监听到用户上线

 @param manager 聊天管理类
 @param userName 上线用户
 */
- (void)chatManager:(FLChatManager *)manager userOnline:(NSString *)userName;

/**
 监听到用户下线

 @param manager 聊天管理类
 @param userName 下线用户
 */
- (void)chatManager:(FLChatManager *)manager userOffline:(NSString *)userName;

@end
@interface FLChatManager : NSObject

+ (instancetype)shareManager;

/**
 添加代理

 @param delegate 代理
 */
- (void)addDelegate:(id<FLChatManagerDelegate>)delegate;

/**
 移除代理

 @param delegate 代理
 */
- (void)removeDelegate:(id<FLChatManagerDelegate>)delegate;

/**
 发送文本消息

 @param text 文本消息内容
 @param toUser 发送目标人
 @return 消息模型
 */
- (FLMessageModel *)sendTextMessage:(NSString *)text toUser:(NSString *)toUser;

/**
 发送图片消息

 @param imgData 图片数据
 @param toUser 发送目标
 @return 消息模型
 */
- (FLMessageModel *)sendImgMessage:(NSData *)imgData toUser:(NSString *)toUser;

@end
