//
//  FLChatListCell.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/14.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLChatListCell.h"
#import "FLConversationModel.h"
#import "FLBadgeLabel.h"
@interface FLChatListCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *lastMessageLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) FLBadgeLabel *unReadMsgCountLabel;

@end
@implementation FLChatListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self creatUI];
    }
    return self;
}

- (void)creatUI {
    
    _iconImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_iconImageView];
    
    _nameLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_nameLabel];
    _nameLabel.font = FLFont(17);
    
    _lastMessageLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_lastMessageLabel];
    _lastMessageLabel.font = FLFont(14);
    _lastMessageLabel.textColor = FLSecondColor;
    
    _timeLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_timeLabel];
    _timeLabel.font = FLFont(13);
    _timeLabel.textColor = FLLightGrayColor;
    
    
    _unReadMsgCountLabel = [[FLBadgeLabel alloc] init];
    [self.contentView addSubview:_unReadMsgCountLabel];
    [_unReadMsgCountLabel setPersistentBackgroundColor:[UIColor redColor]];
    _unReadMsgCountLabel.textColor = [UIColor whiteColor];
    _unReadMsgCountLabel.font = FLFont(13);
    _unReadMsgCountLabel.layer.cornerRadius = 7;
    _unReadMsgCountLabel.layer.masksToBounds = YES;
    _unReadMsgCountLabel.textAlignment = NSTextAlignmentCenter;
    
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(kMargin);
        make.width.height.mas_equalTo(50);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(_iconImageView);
        make.left.equalTo(_iconImageView.mas_right).offset(kPadding);
    }];
    
    [_lastMessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(_nameLabel);
        make.bottom.equalTo(_iconImageView);
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self).offset(-kMargin);
        make.centerY.equalTo(_nameLabel);
    }];
    
    [_unReadMsgCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(_iconImageView.mas_right);
        make.centerY.equalTo(_iconImageView.mas_top);
        make.height.mas_equalTo(15);
    }];
    
    
}

- (void)setModel:(FLConversationModel *)model {

    _model = model;
    _iconImageView.image = [UIImage imageNamed:model.imageStr];
    _nameLabel.text = model.userName;
    _timeLabel.text = [NSDate stringTimesWithTimeStamp:model.latestMsgTimeStamp];
    _lastMessageLabel.text = model.latestMsgStr;
    
    [self updateUnreadCount];
}


- (void)updateUnreadCount {
    FLConversationModel *model = self.model;
    _unReadMsgCountLabel.hidden = model.unReadCount <= 0;
    if (model.unReadCount) {
        _unReadMsgCountLabel.text = model.unReadCount > 99 ? @"99+" : [NSString stringWithFormat:@"%ld", model.unReadCount];
        CGFloat width = model.unReadCount > 9 ? (model.unReadCount > 99 ? 30 : 22) : 15;
        [_unReadMsgCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.width.mas_equalTo(width);
        }];
    }
}


@end
