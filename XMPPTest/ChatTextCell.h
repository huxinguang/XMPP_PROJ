//
//  ChatTextCell.h
//  XMPPTest
//
//  Created by huxinguang on 16/5/10.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatModel.h"
#import "ShapedPhotoView.h"
@interface ChatTextCell : UITableViewCell

@property (nonatomic ,strong)UIButton *iconBtn;
@property (nonatomic ,strong)UIImageView *bgImgView;
@property (nonatomic ,strong)UILabel *messageLabel;
@property (nonatomic ,strong)UIImageView *voiceImg;
@property (nonatomic ,strong)UILabel *voiceTimeLabel;
@property (nonatomic ,strong)UILabel *timeLabel;
@property (nonatomic ,strong)ShapedPhotoView *photoMsgView;
@property (nonatomic ,strong)ChatModel *cm;
- (void)configCellWithModel:(ChatModel *)model;

@end
