//
//  ShapedPhotoButtton.m
//  XMPPTest
//
//  Created by huxinguang on 16/5/27.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import "ShapedPhotoView.h"

@implementation ShapedPhotoView

- (void)configWithShapeLayerContentImage:(UIImage *)shapeImg subLayerContentImage:(UIImage *)subImg
{
    self.contentImage = subImg;
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
    }
    _shapeLayer.fillColor = [UIColor blackColor].CGColor;
    _shapeLayer.strokeColor = [UIColor clearColor].CGColor;
    _shapeLayer.frame = self.bounds;
    _shapeLayer.contentsCenter = CGRectMake(0.5, 0.75, 0.1, 0.1);//注意CALayer的contentsCenter属性的单位是比例（而不是绝对坐标）,https://www.mgenware.com/blog/?p=489
    _shapeLayer.contentsScale = [UIScreen mainScreen].scale;  //非常关键设置自动拉伸的效果且不变形
    _shapeLayer.contents = (id)shapeImg.CGImage;
    
    if (!_subLayer) {
        _subLayer = [CALayer layer];
    }
    _subLayer.mask = _shapeLayer;
    _subLayer.contents = (id)subImg.CGImage;
    _subLayer.frame = self.bounds;
    if (_subLayer) {
        [_subLayer removeFromSuperlayer];
    }
    [self.layer addSublayer:_subLayer];
    
}

@end
