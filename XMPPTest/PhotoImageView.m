

#import "PhotoImageView.h"
#import "PBConst.h"

@interface PhotoImageView ()

/** bounds */
@property (nonatomic,assign) CGRect screenBounds;

/** center*/
@property (nonatomic,assign) CGPoint screenCenter;

@end


@implementation PhotoImageView


-(void)setImage:(UIImage *)image{
    
    if(image == nil) return;
    [super setImage:image];
    
//    @try {
//        if ([image isKindOfClass:[FLAnimatedImage class]]) {
//            [super setAnimatedImage:(FLAnimatedImage *)image];
//        } else {
//            [super setImage:image];
//        }
//    }
//    @catch (NSException *exception) {
//        
//    }
//    @finally {
//        
//    }
    
    //确定frame
    [self calFrame];
    
//    if(_ImageSetBlock != nil) _ImageSetBlock(image);
}

//-(void)setImage:(UIImage *)image{
//    
//    if(image == nil) return;
//    
//    @try {
//        [super setImage:image];
//    }
//    @catch (NSException *exception) {
//        
//    }
//    @finally {
//        
//    }
//    
//    //确定frame
//    [self calFrame];
//    
//    Dlog(@"图片size。height＝%f",image.size.height);
//    Dlog(@"图片size。height＝%f",self.frame.size.height);
//    
//    if(_ImageSetBlock != nil) _ImageSetBlock(image);
//}



/*
 *  确定frame
 */
-(void)calFrame{
    
    CGSize size = self.image.size;
    
    CGFloat w = size.width;
    CGFloat h = size.height;
    
//    if ((w<=0)||(h<=0))
//    {
//        return;
//    }
    
    CGRect superFrame = self.screenBounds;
    CGFloat superW =superFrame.size.width ;
    CGFloat superH =superFrame.size.height;
    
    CGFloat calW = superW;
    CGFloat calH = superW;
    
    if (w>=h) {//较宽
        
        if(w> superW){//比屏幕宽
            
            CGFloat scale = superW / w;
            
            //确定宽度
            calW = w * scale;
            calH = h * scale;
            
        }else if(w <= superW){//比屏幕窄，直接居中显示

            float sc = superW/w;
            calW = superW;
            calH = h *sc;
        }
        
    }else if(w<h){//较高
        
        CGFloat scale1 = superH / h;
        CGFloat scale2 = superW / w;
        
        BOOL isFat = w * scale1 > superW;//比较胖
        
        CGFloat scale =isFat ? scale1 : scale2;
 
        if(h> superH){//比屏幕高
            
            //确定宽度
            calW = w * scale;
            calH = h * scale;
            
            if(w >= superW)
            {
                calW = superW;
                calH = h * superW/w;
            }
            
            if(calH < superH)
            {
                self.frame =CGRectMake(0,(superH - calH)/2,calW,calH) ;
            }
            else
            {
                self.frame = CGRectMake(0, 0, calW, calH);
            }
            return;

        }else if(h <= superH){//比屏幕窄，直接居中显示
            
            if(w>superW){
                
                CGFloat scaleW = superW /w;
                calW = superW;
                calH = h *scaleW;
                
            }else{
                float sc = superW/w;
                
                calW = superW;
                calH = h * sc;
            }
            
        }
    }
    
    CGRect frame = [self frameWithW:floor(calW) h:floorf(calH) center:self.screenCenter];
    
    self.frame = frame;
}


/*
 *  计算frame
 */
-(CGRect)frameWithW:(CGFloat)w h:(CGFloat)h center:(CGPoint)center{
    
    CGFloat x = center.x - w *.5f;
    CGFloat y = center.y - h * .5f;
    
    if(y<0) y=0;
    
    CGRect frame = (CGRect){CGPointMake(x, y),CGSizeMake(w, h)};
    
    return frame;
}


-(CGRect)screenBounds{
    
    if(CGRectEqualToRect(_screenBounds, CGRectZero)){
        
        _screenBounds = [UIScreen mainScreen].bounds;
    }
    
    return _screenBounds;
}

-(CGPoint)screenCenter{
    if(CGPointEqualToPoint(_screenCenter, CGPointZero)){
        CGSize size = self.screenBounds.size;
        _screenCenter = CGPointMake(size.width * .5f, size.height * .5f);
    }

    return _screenCenter;
}



@end
