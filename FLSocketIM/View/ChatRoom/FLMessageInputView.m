//
//  FLMessageInputView.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/11.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLMessageInputView.h"
#import "FLPlaceholderTextView.h"

#define kKeyboardView_Height 216.0
#define kMessageInputView_Height 50.0
#define kMessageInputView_HeightMax 120.0
#define kMessageInputView_PadingHeight 7.0
#define kMessageInputView_Width_Tool 35.0
#define kMessageInputView_MediaPadding 1.0

@interface FLMessageInputView ()

@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) UIButton *arrowKeyboardButton;
@property (nonatomic, strong) UIButton *emotionButton;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) FLPlaceholderTextView *inputTextView;

@property (nonatomic, assign) CGFloat viewHeightOld;

@end
@implementation FLMessageInputView


#pragma mark - LifeCircle
- (void)dealloc {
    [FLNotificationCenter removeObserver:self];
    [self.inputTextView removeObserver:self forKeyPath:@"contentSize"];
}
- (instancetype)init {
    if (self = [super initWithFrame:CGRectMake(0, kScreenHeight - kMessageInputView_Height, kScreenWidth, kMessageInputView_Height)]) {
        
        [self setupUI];
        _viewHeightOld = self.height;
        [FLNotificationCenter addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        [self.inputTextView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = FLNavBGColor;
    
    // topLine
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
    line.backgroundColor = [UIColor colorWithHex:0xD8DDE4];
    [self addSubview:line];
    
    // voiceButton
    _voiceButton = [[UIButton alloc] initWithFrame:CGRectMake(7, (kMessageInputView_Height - kMessageInputView_Width_Tool)/2, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool)];
    
    [_voiceButton setImage:[UIImage imageNamed:@"keyboard_voice"] forState:UIControlStateNormal];
    [_voiceButton addTarget:self action:@selector(voiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_voiceButton];
    
    // emotionButton
    _emotionButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 15.0/2 - 2 * kMessageInputView_Width_Tool, (kMessageInputView_Height - kMessageInputView_Width_Tool)/2, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool)];
    [_emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
    [_emotionButton addTarget:self action:@selector(emotionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_emotionButton];
    
    // addButton
    _addButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 15.0/2 -kMessageInputView_Width_Tool, (kMessageInputView_Height - kMessageInputView_Width_Tool)/2, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool)];
    [_addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
    [_addButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_addButton];
    
    // arrowKeyboardButton
    _arrowKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _arrowKeyboardButton.frame = CGRectMake(0, 0, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool);
    [_arrowKeyboardButton setImage:[UIImage imageNamed:@"keyboard_arrow_down"] forState:UIControlStateNormal];
    [_arrowKeyboardButton addTarget:self action:@selector(arrowButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_arrowKeyboardButton];
    _arrowKeyboardButton.hidden = YES;
    
    
    // contentView
     CGFloat contentViewHeight = kMessageInputView_Height -2*kMessageInputView_PadingHeight;
    _contentView = [[UIScrollView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.layer.borderWidth = 0.5;
    _contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _contentView.layer.cornerRadius = contentViewHeight/2;
    _contentView.layer.masksToBounds = YES;
    _contentView.alwaysBounceVertical = YES;
    [self addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat left = 7+kMessageInputView_Width_Tool+7;
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(kMessageInputView_PadingHeight, left, kMessageInputView_PadingHeight, 15 + 2 *kMessageInputView_Width_Tool));
    }];
    // inputTextView
    _inputTextView = [[FLPlaceholderTextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 15 - 2 *kMessageInputView_Width_Tool - (7+kMessageInputView_Width_Tool+7), contentViewHeight)];
    _inputTextView.font = [UIFont systemFontOfSize:16];
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.scrollsToTop = NO;
    _inputTextView.delegate = self;
    
    //输入框缩进
    UIEdgeInsets insets = _inputTextView.textContainerInset;
    insets.left += 8.0;
    insets.right += 8.0;
    _inputTextView.textContainerInset = insets;
    
    [self.contentView addSubview:_inputTextView];
}
#pragma mark - Private

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([object isEqual:self.inputTextView]) {
        [self changContentViewHeight];
    }
    
}
- (void)setFrame:(CGRect)frame {
    
    CGFloat oldHeightToBottom = kScreenHeight - self.y;
    CGFloat newHeightToBottom = kScreenHeight - frame.origin.y;
    [super setFrame:frame];
    if (fabs(oldHeightToBottom - newHeightToBottom) > 0.1) {
        
    }
    if (self.delegate && [_delegate respondsToSelector:@selector(messageInputView:heightToBottomChange:)]) {
        
        [_delegate messageInputView:self heightToBottomChange:newHeightToBottom];
    }
}

- (void)sendText {
    
    NSString *sendText = _inputTextView.text;
    _inputTextView.text = @"";
//    [self changContentViewHeight];
    if (_delegate && [_delegate respondsToSelector:@selector(messageInputView:sendText:)] && sendText.length) {
        [_delegate messageInputView:self sendText:sendText];
    }
}

- (void)changContentViewHeight {
    
    CGSize textSize = _inputTextView.contentSize;
    if (ABS(_inputTextView.height - textSize.height) > 0.5) {
        
        _inputTextView.height = textSize.height;
    }
    else {
        return;
    }
    CGSize contentSize = textSize;
    CGFloat selfHeight = MAX(kMessageInputView_Height, contentSize.height + 2 * kMessageInputView_PadingHeight);
    
    CGFloat maxSelfHeight = kScreenHeight/3.0f;
    selfHeight = MIN(maxSelfHeight, selfHeight);
    CGFloat diffHeight = selfHeight - _viewHeightOld;
    if (ABS(diffHeight) > 0.5) {
        CGRect selfFrame = self.frame;
        selfFrame.size.height += diffHeight;
        selfFrame.origin.y -= diffHeight;
        self.frame = selfFrame;
        _viewHeightOld = selfHeight;
    }
    self.contentView.contentSize = contentSize;
    CGFloat bottomY = textSize.height;
    CGFloat offsetY = MAX(0, bottomY - self.height - 2 * kMessageInputView_PadingHeight);
    [self.contentView setContentOffset:CGPointMake(0, offsetY) animated:YES];
}
#pragma mark - ButtonAction
- (void)emotionButtonClicked:(UIButton *)sender {
    [[FLSocketManager shareManager].client disconnect];
}
- (void)voiceButtonClicked:(UIButton *)sender {
    [[FLSocketManager shareManager].client connect];
}
- (void)addButtonClicked:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(messageInputViewSendImage)]) {
        [_delegate messageInputViewSendImage];
    }
}
#pragma mark - KeyBoard Notification Handle
- (void)keyboardChange:(NSNotification*)aNotification {
    
    NSDictionary *userInfo = [aNotification userInfo];
    CGRect keyBoardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardY = keyBoardEndFrame.origin.y;
    CGFloat selfOriginY = keyboardY - self.height;
    if (selfOriginY == self.y) {
        return;
    }
    
    
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve anmationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    [UIView animateWithDuration:animationDuration delay:0 options:[UIView animationOptionsForCurve:anmationCurve] animations:^{
        
        self.y = selfOriginY;
    } completion:nil];
}
#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self sendText];
        return NO;
    }
    
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
    
//    [self changContentViewHeight];
}
@end
