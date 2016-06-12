//
//  ChatModel.h
//  XMPPTest
//
//  Created by huxinguang on 16/5/9.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,ChatCellOwner) {
    ChatCellOwnerMe,
    ChatCellOwnerOther
};

typedef NS_ENUM(NSInteger,MessageType) {
    MessageTypeRichText,//包括纯文字，纯表情，文字表情混合
    MessageTypePhoto,//相册照片、拍照
    MessageTypeEmotionImage,//表情图片（大）
    MessageTypeVoice//语音
};


@interface ChatModel : NSObject
//Common
@property (nonatomic ,assign)ChatCellOwner chatCellOwner;
@property (nonatomic ,assign)MessageType msgType;
@property (nonatomic ,strong)NSString *iconUrl;
@property (nonatomic ,assign)CGFloat cellHeight;
//RichText
@property (nonatomic ,strong)NSMutableAttributedString *message;
@property (nonatomic ,assign)CGSize messageLabelSize;
@property (nonatomic ,assign)BOOL isSingleLine;
@property (nonatomic ,assign)CGFloat messageMinHeight;
//Photo
@property (nonatomic ,strong)UIImage *photo;

@property (nonatomic ,strong)NSData *data;
@property (nonatomic ,assign)int timeLength;

@property (nonatomic ,assign)float voiceTime;






@end
