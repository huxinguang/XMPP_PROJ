//
//  ChatTextCell.m
//  XMPPTest
//
//  Created by huxinguang on 16/5/10.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import "ChatTextCell.h"

#define Padding 8
#define OffsetY 8
#define MessageBgTopOffset 6
#define MessageTopOffset 19.5
#define  MessageFont [UIFont systemFontOfSize:15]

@interface ChatTextCell ()

@property (nonatomic ,strong)UIButton *iconBtn;
@property (nonatomic ,strong)UIImageView *bgImgView;
@property (nonatomic ,strong)UILabel *messageLabel;
@property (nonatomic ,strong)UIImageView *voiceImg;

@end


@implementation ChatTextCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_iconBtn];
        
        
        _bgImgView = [[UIImageView alloc]init];
        [self.contentView addSubview:_bgImgView];
        
        _messageLabel = [[UILabel alloc]init];
        _messageLabel.font = MessageFont;
        _messageLabel.numberOfLines = 0;
        _messageLabel.lineBreakMode=NSLineBreakByWordWrapping;
        [self.contentView addSubview:_messageLabel];
        
        _voiceImg = [[UIImageView alloc]init];
        [self.contentView addSubview:_voiceImg];
        _voiceImg.hidden = YES;
        
    }
    
    return self;
}

- (void)configCellWithModel:(ChatModel *)model{

    if (model.chatCellOwner == ChatCellOwnerMe) {
        
        //设置头像frame
        _iconBtn.frame = CGRectMake(ScreenWidth-40-Padding, OffsetY, 40, 40);
        [_iconBtn sd_setImageWithURL:[NSURL URLWithString:model.iconUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@""]];
        
        //设置气泡frame
        CGSize labelSize = model.messageLabelSize;
        if (model.isSingleLine) {
            _bgImgView.frame = CGRectMake(ScreenWidth-Padding-40-(labelSize.width+40), MessageBgTopOffset, labelSize.width+40, 45);
        }else{
            _bgImgView.frame = CGRectMake(ScreenWidth-Padding-40- (labelSize.width+40), MessageBgTopOffset, labelSize.width+40, labelSize.height+27);
        }
        //气泡拉伸，设置图片
        UIImage *img = [UIImage imageNamed:@"chat_dialog_me_male"];
        img = [img resizableImageWithCapInsets:(UIEdgeInsetsMake(img.size.height * 0.8, img.size.width * 0.5, img.size.height * 0.2, img.size.width * 0.5))];
        _bgImgView.image = img;
        
        //设置消息文本frame
        _messageLabel.frame = CGRectMake(ScreenWidth- Padding-40-20- 3 -labelSize.width, MessageTopOffset, labelSize.width, labelSize.height);
//        _messageLabel.text = model.message;
        _messageLabel.attributedText = model.message;
        
        
    }else{
        
        //设置头像frame
        _iconBtn.frame = CGRectMake(Padding, OffsetY, 40, 40);
        [_iconBtn sd_setImageWithURL:[NSURL URLWithString:model.iconUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@""]];
        
        //设置气泡frame
        CGSize labelSize = model.messageLabelSize;
        if (model.isSingleLine) {
            _bgImgView.frame = CGRectMake(Padding+40, MessageBgTopOffset, labelSize.width+40, 45);
        }else{
            _bgImgView.frame = CGRectMake(Padding+40, MessageBgTopOffset, labelSize.width+40, labelSize.height+27);
        }
        
        //气泡拉伸，设置图片
        UIImage *img = [UIImage imageNamed:@"chat_dialog_others"];
        img = [img resizableImageWithCapInsets:(UIEdgeInsetsMake(img.size.height*0.8,img.size.width*0.5,img.size.height*0.2,img.size.width*0.5))];
        _bgImgView.image = img;
        
        //设置消息文本frame
        _messageLabel.frame = CGRectMake(Padding+40+20+3 , MessageTopOffset, labelSize.width, labelSize.height);
//        _messageLabel.text = model.message;
        _messageLabel.attributedText = model.message;
    }

}





- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
