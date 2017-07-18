//
//  FLBridgeDelegateModel.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/12.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FLBridgeDelegateModel : NSObject

@property (nonatomic, weak) id delegate;

- (instancetype)initWithDelegate:(id)delegate;

@end
