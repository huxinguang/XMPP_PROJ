//
//  PhotoScrollView.h
//  XMPPTest
//
//  Created by huxinguang on 16/6/1.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoScrollView : UIScrollView

@property (nonatomic,strong) NSArray *photoModels;
@property (nonatomic,assign) NSUInteger index;
@property (nonatomic,assign) BOOL isScrollToIndex;

@end
