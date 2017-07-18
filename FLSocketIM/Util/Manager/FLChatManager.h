//
//  FLChatManager.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/10.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLMessageModel.h"

@class FLChatManager;

@interface FLChatManager : NSObject

+ (instancetype)shareManager;



/**
 发送文本消息

 @param text 文本消息内容
 @param toUser 发送目标人
 @return 消息模型
 */
- (FLMessageModel *)sendTextMessage:(NSString *)text toUser:(NSString *)toUser;

/**
 发送图片消息

 @param imgData 图片数据
 @param toUser 发送目标
 @return 消息模型
 */
- (FLMessageModel *)sendImgMessage:(NSData *)imgData toUser:(NSString *)toUser;

@end
