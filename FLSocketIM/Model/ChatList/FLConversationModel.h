//
//  FLConversationModel.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/14.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FLMessageModel;

@interface FLConversationModel : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, strong) FLMessageModel *latestMessage;
@property (nonatomic, copy) NSString *imageStr;
@property (nonatomic, copy) NSString *latestMsgStr;
@property (nonatomic, assign) NSInteger unReadCount;

- (instancetype)initWithMessageModel:(FLMessageModel *)message;
@end
