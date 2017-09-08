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

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    
    return @{@"to" : @"to_user", @"from" : @"from_user"};
}

- (void)setBodies:(FLMessageBody *)bodies {
    _bodies = bodies;
    
    _messageCellHeight = 0;
    
    NSString *type = bodies.type;
    if ([type isEqualToString:@"txt"]) {
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineBreakMode:NSLineBreakByCharWrapping];
        
        NSDictionary *attributes = @{ NSFontAttributeName : [FLMessageBubbleView appearance].textFont, NSParagraphStyleAttributeName : style };
        CGRect rect = [bodies.msg boundingRectWithSize:CGSizeMake(kScreenWidth*3/5.0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil];
        
        rect.size.width = ceil(rect.size.width);
        rect.size.height = ceil(rect.size.height>35?rect.size.height:35);
        _textMessageLabelSize = rect.size;
        _messageCellHeight += _textMessageLabelSize.height + 10 + [FLMessageBubbleView appearance].textSendInsets.top + [FLMessageBubbleView appearance].textSendInsets.bottom + 15;
        self.type = FLMessageText;
    }
    else if ([type isEqualToString:@"img"]) {
        _messageCellHeight = kScreenWidth/4 *1.5 + 10 + 15;
        self.type = FLMessageImage;
    }
    else if ([type isEqualToString:@"loc"]) {
        self.type = FLMessageLoc;
        _messageCellHeight = 150 + 10 + 15;
    }
    else if ([type isEqualToString:@"audio"]) {
        self.type = FlMessageAudio;
        _messageCellHeight = 60;
    }
    else if ([type isEqualToString:@"video"]) {
        self.type = FLMessageVideo;
        _messageCellHeight = 40;
    }
    else {
        self.type = FLMessageOther;
    }

    
}

- (instancetype)initWithToUser:(NSString *)toUser fromUser:(NSString *)fromUser chatType:(NSString *)chatType messageBody:(FLMessageBody *)body{
    if (self = [super init]) {
        
        _to = toUser;
        _from = fromUser;
        _chat_type = chatType;
        self.bodies = body;
    }
    return self;
}

@end

@implementation FLMessageBody



@end
