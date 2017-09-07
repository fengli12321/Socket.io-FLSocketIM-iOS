//
//  FLVideoChatViewController.h
//  FLSocketIM
//
//  Created by 冯里 on 29/08/2017.
//  Copyright © 2017 冯里. All rights reserved.
//

#import "FLViewController.h"

typedef NS_ENUM(NSInteger, FLVideoChatType) {
    
    FLVideoChatCaller,  // 通话发起者
    FLVideoChatCallee   // 通话被请求者
};
@interface FLVideoChatViewController : FLViewController

@property (nonatomic, copy) NSString *room;
- (instancetype)initWithFromUser:(NSString *)fromUser toUser:(NSString *)toUser type:(FLVideoChatType)type;

@end
