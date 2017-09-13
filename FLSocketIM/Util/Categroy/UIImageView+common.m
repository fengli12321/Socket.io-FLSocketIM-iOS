//
//  UIImageView+common.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/24.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "UIImageView+common.h"

@implementation UIImageView (common)

//- (void)fl_setImageWithURL:(NSString *)url locSavePath:(NSString *)localPath placeholderImage:(UIImage *)placeholderImage {
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        UIImage *image;
//        if (localPath.length) {
//            
//            NSFileManager *fileManager = [NSFileManager defaultManager];
//            NSData *imageData = [fileManager contentsAtPath:[[NSString getFielSavePath] stringByAppendingPathComponent:localPath]];
//            image = [UIImage imageWithData:imageData];
//        };
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            if (image) {
//                [self setImage:image];
//            }
//            else {
//                [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholderImage];
//            }
//        });
//    });
//    
//    
//}

@end
