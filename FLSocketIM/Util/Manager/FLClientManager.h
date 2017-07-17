//
//  FLClientManager.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/10.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FLChatViewController;
@class FLChatListViewController;
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

@end
