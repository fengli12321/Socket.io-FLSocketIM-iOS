//
//  FLClientManager.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/10.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLClientManager : NSObject

+ (instancetype)shareManager;
@property (nonatomic, copy) NSString *currentUserID;
@property (nonatomic, copy) NSString *auth_token;

@end
