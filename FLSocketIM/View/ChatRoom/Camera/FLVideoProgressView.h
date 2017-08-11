//
//  FLVideoProgressView.h
//  FLSocketIM
//
//  Created by 冯里 on 11/08/2017.
//  Copyright © 2017 冯里. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLVideoProgressView : UIView

@property (nonatomic, assign) NSInteger timeMax;

- (void)clearProgress;

@end
