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
    
    self.latestMsgTimeStamp = latestMessage.timestamp;
    self.latestMsgStr = [FLConversationModel getLatestMessageStrWithMessage:latestMessage];
    
}

- (instancetype)initWithMessageModel:(FLMessageModel *)message {
    if (self = [super init]) {
        
        self.latestMessage = message;
        self.userName = message.from;
    }
    return self;
}


+ (NSString *)getLatestMessageStrWithMessage:(FLMessageModel *)message {
    
    NSString *latestMsgStr;
    switch (message.type) {
        case FLMessageText:
            latestMsgStr = message.bodies.msg;
            break;
            
        case FLMessageImage:
            latestMsgStr = @"[图片]";
            break;
            
        case FLMessageOther:
            latestMsgStr = @"[其他]";
            break;
            
        default:
            latestMsgStr = @"错误";
            break;
    }
    return latestMsgStr;
}

@end
