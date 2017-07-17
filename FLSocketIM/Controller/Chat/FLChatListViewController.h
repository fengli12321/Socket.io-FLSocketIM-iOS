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
 添加会话

 @param message 会话的最新一条消息
 @param read 消息是否已读
 */
- (void)addConversationWithMessage:(FLMessageModel *)message isReaded:(BOOL)read;

@end
