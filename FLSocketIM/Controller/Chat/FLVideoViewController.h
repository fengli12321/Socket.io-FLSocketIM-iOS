//
//  FLVideoViewController.h
//  FLSocketIM
//
//  Created by 冯里 on 11/08/2017.
//  Copyright © 2017 冯里. All rights reserved.
//

#import "FLViewController.h"

@interface FLVideoViewController : FLViewController

@property (nonatomic, copy) void(^takePhotoOrVideo)(NSData *data, BOOL isPhoto);
@property (nonatomic, assign) NSInteger maxSeconds;

@end

@interface FLVideoPlayer : UIView

@property (nonatomic, copy) NSURL *videoUrl;
- (instancetype)initWithFrame:(CGRect)frame showInView:(UIView *)bgView url:(NSURL *)url;
- (void)stopPlayer;

@end
