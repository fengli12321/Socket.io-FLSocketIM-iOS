//
//  FLImageBrowseModel.m
//  FLSocketIM
//
//  Created by 冯里 on 10/09/2017.
//  Copyright © 2017 冯里. All rights reserved.
//

#import "FLImageBrowseModel.h"

@implementation FLImageBrowseModel

- (instancetype)initWithMessage:(FLMessageModel *)message {
    if (self = [super init]) {
        
        FLMessageBody *body = message.bodies;
        self.imageRemotePath = body.fileRemotePath;
        self.imageName = body.fileName;
    }
    return self;
}

- (void)setImageSize:(CGSize)imageSize {
    _imageSize = imageSize;
    CGFloat widthRatio = kScreenWidth/imageSize.width;
    CGFloat heigthRatio = kScreenHeight/imageSize.height;
    CGFloat scale = MIN(widthRatio, heigthRatio);
    CGFloat width = scale * imageSize.width;
    CGFloat height = scale * imageSize.height;
    self.imageRect = CGRectMake((kScreenWidth - width)/2.0, (kScreenHeight - height)/2, width, height);
}

@end
