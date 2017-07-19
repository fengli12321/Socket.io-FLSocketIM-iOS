//
//  FLConversationModel.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/14.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLConversationModel.h"

@implementation FLConversationModel

- (void)setLatestMessage:(FLMessageModel *)latestMessage {
    _latestMessage = latestMessage;
    
    switch (latestMessage.type) {
        case FLMessageText:
            self.latestMsgStr = latestMessage.bodies.msg;
            break;
            
        case FLMessageImage:
            self.latestMsgStr = @"[图片]";
            break;
            
        case FLMessageOther:
            self.latestMsgStr = @"[其他]";
            break;
            
        default:
            break;
    }
    
}

- (instancetype)initWithMessageModel:(FLMessageModel *)message {
    if (self = [super init]) {
        
        self.latestMessage = message;
        self.userName = message.from;
    }
    return self;
}


@end
