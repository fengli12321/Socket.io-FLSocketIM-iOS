//
//  FLChatListCell.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/14.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FLConversationModel;
@interface FLChatListCell : UITableViewCell

@property (nonatomic, strong) FLConversationModel *model;

- (void)updateUnreadCount;

@end
