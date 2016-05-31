
#import <UIKit/UIKit.h>
#import "PhotoModel.h"
#import "PhotoItemView.h"
#import "ShapedPhotoView.h"

@interface PhotoBroswerVC : UIViewController<UINavigationControllerDelegate>

/** 当前显示中的itemView */
@property (nonatomic,weak) PhotoItemView *currentItemView;

@property(nonatomic,weak)ShapedPhotoView *spv;


+(void)show:(UIViewController *)vc index:(NSUInteger)index andView:(ShapedPhotoView*)clickedPhotoView photoModelBlock:(NSArray *(^)())photoModelBlock;


@end
