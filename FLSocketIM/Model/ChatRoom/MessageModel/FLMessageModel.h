//
//  FLMessageModel.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/7.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FLMessageBody;
typedef NS_ENUM(NSInteger, FLMessageModelType) {
    FLMessageText,
    FLMessageImage,
    FLMessageOther
};
@interface FLMessageModel : NSObject

@property (nonatomic, assign) CGFloat messageCellHeight;
@property (nonatomic, assign) BOOL isSender;


@property (nonatomic, copy) NSString *msg_id;           //消息ID
@property (nonatomic, copy) NSString *timestamp;        //消息发送时间
@property (nonatomic, copy) NSString *to;               //接收人的username或者接收group的ID
@property (nonatomic, copy) NSString *from;             //发送人username
@property (nonatomic, strong) FLMessageBody *bodies;     // 消息体对象

@end

@interface FLMessageBody : NSObject

@property (nonatomic, weak) FLMessageModel *superModel;
@property (nonatomic, assign) CGSize textMessageLabelSize;

@property (nonatomic, copy) NSString *type;     // 消息类型
@property (nonatomic, copy) NSString *msg;      // 文本消息内容
@property (nonatomic, copy) NSString *imgUrl;   // 图片远程地址
@property (nonatomic, copy) NSString *imageName;    // 图片名称

@end
