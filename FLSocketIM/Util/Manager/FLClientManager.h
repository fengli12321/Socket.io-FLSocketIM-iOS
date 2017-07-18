//
//  FLClientManager.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/10.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <Foundation/Foundation.h>
@import SocketIO;
@class FLChatViewController;
@class FLChatListViewController;
@class FLMessageModel;
@protocol FLClientManagerDelegate;
@interface FLClientManager : NSObject

+ (instancetype)shareManager;

/**
 当前用户ID
 */
@property (nonatomic, copy) NSString *currentUserID;

/**
 token
 */
@property (nonatomic, copy) NSString *auth_token;

/**
 全部未读消息数量
 */
@property (nonatomic, assign) NSInteger *unreadMessageCount;


/**
 正在聊天的会话控制器
 */
@property (nonatomic, weak) FLChatViewController *chattingConversation;


/**
 消息会话列表
 */
@property (nonatomic, weak) FLChatListViewController *chatListVC;


/**
 添加代理
 
 @param delegate 代理
 */
- (void)addDelegate:(id<FLClientManagerDelegate>)delegate;

/**
 移除代理
 
 @param delegate 代理
 */
- (void)removeDelegate:(id<FLClientManagerDelegate>)delegate;

@end

@protocol FLClientManagerDelegate <NSObject>

@optional
/**
 连接状态发生变化

 @param manager 客户端管理器
 @param status 变化的状态
 */
- (void)clientManager:(FLClientManager *)manager didChangeStatus:(SocketIOClientStatus)status;


/**
 监听收到新消息
 
 @param manager 聊天管理类
 @param message 收到的消息模型
 */
- (void)clientManager:(FLClientManager *)manager didReceivedMessage:(FLMessageModel *)message;

/**
 监听到用户上线
 
 @param manager 聊天管理类
 @param userName 上线用户
 */
- (void)clientManager:(FLClientManager *)manager userOnline:(NSString *)userName;

/**
 监听到用户下线
 
 @param manager 聊天管理类
 @param userName 下线用户
 */
- (void)clientManager:(FLClientManager *)manager userOffline:(NSString *)userName;



@end
