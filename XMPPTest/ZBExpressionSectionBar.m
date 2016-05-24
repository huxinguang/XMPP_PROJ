//
//  ZBExpressionSectionBar.m
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-13.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import "ZBExpressionSectionBar.h"

@implementation ZBExpressionSectionBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:255.0f/255 green:250.0f/255 blue:240.0f/255 alpha:1];
        [self createSubViews];
    }
    return self;
}


-(void)createSubViews{

    UIButton *sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width-50, 0, 50, self.frame.size.height)];
    sendBtn.backgroundColor = Color(21, 126, 251);
    sendBtn.titleLabel.font = DefaultFont(16);
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendBtn];
    
}

- (void)sendMessage{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SendMessageNotification" object:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
