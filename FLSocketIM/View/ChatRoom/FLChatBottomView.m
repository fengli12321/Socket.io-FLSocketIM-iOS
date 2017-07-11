//
//  FLChatBottomView.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/10.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLChatBottomView.h"

@implementation FLChatBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self creatUI];
    }
    return self;
}

- (void)creatUI {
    
    UILabel *inputLabel = [[UILabel alloc] initWithFrame:self.frame];
    inputLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:inputLabel];
}

@end
