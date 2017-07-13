//
//  FLFriendsListCell.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/12.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLFriendsListCell.h"

@interface FLFriendsListCell ()



@end
@implementation FLFriendsListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        
        _iconImage = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconImage];
        [_iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(kMargin);
            make.width.height.mas_equalTo(50);
        }];
//        _iconImage.backgroundColor = RGBAColor(arc4random()%256, arc4random()%256, arc4random()%256, 1);
        
        _nameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(_iconImage.mas_right).offset(kPadding);
            make.centerY.mas_equalTo(self);
        }];
        _nameLabel.font = FLFont(16);
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
