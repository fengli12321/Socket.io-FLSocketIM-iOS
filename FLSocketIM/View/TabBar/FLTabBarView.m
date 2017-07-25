//
//  FLTabBarView.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/25.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLTabBarView.h"
#import "FLTabBarMessageItemView.h"
#import "FLTabBarContactsItemView.h"
#import "FLTabBarDynamicItemView.h"

@interface FLTabBarView ()

@property (nonatomic, strong) FLTabBarMessageItemView *messageView;
@property (nonatomic, strong) FLTabBarContactsItemView *contactsView;
@property (nonatomic, strong) FLTabBarDynamicItemView *dynamicView;

@end
@implementation FLTabBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self setupItem];
    }
    return self;
}

- (void)setupItem {
    
    self.messageView = [[FLTabBarMessageItemView alloc] initWithOrientation:FLSelected title:@"消息" type:FLTabBarMessage];
    self.messageView.tag = 0;
    [self addSubview:self.messageView];
    
    [self.messageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.bottom.top.equalTo(self);
//        make.width.greaterThanOrEqualTo(0);

    }];
    
    UITapGestureRecognizer *tapA = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapView:)];
    [self.messageView addGestureRecognizer:tapA];
    
    self.contactsView = [[FLTabBarContactsItemView alloc] initWithOrientation:FLLeft title:@"联系人" type:FLTabBarContacts];
    self.contactsView.tag = 1;
    [self addSubview:self.contactsView];
    [self.contactsView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.messageView.mas_right);
        make.top.bottom.equalTo(self);
        make.width.equalTo(self.messageView);
    }];
    
    UITapGestureRecognizer *tapB = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapView:)];
    [self.contactsView addGestureRecognizer:tapB];
    
    self.dynamicView = [[FLTabBarDynamicItemView alloc] initWithOrientation:FLLeft title:@"我的" type:FLTabBarDynamic];
    self.dynamicView.tag = 2;
    [self addSubview:self.dynamicView];
    [self.dynamicView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contactsView.mas_right);
        make.top.bottom.right.equalTo(self);
        make.width.equalTo(self.contactsView);
    }];
    UITapGestureRecognizer *tapC = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapView:)];
    [self.dynamicView addGestureRecognizer:tapC];
}

- (void)didTapView:(UITapGestureRecognizer *)tap {
    
    UIView *view = tap.view;
    FLTabBarItemView *tapView;
    if ([view isKindOfClass:[FLTabBarItemView class]]) {
        tapView = (FLTabBarItemView *)view;
    }
    else {
        return;
    }
    if (tapView.orientation == FLSelected) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(fl_tabBarView:shoulSelectItemAtIndex:)]) {
        
        BOOL should = [_delegate fl_tabBarView:self shoulSelectItemAtIndex:tapView.tag];
        if (!should) {
            return;
        }
    }
    
    if ([tapView isEqual:self.messageView]) {
        self.contactsView.orientation = FLLeft;
        self.dynamicView.orientation = FLLeft;
    }
    else if ([tapView isEqual:self.contactsView]) {
        self.messageView.orientation = FLRight;
        self.dynamicView.orientation = FLLeft;
    }
    else if ([tapView isEqual:self.dynamicView]) {
        self.messageView.orientation = FLRight;
        self.contactsView.orientation = FLRight;
    }
    
    tapView.orientation = FLSelected;
    if (_delegate && [_delegate respondsToSelector:@selector(fl_tabBarView:didSelectItemAtIndex:)]) {
        [_delegate fl_tabBarView:self didSelectItemAtIndex:tapView.tag];
    }
}

@end
