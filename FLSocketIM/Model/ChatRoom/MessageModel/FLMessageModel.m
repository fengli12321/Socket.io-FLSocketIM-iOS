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
        self.type = FLMessageImage;
        if (bodies.size) {
            
            [self setImageCellSize];
        }
        else {
            bodies.superModel = self;
        }
        
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

+ (NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"messageCellHeight"];
}

- (void)setImageCellSize {
    
    NSDictionary *size = self.bodies.size;
    CGFloat height = [size[@"height"] floatValue];
    _messageCellHeight = height + 10 + 15;
    
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

- (void)setSize:(NSDictionary *)size {
    
    
    CGFloat width = [size[@"width"] floatValue];
    CGFloat height = [size[@"height"] floatValue];
    CGFloat scale = width/height;
    CGFloat refer = scale>1?width:height;
    CGFloat imageScale;
    if (refer > 300) {
        
        imageScale = refer/300*2.0;
    }
    else {
        imageScale = 1;
    }
    
    _size = @{@"width" : @(width/imageScale), @"height" : @(height/imageScale)};
    if (self.superModel) {
        
        [self.superModel setImageCellSize];
    }
}

+ (NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"superModel"];
}

@end
