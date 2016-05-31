//
//  PhotoBrowseEnterAnimation.h
//  XMPPTest
//
//  Created by huxinguang on 16/5/31.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShapedPhotoView.h"
@interface PhotoBrowseEnterAnimation : NSObject<UIViewControllerAnimatedTransitioning>//点击消息图片进入浏览界面的动画

@property(nonatomic,strong)ShapedPhotoView *clickedPhotoView;

@end
