//
//  FLImageBrowseCell.m
//  FLSocketIM
//
//  Created by 冯里 on 10/09/2017.
//  Copyright © 2017 冯里. All rights reserved.
//

#import "FLImageBrowseCell.h"
#import "FLImageBrowseModel.h"

@interface FLImageBrowseCell () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) UIImageView *imageView;

@end
@implementation FLImageBrowseCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self creatUI];
    }
    return self;
}

- (void)creatUI {
    
    _imageScrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _imageScrollView.minimumZoomScale = 1;
    _imageScrollView.maximumZoomScale = 3;
    _imageScrollView.delegate = self;
    [_imageScrollView setShowsVerticalScrollIndicator:NO];
    [_imageScrollView setShowsHorizontalScrollIndicator:NO];
    [self.contentView addSubview:_imageScrollView];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.userInteractionEnabled = YES;
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageScrollView addSubview:_imageView];
    
    
    
    UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneClick)];
    [_imageView addGestureRecognizer:oneTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
    doubleTap.numberOfTapsRequired = 2;
    [oneTap requireGestureRecognizerToFail:doubleTap];
    [_imageView addGestureRecognizer:doubleTap];
}

- (void)oneClick {
    
    if (self.closeBrowserBlock) {
        self.closeBrowserBlock();
    }
}

- (void)doubleClick:(UITapGestureRecognizer *)tap {
    FLLog(@"==============double");
    
    if (_imageScrollView.zoomScale > 1.0) {
        [_imageScrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _imageScrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [_imageScrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)setImageModel:(FLImageBrowseModel *)imageModel {
    _imageModel = imageModel;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *image;
        if (imageModel.imageName.length) { // 从本地读取图片
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSData *imageData = [fileManager contentsAtPath:[[NSString getFielSavePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"s_%@", imageModel.imageName]]];
            image = [UIImage imageWithData:imageData];
            
        };
        
        if (!image)  { // 本地未取到图片
            
            // 从sd缓存中取图
            NSString* strUrl = [BaseUrl stringByAppendingPathComponent:imageModel.thumRemotePath];
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            NSString* key = [manager cacheKeyForURL:[NSURL URLWithString:strUrl]];
            SDImageCache* cache = [SDImageCache sharedImageCache];
            //此方法会先从memory中取。
            image = [cache imageFromCacheForKey:key];
 
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BaseUrl, imageModel.imageRemotePath]] placeholderImage:image];
        });
    });
    _imageView.frame = imageModel.imageRect;
}

- (void)showAnimationWithStartRect:(CGRect)rect{
    
    _imageView.frame = rect;
    [UIView animateWithDuration:0.3 animations:^{
        
        _imageView.frame = self.imageModel.imageRect;
    }];
}

- (void)hideAnimationWithEndRect:(CGRect)rect complete:(void (^)())complete {
    [UIView animateWithDuration:0.3 animations:^{
        
        _imageView.frame = rect;
    } completion:^(BOOL finished) {
        
        complete();
    }];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.width > scrollView.contentSize.width) ? (scrollView.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.height > scrollView.contentSize.height) ? (scrollView.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

@end
