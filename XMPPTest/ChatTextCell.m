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
#define  MessageMaxWidth (ScreenWidth - 10*6 - 40*2)

@interface ChatTextCell ()

@end


@implementation ChatTextCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //根据不同的cell类型添加子视图
        
        if ([reuseIdentifier isEqualToString:@"RichTextCellIdentifier"]) {
            
            _iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.contentView addSubview:_iconBtn];
            
            _bgImgView = [[UIImageView alloc]init];
            [self.contentView addSubview:_bgImgView];
            
            _messageLabel = [[UILabel alloc]init];
            _messageLabel.font = MessageFont;
            _messageLabel.numberOfLines = 0;
            _messageLabel.lineBreakMode=NSLineBreakByWordWrapping;
            [self.contentView addSubview:_messageLabel];
            
        }
        else if ([reuseIdentifier isEqualToString:@"PhotoCellIdentifier"])
        {
            _iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.contentView addSubview:_iconBtn];
            
            _photoMsgView = [[ShapedPhotoView alloc]init];
            _photoMsgView.userInteractionEnabled = YES;
            [self.contentView addSubview:_photoMsgView];
        
        }
        else if ([reuseIdentifier isEqualToString:@"EmotionImageCellIdentifier"])
        {
        
            
        }
        else if ([reuseIdentifier isEqualToString:@"VoiceCellIdentifier"])
        {
            _iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.contentView addSubview:_iconBtn];
            
            _bgImgView = [[UIImageView alloc]init];
            [self.contentView addSubview:_bgImgView];
            _bgImgView.userInteractionEnabled = YES;
            
            _voiceImg = [[UIImageView alloc]init];
            [self.contentView addSubview:_voiceImg];
            
            _voiceTimeLabel = [[UILabel alloc]init];
            _voiceTimeLabel.font = DefaultFont(15);
            _voiceTimeLabel.textColor = [UIColor grayColor];
            [self.contentView addSubview:_voiceTimeLabel];
            
        }
        else
        {
            
        
        }
        
        
        
        
        
        
        
        
    }
    
    return self;
}

- (void)configCellWithModel:(ChatModel *)model{
    
    self.cm = model;
    
    switch (model.msgType) {
        case MessageTypeRichText:
        {
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
                
                //气 泡拉伸，设置图片
                UIImage *img = [UIImage imageNamed:@"chat_dialog_others"];
                img = [img resizableImageWithCapInsets:(UIEdgeInsetsMake(img.size.height*0.8,img.size.width*0.5,img.size.height*0.2,img.size.width*0.5))];
                _bgImgView.image = img;
                
                //设置消息文本frame
                _messageLabel.frame = CGRectMake(Padding+40+20+3 , MessageTopOffset, labelSize.width, labelSize.height);
                _messageLabel.attributedText = model.message;
            }
            
        }
            break;
        case MessageTypePhoto:
        {
            if (model.chatCellOwner == ChatCellOwnerMe) {
                //设置头像frame
                _iconBtn.frame = CGRectMake(ScreenWidth-40-Padding, OffsetY, 40, 40);
                [_iconBtn sd_setImageWithURL:[NSURL URLWithString:model.iconUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@""]];
                
                if (_photoMsgView.subLayer) {
                    [_photoMsgView.subLayer.mask removeFromSuperlayer];
                    _photoMsgView.subLayer.mask = nil;
                    [_photoMsgView.subLayer removeFromSuperlayer];
                    _photoMsgView.subLayer = nil;
                }
                
                UIImage *shapeImg = [UIImage imageNamed:@"chat_dialog_me_male"];
                UIImage *subImg = model.photo;
                CGFloat w = subImg.size.width;
                CGFloat h = subImg.size.height;
                _photoMsgView.frame = CGRectMake(ScreenWidth - Padding - 40 - 150*w/h, OffsetY, 150*w/h, 150);
                [_photoMsgView configWithShapeLayerContentImage:shapeImg subLayerContentImage:subImg];
                
                
            }else{
                //设置头像frame
                _iconBtn.frame = CGRectMake(Padding, OffsetY, 40, 40);
                [_iconBtn sd_setImageWithURL:[NSURL URLWithString:model.iconUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@""]];
                
                if (_photoMsgView.subLayer) {
                    [_photoMsgView.subLayer.mask removeFromSuperlayer];
                    _photoMsgView.subLayer.mask = nil;
                    [_photoMsgView.subLayer removeFromSuperlayer];
                    _photoMsgView.subLayer = nil;
                }
                
                UIImage *shapeImg = [UIImage imageNamed:@"chat_dialog_others"];
                UIImage *subImg = model.photo;
                CGFloat w = subImg.size.width;
                CGFloat h = subImg.size.height;
                _photoMsgView.frame = CGRectMake(Padding + 40 , OffsetY, 150*w/h, 150);
                [_photoMsgView configWithShapeLayerContentImage:shapeImg subLayerContentImage:subImg];
            
            }
            
            
        }
            break;
        case MessageTypeEmotionImage:
        {
            
        }
            break;
        case MessageTypeVoice:
        {
            if (model.chatCellOwner == ChatCellOwnerMe) {
                //设置头像frame
                _iconBtn.frame = CGRectMake(ScreenWidth-40-Padding, OffsetY, 40, 40);
                [_iconBtn sd_setImageWithURL:[NSURL URLWithString:model.iconUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@""]];
                
                //设置气泡frame
                CGFloat bubbleWidth = (MessageMaxWidth-66)*(self.cm.voiceTime/60.0)+66;
                _bgImgView.frame = CGRectMake(ScreenWidth-Padding-40-(bubbleWidth), MessageBgTopOffset, bubbleWidth, 45);

                //气泡拉伸，设置图片
                UIImage *img = [UIImage imageNamed:@"chat_dialog_me_male"];
                img = [img resizableImageWithCapInsets:(UIEdgeInsetsMake(img.size.height * 0.8, img.size.width * 0.5, img.size.height * 0.2, img.size.width * 0.5))];
                _bgImgView.image = img;
                
                _voiceImg.image = [UIImage imageNamed:@"chat_animation_white3"];
                
                NSMutableArray *imgArr = [NSMutableArray array];
                for (int i = 0; i < 3; i ++) {
                    UIImage *animationImg = [UIImage imageNamed:[NSString stringWithFormat:@"chat_animation_white%d",i+1]];
                    [imgArr addObject:animationImg];
                }
                _voiceImg.animationImages = imgArr;
                _voiceImg.animationDuration = 1.5;
                
                _voiceImg.frame = CGRectMake(_bgImgView.right-25-18, _bgImgView.top + 11, 18, 22);
                
                _voiceTimeLabel.textAlignment = NSTextAlignmentRight;
                _voiceTimeLabel.text = [NSString stringWithFormat:@"%d''",(int)self.cm.voiceTime];
                _voiceTimeLabel.frame = CGRectMake(_bgImgView.left-50, _bgImgView.bottom-30, 45, 20);
                
                
            }else{
                //设置头像frame
                _iconBtn.frame = CGRectMake(Padding, OffsetY, 40, 40);
                [_iconBtn sd_setImageWithURL:[NSURL URLWithString:model.iconUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@""]];
                
                //设置气泡frame
                CGFloat bubbleWidth = (MessageMaxWidth-66)*(self.cm.voiceTime/60.0)+66;
                _bgImgView.frame = CGRectMake(Padding+40, MessageBgTopOffset, bubbleWidth, 45);

                //气泡拉伸，设置图片
                UIImage *img = [UIImage imageNamed:@"chat_dialog_others"];
                img = [img resizableImageWithCapInsets:(UIEdgeInsetsMake(img.size.height*0.8,img.size.width*0.5,img.size.height*0.2,img.size.width*0.5))];
                _bgImgView.image = img;
                
                
                _voiceImg.image = [UIImage imageNamed:@"chat_animation3"];
                
                NSMutableArray *imgArr = [NSMutableArray array];
                for (int i = 0; i < 3; i ++) {
                    UIImage *animationImg = [UIImage imageNamed:[NSString stringWithFormat:@"chat_animation%d",i+1]];
                    [imgArr addObject:animationImg];
                }
                _voiceImg.animationImages = imgArr;
                _voiceImg.animationDuration = 1.5;
                
                _voiceImg.frame  =CGRectMake(_bgImgView.left + 20 , _bgImgView.top +11, 18, 22);
                
                _voiceTimeLabel.textAlignment = NSTextAlignmentLeft;
                _voiceTimeLabel.text = [NSString stringWithFormat:@"%d''",(int)self.cm.voiceTime];
                _voiceTimeLabel.frame = CGRectMake(_bgImgView.right+2, _bgImgView.bottom-30, 45, 20);
                
            
            }
            
        }
            break;
            
        default:
            break;
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
