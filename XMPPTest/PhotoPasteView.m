//
//  PhotoPasteView.m
//  XMPPTest
//
//  Created by huxinguang on 16/6/24.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import "PhotoPasteView.h"

@implementation PhotoPasteView

- (IBAction)cancelAction:(UIButton *)sender {
    self.chooseBlock(NO);
}

- (IBAction)sendAction:(UIButton *)sender {
    self.chooseBlock(YES);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
