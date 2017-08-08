//
//  FLStatusTitleView.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/26.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLStatusTitleView : UIView

- (void)updateWithLinkStatus:(SocketIOClientStatus)status;

@end
