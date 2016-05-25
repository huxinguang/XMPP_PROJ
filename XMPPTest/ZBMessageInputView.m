//
//  ZBMessageInputView.m
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-10.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import "ZBMessageInputView.h"
#import "NSString+Message.h"

#define  InputViewHeight 50

@interface ZBMessageInputView()<UITextViewDelegate>

@property (nonatomic, copy) NSString *inputedText;

@end

@implementation ZBMessageInputView

- (void)dealloc{
    _messageInputTextView.delegate = nil;
    _messageInputTextView = nil;
    
    _voiceChangeButton = nil;
    _multiMediaSendButton = nil;
    _faceSendButton = nil;
    _holdDownButton = nil;

}

#pragma mark - Action

- (void)messageStyleButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
        {
            self.faceSendButton.selected = NO;
            self.multiMediaSendButton.selected = NO;
            sender.selected = !sender.selected;
            
            if (sender.selected){
                NSLog(@"声音被点击的");
                [self.messageInputTextView resignFirstResponder];
                
            }else{
                NSLog(@"声音被点击结束");
                [self.messageInputTextView becomeFirstResponder];
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
            } completion:^(BOOL finished) {
                self.holdDownButton.hidden = !sender.selected;
                self.messageInputTextView.hidden = sender.selected;
            }];
            

            if ([self.delegate respondsToSelector:@selector(didChangeSendVoiceAction:)]) {
                [self.delegate didChangeSendVoiceAction:!sender.selected];
            }
        }
            break;
        case 1:
        {
            self.multiMediaSendButton.selected = NO;
            self.voiceChangeButton.selected = NO;
            
            sender.selected = !sender.selected;
            if (sender.selected) {
                NSLog(@"表情被点击");
                [self.messageInputTextView resignFirstResponder];
            }else{
                NSLog(@"表情没被点击");
                [self.messageInputTextView becomeFirstResponder];
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.holdDownButton.hidden = YES;
                self.messageInputTextView.hidden = NO;
            } completion:^(BOOL finished) {
                
            }];
            
            if ([self.delegate respondsToSelector:@selector(didSendFaceAction:)]) {
                [self.delegate didSendFaceAction:sender.selected];
            }
        }
            break;
        case 2:
        {
            self.voiceChangeButton.selected = NO;
            self.faceSendButton.selected = NO;
            
            sender.selected = !sender.selected;
            if (sender.selected) {
                NSLog(@"分享被点击");
                [self.messageInputTextView resignFirstResponder];
            }else{
                NSLog(@"分享没被点击");
                [self.messageInputTextView becomeFirstResponder];
            }

            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.holdDownButton.hidden = YES;
                self.messageInputTextView.hidden = NO;
            } completion:^(BOOL finished) {
                
            }];
            
            if ([self.delegate respondsToSelector:@selector(didSelectedMultipleMediaAction:)]) {
                [self.delegate didSelectedMultipleMediaAction:sender.selected];
            }
        }
            break;
        default:
            break;
    }
}


#pragma mark -语音功能
- (void)holdDownButtonTouchDown {
    if ([self.delegate respondsToSelector:@selector(didStartRecordingVoiceAction)]) {
        [self.delegate didStartRecordingVoiceAction];
    }
}

- (void)holdDownButtonTouchUpOutside {
    if ([self.delegate respondsToSelector:@selector(didCancelRecordingVoiceAction)]) {
        [self.delegate didCancelRecordingVoiceAction];
    }
}

- (void)holdDownButtonTouchUpInside {
    if ([self.delegate respondsToSelector:@selector(didFinishRecoingVoiceAction)]) {
        [self.delegate didFinishRecoingVoiceAction];
    }
}

- (void)holdDownButtonTouchDragExit{
    if ([self.delegate respondsToSelector:@selector(didTouchDragExitAction)]) {
        [self.delegate didTouchDragExitAction];
    }
}

- (void)holdDownButtonTouchDragEnter{
    if ([self.delegate respondsToSelector:@selector(didTouchDragEnterAction)]) {
        [self.delegate didTouchDragEnterAction];
    }
}

#pragma end

#pragma mark - 添加控件
- (void)setupMessageInputViewBar{
    
    // 水平间隔
    CGFloat horizontalPadding = 6;
    
    // 垂直间隔
    CGFloat verticalPadding = 7;
    
    // 按钮长,宽
    CGFloat buttonSize = 36.0f;
    
    // 发送语音
    
    self.voiceChangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.voiceChangeButton setImage:Image(@"ToolViewInputVoice_ios7") forState:UIControlStateNormal];
    [self.voiceChangeButton setImage:Image(@"ToolViewKeyboard_ios7") forState:UIControlStateSelected];
    [self.voiceChangeButton addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.voiceChangeButton.tag = 0;
    [self addSubview:self.voiceChangeButton];
    
    [self.voiceChangeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(-(50/2-buttonSize/2));
        make.left.equalTo(self.mas_left).offset(horizontalPadding);
        make.size.mas_equalTo(CGSizeMake(buttonSize, buttonSize));
    }];
    
    
    
    // 允许发送多媒体消息，为什么不是先放表情按钮呢？因为布局的需要！
    self.multiMediaSendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.multiMediaSendButton setImage:Image(@"TypeSelectorBtn_Black_ios7") forState:UIControlStateNormal];
    [self.multiMediaSendButton setImage:Image(@"ToolViewKeyboard_ios7") forState:UIControlStateSelected];
    [self.multiMediaSendButton addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.multiMediaSendButton.tag = 2;
    [self addSubview:self.multiMediaSendButton];
    
    [self.multiMediaSendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(-(50/2-buttonSize/2));
        make.right.equalTo(self.mas_right).offset(-horizontalPadding);
        make.size.mas_equalTo(CGSizeMake(buttonSize, buttonSize));
    }];
    
    
    // 发送表情
    self.faceSendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.faceSendButton setImage:Image(@"ToolViewEmotion_ios7") forState:UIControlStateNormal];
    [self.faceSendButton setImage:[UIImage imageNamed:@"ToolViewKeyboard_ios7"] forState:UIControlStateSelected];
    [self.faceSendButton addTarget:self  action:@selector(messageStyleButtonClicked:)forControlEvents:UIControlEventTouchUpInside];
    self.faceSendButton.tag = 1;
    [self addSubview:self.faceSendButton];
    
    [self.faceSendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(-(50/2-buttonSize/2));
        make.right.equalTo(self.multiMediaSendButton.mas_left).offset(-horizontalPadding/2);
        make.size.mas_equalTo(CGSizeMake(buttonSize, buttonSize));
    }];
    
    
    // 如果是可以发送语言的，那就需要一个按钮录音的按钮，事件可以在外部添加
    self.holdDownButton = [[UIButton alloc]init];
    [self.holdDownButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    [self.holdDownButton setTitle:@"松开 结束" forState:UIControlStateHighlighted];
    self.holdDownButton.titleLabel.font = DefaultFont(16);
    self.holdDownButton.backgroundColor = Color(230, 230, 230);
    [self.holdDownButton setTitleColor:Color(83, 83, 83) forState:UIControlStateNormal];
    [self.holdDownButton setTitleColor:Color(183, 183, 183) forState:UIControlStateHighlighted];
    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchDragExit) forControlEvents:UIControlEventTouchDragExit];
    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchDragEnter) forControlEvents:UIControlEventTouchDragEnter];
    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.holdDownButton];
    self.holdDownButton.layer.cornerRadius = 5;
    self.holdDownButton.layer.borderColor = Color(183, 183, 183).CGColor;
    self.holdDownButton.layer.borderWidth = 0.5;
    self.holdDownButton.hidden = YES;
    
    [self.holdDownButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(-(50/2-32/2));
        make.left.equalTo(self.mas_left).offset(7.5+verticalPadding+buttonSize);
        make.right.equalTo(self.mas_right).offset(-(7.5 + 2*horizontalPadding + 2*buttonSize));
        make.size.height.mas_equalTo(32);
    }];
    
    // 初始化输入框
    self.messageInputTextView = [[ZBMessageTextView alloc]init];
    self.messageInputTextView.placeHolder = @"";
    self.messageInputTextView.delegate = self;
    [self addSubview:self.messageInputTextView];
    self.messageInputTextView.hidden = self.voiceChangeButton.selected;
    
    _messageInputTextView.backgroundColor = [UIColor clearColor];
    _messageInputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    _messageInputTextView.layer.borderWidth = 0.65f;
    _messageInputTextView.layer.cornerRadius = 6.0f;
    
    [self.messageInputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(50/2-32/2);
        make.bottom.equalTo(self.mas_bottom).offset(-(50/2-32/2));
        make.left.equalTo(self.mas_left).offset(7.5+horizontalPadding+buttonSize);
        make.right.equalTo(self.mas_right).offset(-(7.5 + 2*horizontalPadding + 2*buttonSize));
    }];

    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        [self setup];
    }
    return self;
}


#pragma mark - Message input view

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight {
    // 动态改变自身的高度和输入框的高度
    CGRect prevFrame = self.messageInputTextView.frame;
    
    NSUInteger numLines = MAX([self.messageInputTextView numberOfLinesOfText],
                              [self.messageInputTextView.text numberOfLines]);
    
    self.messageInputTextView.frame = CGRectMake(prevFrame.origin.x,
                                          prevFrame.origin.y,
                                          prevFrame.size.width,
                                          prevFrame.size.height + changeInHeight);
    
    
    self.messageInputTextView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f),
                                                       0.0f,
                                                       (numLines >= 6 ? 4.0f : 0.0f),
                                                       0.0f);
    
    // from iOS 7, the content size will be accurate only if the scrolling is enabled.
    self.messageInputTextView.scrollEnabled = YES;
    
    if (numLines >= 6) {
        CGPoint bottomOffset = CGPointMake(0.0f, self.messageInputTextView.contentSize.height - self.messageInputTextView.bounds.size.height);
        [self.messageInputTextView setContentOffset:bottomOffset animated:YES];
        [self.messageInputTextView scrollRangeToVisible:NSMakeRange(self.messageInputTextView.text.length - 2, 1)];
    }
}

+ (CGFloat)textViewLineHeight{
    return 36.0f ;// 字体大小为16
}

+ (CGFloat)maxHeight{
    return ([ZBMessageInputView maxLines] + 1.0f) * [ZBMessageInputView textViewLineHeight];
}

+ (CGFloat)maxLines{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 3.0f : 8.0f;
}
#pragma end

- (void)setup {
    UIImage *img = [UIImage imageNamed:@"input-bar-flat"];
    img = [img resizableImageWithCapInsets:(UIEdgeInsetsMake(img.size.height*0.5,img.size.width*0.5,img.size.height*0.5,img.size.width*0.5))];
    self.image = img;
    
    [self setupMessageInputViewBar];
}

#pragma mark - textViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
   
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)])
    {
        [self.delegate inputTextViewWillBeginEditing:self.messageInputTextView];
    }
    self.faceSendButton.selected = NO;
    self.multiMediaSendButton.selected = NO;
   
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidChange:)]) {
        [self.delegate inputTextViewDidChange:self.messageInputTextView];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
//    [textView becomeFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:self.messageInputTextView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendTextAction:)]) {
            [self.delegate didSendTextAction:self.messageInputTextView];
        }
        return NO;
    }
    return YES;
}
#pragma end

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
