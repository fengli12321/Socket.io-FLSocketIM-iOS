//
//  FLImageBrowseViewController.m
//  FLSocketIM
//
//  Created by 冯里 on 10/09/2017.
//  Copyright © 2017 冯里. All rights reserved.
//

#import "FLImageBrowseViewController.h"
#import "FLImageBrowseCell.h"
#import "FLImageBrowseModel.h"
#import "FLChatViewController.h"

@interface FLImageBrowseViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) BOOL firstLoad;

@end

@implementation FLImageBrowseViewController

- (instancetype)initWithImageModels:(NSArray *)imageModels selectedIndex:(NSInteger)selectedIndex{
    if (self = [super init]) {
        self.firstLoad = YES;
        self.dataArray = [imageModels copy];
        self.selectedIndex = selectedIndex;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.firstLoad) {
        self.firstLoad = NO;
        FLImageBrowseModel *model = self.dataArray[self.selectedIndex];
        FLImageBrowseCell *cell = (FLImageBrowseCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0]];
        FLChatViewController *chatVC = [FLClientManager shareManager].chattingConversation;
        CGRect rect = [chatVC getImageRectInWindowAtIndex:model.messageIndex];
        [cell showAnimationWithStartRect:rect];
    }
    
}


#pragma mark - UI
- (void)creatUI {
    
    // self
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = [UIScreen mainScreen].bounds.size;
    [layout setSectionInset:UIEdgeInsetsZero];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [_collectionView setShowsHorizontalScrollIndicator:NO];
    [_collectionView setShowsVerticalScrollIndicator:NO];
    [_collectionView setPagingEnabled:YES];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[FLImageBrowseCell class] forCellWithReuseIdentifier:NSStringFromClass([FLImageBrowseCell class])];
    [_collectionView setContentOffset:CGPointMake(self.selectedIndex * kScreenWidth, 0)];
    [self.view addSubview:_collectionView];
    
    
}
#pragma mark - Private
- (void)closeAnimation {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.collectionView.contentOffset.x/kScreenWidth inSection:0];
    FLImageBrowseCell *cell = (FLImageBrowseCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    FLChatViewController *chatVC = [FLClientManager shareManager].chattingConversation;
    FLImageBrowseModel *model = self.dataArray[indexPath.row];
    CGRect rect = [chatVC getImageRectInWindowAtIndex:model.messageIndex];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [cell hideAnimationWithEndRect:rect complete:^{
        
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

#pragma mark - Public
- (void)show {
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    
    
    
}
#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FLImageBrowseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FLImageBrowseCell class]) forIndexPath:indexPath];
    FLImageBrowseModel *imageModel = self.dataArray[indexPath.item];
    cell.imageModel = imageModel;
    
    __weak typeof(self) weakSelf = self;
    [cell setCloseBrowserBlock:^{
        
        [weakSelf closeAnimation];
    }];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

@end
