//
//  ChatTextCell.h
//  XMPPTest
//
//  Created by huxinguang on 16/5/10.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatModel.h"
#import "ShapedPhotoButtton.h"
@interface ChatTextCell : UITableViewCell

@property (nonatomic ,strong)UIButton *iconBtn;
@property (nonatomic ,strong)UIImageView *bgImgView;
@property (nonatomic ,strong)UILabel *messageLabel;
@property (nonatomic ,strong)UIImageView *voiceImg;
@property (nonatomic ,strong)ShapedPhotoButtton *photoMsgBtn;
- (void)configCellWithModel:(ChatModel *)model;

@end
