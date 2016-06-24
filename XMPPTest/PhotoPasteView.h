//
//  PhotoPasteView.h
//  XMPPTest
//
//  Created by huxinguang on 16/6/24.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChooseBlock)(BOOL);

@interface PhotoPasteView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *pasteImg;

@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@property (nonatomic ,copy) ChooseBlock chooseBlock;



@end
