//
//  FLFriendsListCell.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/12.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLFriendsListCell.h"
#import "FLFriendModel.h"

@interface FLFriendsListCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *statusLabel;

@end
@implementation FLFriendsListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        
        _iconImage = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconImage];
        [_iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(kMargin);
            make.width.height.mas_equalTo(40);
        }];
//        _iconImage.backgroundColor = RGBAColor(arc4random()%256, arc4random()%256, arc4random()%256, 1);
        
        _nameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(_iconImage.mas_right).offset(kPadding);
            make.centerY.equalTo(self);
        }];
        _nameLabel.font = FLFont(16);
        
        
        
        _statusLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_statusLabel];
        [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(self).offset(-kMargin);
            make.centerY.equalTo(self);
        }];
        _statusLabel.textColor = FLSecondColor;
        _statusLabel.font = FLFont(14);
    }
    return self;
}

- (void)setModel:(FLFriendModel *)model {
    _model = model;
    _nameLabel.text = model.name;
    _statusLabel.text = model.isOnline ? @"[在线]" : @"[离线]";
}

@end
