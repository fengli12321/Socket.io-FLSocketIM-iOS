//
//  FLBridgeDelegateModel.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/12.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLBridgeDelegateModel.h"

@implementation FLBridgeDelegateModel

- (instancetype)initWithDelegate:(id)delegate {
    if (self = [super init]) {
        
        self.delegate = delegate;
    }
    return self;
}

@end
