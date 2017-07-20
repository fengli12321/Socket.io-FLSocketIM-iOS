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
 发送文字消息
 
 @param text 图片数据
 @param toUser 发送目标
 @param sendStatus 状态改变返回消息模型
 @return 消息模型
 */
- (FLMessageModel *)sendTextMessage:(NSString *)text toUser:(NSString *)toUser sendStatus:(void(^)(FLMessageModel *message))sendStatus;



/**
 发送图片消息

 @param imgData 图片数据
 @param toUser 发送目标
 @param sendStatus 状态改变返回消息模型
 @return 消息模型
 */
- (FLMessageModel *)sendImgMessage:(NSData *)imgData toUser:(NSString *)toUser sendStatus:(void(^)(FLMessageModel *message))sendStatus;

@end
