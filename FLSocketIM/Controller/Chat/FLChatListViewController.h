//
//  FLChatListViewController.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/6.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLViewController.h"
@class FLConversationModel;
@class FLMessageModel;
@interface FLChatListViewController : FLViewController


/**
 与某个联系人的会话是否存在，存在的话返回该会话

 @param toUser 会话的目标联系人
 @return 与某个联系人的会话
 */
- (FLConversationModel *)isExistConversationWithToUser:(NSString *)toUser;




/**
 会话存在，则更新会话最新消息，不存在则添加该会话

 @param conversationName 会话ID
 @param message 最新一条消息
 */
- (void)addOrUpdateConversation:(NSString *)conversationName latestMessage:(FLMessageModel *)message isRead:(BOOL)isRead;

/**
 添加会话

 @param message 会话的最新一条消息
 @param read 消息是否已读
 */
//- (void)addConversationWithMessage:(FLMessageModel *)message isReaded:(BOOL)read;



/**
 更新会话的最新消息，包括模型数据和UI

 @param message 会话的最新一条消息
 */
//- (void)updateLatestMsgForConversation:(FLConversationModel *)conversation latestMessage:(FLMessageModel *)message;

/**
 更新未读消息红点

 @param conversationName 会话ID
 */
- (void)updateRedPointForUnreadWithConveration:(NSString *)conversationName;

@end
