//
//  FLMessageModel.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/7.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLMessageModel.h"
#import "FLMessageBubbleView.h"
#import "FLMessageCell.h"

@implementation FLMessageModel

- (void)setBodies:(FLMessageBody *)bodies {
    _bodies = bodies;
    bodies.superModel = self;
}

@end

@implementation FLMessageBody

- (void)setMsg:(NSString *)msg {
    _msg = [msg copy];
    
    self.superModel.messageCellHeight = 0;
    
    if (!msg.length) {
        return;
    }
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:16], NSParagraphStyleAttributeName : style };
    CGRect rect = [msg boundingRectWithSize:CGSizeMake(kScreenWidth*3/5.0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil];
    
    _textMessageLabelSize = rect.size;
    self.superModel.messageCellHeight += _textMessageLabelSize.height + 10 + [FLMessageBubbleView appearance].textSendInsets.top + [FLMessageBubbleView appearance].textSendInsets.bottom + 15;
}

@end
