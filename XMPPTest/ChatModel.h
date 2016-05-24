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

@interface ChatModel : NSObject


@property (nonatomic ,assign)ChatCellOwner chatCellOwner;
@property (nonatomic ,strong)NSString *iconUrl;
@property (nonatomic ,strong)NSMutableAttributedString *message;
@property (nonatomic ,assign)CGSize messageLabelSize;
@property (nonatomic ,assign)BOOL isSingleLine;
@property (nonatomic ,assign)CGFloat messageMinHeight;
@end
