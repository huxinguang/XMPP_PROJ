

#import "PBScrollView.h"
#import "UIView+Extend.h"
#import "PBConst.h"
#import "PhotoItemView.h"

@interface PBScrollView ()

@end

@implementation PBScrollView






-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    __block CGRect frame = self.bounds;

    CGFloat w = frame.size.width ;

    frame.size.width =w - PBMargin;
    
        [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([obj isKindOfClass:[PhotoItemView class]])
            {
                PhotoItemView *photoItemView = obj;
                CGFloat x;
                @try {
                    if(photoItemView.pageIndex >100)
                    {
                        x =0;
                    }
                    else
                    {
                        x = w * photoItemView.pageIndex;
                    }
                    
                }
                @catch (NSException *exception) {
                
                }
                @finally {
                    
                };
                
                
                frame.origin.x = x;
                photoItemView.frame = frame;
            }
        }];
    
        

    
    
    if(_isScrollToIndex){
        
        //显示第index张图
        CGFloat offsetX = w * _index;
        [self setContentOffset:CGPointMake(offsetX, 0) animated:NO];
        
        _isScrollToIndex = NO;
    }
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
}



-(void)setPhotoModels:(NSArray *)photoModels{
    
    _photoModels = photoModels;
}




@end
