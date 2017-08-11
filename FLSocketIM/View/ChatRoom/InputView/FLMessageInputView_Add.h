//
//  FLMessageInputView_Add.h
//  FLSocketIM
//
//  Created by 冯里 on 10/08/2017.
//  Copyright © 2017 冯里. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLMessageInputView_Add : UIView

@property (copy, nonatomic) void(^addIndexBlock)(NSInteger);

@end
