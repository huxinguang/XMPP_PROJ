//

#import <UIKit/UIKit.h>

@interface PhotoImageView : UIImageView

/** 设置图片后的回调 */
@property (nonatomic,copy) void (^ImageSetBlock)(UIImage *image);



@end
