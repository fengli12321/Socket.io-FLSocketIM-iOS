//
//  FLFriendsListCell.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/12.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FLFriendModel;
@interface FLFriendsListCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconImage;

@property (nonatomic, strong) FLFriendModel *model;

@end
