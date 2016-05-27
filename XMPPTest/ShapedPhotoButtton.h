//
//  ShapedPhotoButtton.h
//  XMPPTest
//
//  Created by huxinguang on 16/5/27.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShapedPhotoButtton : UIButton

@property (nonatomic ,strong)CALayer *subLayer;
@property (nonatomic ,strong)CAShapeLayer *shapeLayer;

- (void)configWithShapeLayerContentImage:(UIImage *)shapeImg subLayerContentImage:(UIImage *)subImg;

@end
