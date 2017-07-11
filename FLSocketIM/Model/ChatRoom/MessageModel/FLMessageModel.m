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
    
    _messageCellHeight = 0;
    
    if (! bodies.msg.length) {
        return;
    }
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:[FLMessageBubbleView appearance].textFont.pointSize + 1], NSParagraphStyleAttributeName : style };
    CGRect rect = [bodies.msg boundingRectWithSize:CGSizeMake(kScreenWidth*3/5.0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil];
    
    rect.size.height = rect.size.height>40?rect.size.height:40;
    rect.size.width = rect.size.width>50?rect.size.width:50;
    _textMessageLabelSize = rect.size;
    _messageCellHeight += _textMessageLabelSize.height + 10 + [FLMessageBubbleView appearance].textSendInsets.top + [FLMessageBubbleView appearance].textSendInsets.bottom + 15;
}

@end

@implementation FLMessageBody

- (void)setMsg:(NSString *)msg {
    _msg = [msg copy];
    
    
}

@end
