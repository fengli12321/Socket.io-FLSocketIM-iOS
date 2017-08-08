//
//  FLStatusTitleView.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/26.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLStatusTitleView.h"

@interface FLStatusTitleView ()

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end
@implementation FLStatusTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    _statusLabel = [[UILabel alloc] init];
    _statusLabel.textColor = [UIColor whiteColor];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    _statusLabel.font = [UIFont boldSystemFontOfSize:18];
    [self addSubview:_statusLabel];
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    _indicator.x = 0;
    _indicator.y = (self.height - _indicator.height) / 2.0;
    [self addSubview:_indicator];
    
    [self updateWithLinkStatus:[FLSocketManager shareManager].client.status];
}

- (void)updateWithLinkStatus:(SocketIOClientStatus)status {
    
    switch (status) {
        case SocketIOClientStatusNotConnected:{
            
            [_indicator stopAnimating];
            _statusLabel.x = 0;
            _statusLabel.text = @"FoxChat(未连接)";
            break;
        }
            
        case SocketIOClientStatusDisconnected:{
            
            [_indicator stopAnimating];
            _statusLabel.x = 0;
            _statusLabel.text = @"FoxChat(连接断开)";
            break;
        }
            
        case SocketIOClientStatusConnecting:{
            
            [_indicator startAnimating];
            _statusLabel.x = _indicator.maxX;
            _statusLabel.text = @"FoxChat(连接中...)";
            break;
        }
            
        case SocketIOClientStatusConnected:{
            
            [_indicator stopAnimating];
            _statusLabel.x = 0;
            _statusLabel.text = @"FoxChat";
            break;
        }
            
        default:
            break;
    }
    
    [_statusLabel sizeToFit];
    _statusLabel.height = self.height;
    self.width = _statusLabel.maxX;
}

@end
