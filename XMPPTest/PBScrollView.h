
#import <UIKit/UIKit.h>

@interface PBScrollView : UIScrollView

@property (nonatomic,assign) NSUInteger index;


/** 照片数组 */
@property (nonatomic,strong) NSArray *photoModels;
@property (nonatomic,assign) BOOL isScrollToIndex;


@end
