//
//  FLBarBadgeLabel.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/25.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^clearBadgeCompletion)();
@interface FLBarBadgeLabel : UILabel

@property (nonatomic, copy) clearBadgeCompletion clearCompletion;

@end
