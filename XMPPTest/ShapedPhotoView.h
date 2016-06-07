//
//  ShapedPhotoButtton.h
//  XMPPTest
//
//  Created by huxinguang on 16/5/27.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShapedPhotoView : UIImageView

@property (nonatomic ,strong)CALayer *subLayer;
@property (nonatomic ,strong)CAShapeLayer *shapeLayer;
@property (nonatomic ,strong)UIImage *contentImage;
@property (nonatomic ,strong)UIImage *shapeImage;

- (void)configWithShapeLayerContentImage:(UIImage *)shapeImg subLayerContentImage:(UIImage *)subImg;

@end
