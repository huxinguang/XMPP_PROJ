

#import "PhotoItemView.h"
#import "UIView+Extend.h"
//#import "PhotoImageView.h"
#import "UIView+PBExtend.h"
#import "PBPGView.h"
#import "PBBlurImageView.h"
#import "PBConst.h"
#import "UIImage+Extend.h"




@interface PhotoItemView ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet PBPGView *progressView;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMarginC;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightMarginC;



/** view的单击 */
@property (nonatomic,strong) UITapGestureRecognizer *tap_single_viewGesture;

/** view的单击 */
@property (nonatomic,strong) UITapGestureRecognizer *tap_double_viewGesture;

/** imageView的双击 */
@property (nonatomic,strong) UITapGestureRecognizer *tap_double_imageViewGesture;

/** 旋转手势 */
@property (nonatomic,strong) UIRotationGestureRecognizer *rotaGesture;

/** 长按手势 */
@property(nonatomic,strong) UILongPressGestureRecognizer *longPressGestureRecognizer;








/** 展示照片的视图 */
//@property (nonatomic,strong) PhotoImageView *photoImageView;


/** 双击放大 */
@property (nonatomic,assign) BOOL isDoubleClickZoom;


@end


@implementation PhotoItemView


-(void)awakeFromNib{
    
    [super awakeFromNib];
    
    //数据准备
    [self dataPrepare];
    
    //添加手势
    [self addGestureRecognizer:self.tap_single_viewGesture];
    [self addGestureRecognizer:self.tap_double_viewGesture];
    [self addGestureRecognizer:self.tap_double_imageViewGesture];
    [self addGestureRecognizer:self.longPressGestureRecognizer];
    self.multipleTouchEnabled = NO;
    self.exclusiveTouch = YES;
    self.backgroundColor = Color(20, 20, 20);
}

-(void)setPhotoModel:(PhotoModel *)photoModel{
    
    _photoModel = photoModel;
    
    if(photoModel == nil) return;
    
    //数据准备
    [self dataPrepare];
}

/*
 *  数据准备
 */
-(void)dataPrepare{
    
    if(self.photoModel == nil) return;
    
    BOOL isNetWorkShow = _photoModel.photo == nil;
    
    if(isNetWorkShow){//网络请求
        
        /*
        
        NSString *urlStr = [_photoModel.image_HD_U stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        SDWebImageOptions options = SDWebImageLowPriority | SDWebImageRetryFailed;
        
        //创建imageView
        UIImage *imageCache = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[_photoModel.image_HD_U stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if([urlStr rangeOfString:@".gif"].location != NSNotFound)
        {
            NSData *data = [[SDImageCache sharedImageCache]diskImageDataBySearchingAllPathsForKey:urlStr];
            if (data)
            {
                imageCache = [FLAnimatedImage imageWithData:data];
            }
        }
        [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:imageCache options:options progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            _progressView.hidden = NO;
            
            if (receivedSize<=0)
            {
                receivedSize = 0.0f;
            }
            if (expectedSize<=0)
            {
                expectedSize = 1.0f;
            }
            CGFloat progress = receivedSize /((CGFloat)expectedSize);
            
            _progressView.progress = progress;
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            self.hasImage = image !=nil;
            
            if(image!=nil && _progressView.progress <1.0f) {
                _progressView.progress = 1.0f;
            }
            
            if([self calFrameWithImage:image].height>self.scrollView.contentSize.height)
            {
                CGSize size = self.scrollView.contentSize;
                size.height = [self calFrameWithImage:image].height;
                self.scrollView.contentSize = size;
            }
        }];
        
        
        
        */
        
        
//        [self.photoImageView imageWithUrlStr:[_photoModel.image_HD_U stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] phImage:imageCache progressBlock:^(NSInteger receivedSize, NSInteger expectedSize) {
//            
//            _progressView.hidden = NO;
//            
//            if (receivedSize<=0)
//            {
//                receivedSize = 0.0f;
//            }
//            if (expectedSize<=0)
//            {
//                expectedSize = 1.0f;
//            }
//            CGFloat progress = receivedSize /((CGFloat)expectedSize);
//            
//            _progressView.progress = progress;
//            
//        } completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            
//            self.hasImage = image !=nil;
//            
//            if(image!=nil && _progressView.progress <1.0f) {
//                _progressView.progress = 1.0f;
//            }
//            
//            if([self calFrameWithImage:image].height>self.scrollView.contentSize.height)
//            {
//                CGSize size = self.scrollView.contentSize;
//                size.height = [self calFrameWithImage:image].height;
//                self.scrollView.contentSize = size;
//            }
//        }];
    }else{
        
        self.photoImageView.image = _photoModel.photo;
        
        //标记
        self.hasImage = YES;
    }
    
    self.scrollView.contentSize = self.photoImageView.frame.size;
    
}


/*
 *  确定frame
 */
-(CGSize)calFrameWithImage:(UIImage*)image
{
    CGSize size = image.size;
    
    CGFloat w = size.width;
    CGFloat h = size.height;
    if ((w<=0)||(h<=0))
    {
        return CGSizeZero;
    }
    
    CGRect superFrame = [UIScreen mainScreen].bounds;
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
            
            //            calW = w;
            //            calH = h;
            
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
            
            if(w >=superW)
            {
                calW = superW;
                calH = h * superW/w;
            }
            
            if(calH < superH)
            {
                return CGSizeMake(calW, calH);
            }
            else
            {
                return CGSizeMake(calW, calH);
            }
            
            
        }else if(h <= superH){//比屏幕窄，直接居中显示
            
            if(w>superW){
                
                //确定宽度
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
    return CGSizeMake(calW, calH);
}


-(PhotoImageView *)photoImageView{
    
    if(_photoImageView == nil){
        
        _photoImageView = [[PhotoImageView alloc] init];
        
        _photoImageView.userInteractionEnabled = YES;
        
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        [self.scrollView addSubview:_photoImageView];
    }
    
    return _photoImageView;
}

/*
 *  事件处理
 */
/*
 *  view单击
 */
-(void)tap_single_viewTap:(UITapGestureRecognizer *)tap{
    [self tap_view];
}

/*
 *  view双击
 */
-(void)tap_double_viewTap:(UITapGestureRecognizer *)tap{
    [self tap_view];
}

-(void)tap_view{
    if(_ItemViewSingleTapBlock != nil)
    {
        [self.photoImageView sd_cancelCurrentAnimationImagesLoad];
        [self.photoImageView sd_cancelCurrentImageLoad];
        self.photoImageView.image = nil;
        self.photoImageView.animationImages = nil;
        
        _ItemViewSingleTapBlock();
    }
}


/*
 *  imageView双击
 */
-(void)tap_double_imageViewTap:(UITapGestureRecognizer *)tap{
    
    if(!self.hasImage) return;
    
    //标记
    self.isDoubleClickZoom = YES;
    
    CGFloat zoomScale = self.scrollView.zoomScale;
    
    if(zoomScale<=1.0f){
        CGPoint loc = [tap locationInView:tap.view];
        
        CGFloat wh =1;
        
        CGRect rect = [UIView frameWithW:wh h:wh center:loc];
        
        [self.scrollView zoomToRect:rect animated:YES];
        //[self.scrollView setZoomScale:2.0f animated:YES];
    }else{
        [self.scrollView setZoomScale:1.0f animated:YES];
    }
}



/*
 *  旋转手势
 */
-(void)rota:(UIRotationGestureRecognizer *)rotaGesture{
    
    NSLog(@"旋转");
    self.photoImageView.transform = CGAffineTransformRotate(rotaGesture.view.transform, rotaGesture.rotation);
    rotaGesture.rotation = 0;
}

-(void)longPressGesture:(UILongPressGestureRecognizer*)longPressGesture
{
//    if([longPressGesture state] == UIGestureRecognizerStateBegan)
//    {
//        if(_ItemViewLongPressBlock != nil) _ItemViewLongPressBlock(self.photoModel.image_HD_U);
//    }
}



/*
 *  代理方法区
 */
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return self.photoImageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    if(scrollView.zoomScale <=1) scrollView.zoomScale = 1.0f;
    
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
    
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
    
    [self.photoImageView setCenter:CGPointMake(xcenter, ycenter)];
}



/** 懒加载 */

/*
 *  view单击
 */
-(UITapGestureRecognizer *)tap_single_viewGesture{
    
    if(_tap_single_viewGesture == nil){
        _tap_single_viewGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_single_viewTap:)];
        _tap_single_viewGesture.numberOfTouchesRequired =1;
        _tap_single_viewGesture.numberOfTapsRequired = 1;
        [_tap_single_viewGesture requireGestureRecognizerToFail:self.tap_double_imageViewGesture];
        [_tap_single_viewGesture requireGestureRecognizerToFail:self.tap_double_viewGesture];
    }
    
    return _tap_single_viewGesture;
}




/*
 *  view双击
 */
-(UITapGestureRecognizer *)tap_double_viewGesture{
    
    if(_tap_double_viewGesture == nil){
        
        _tap_double_viewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_double_viewTap:)];
        [_tap_double_viewGesture requireGestureRecognizerToFail:self.tap_double_imageViewGesture];
        _tap_double_viewGesture.numberOfTapsRequired = 2;
    }
    
    return _tap_double_viewGesture;
}





/*
 *  imageView单击
 */
-(UITapGestureRecognizer *)tap_double_imageViewGesture{
    
    if(_tap_double_imageViewGesture == nil){
        
        _tap_double_imageViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_double_imageViewTap:)];
        _tap_double_imageViewGesture.numberOfTapsRequired = 2;
    }
    
    return _tap_double_imageViewGesture;
}

/*
 *长按
 */
-(UILongPressGestureRecognizer*)longPressGestureRecognizer
{
    if(_longPressGestureRecognizer == nil)
    {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
        _longPressGestureRecognizer.minimumPressDuration = 1.0;
    }
    return _longPressGestureRecognizer;
}


/*
 *  保存图片及回调
 */
-(void)save:(void(^)())ItemImageSaveCompleteBlock failBlock:(void(^)())failBlock{
    
    if(self.photoImageView.image == nil){
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(failBlock != nil) failBlock();
        });
        return;
    }
    
    [self.photoImageView.image savedPhotosAlbum:ItemImageSaveCompleteBlock failBlock:failBlock];
}


-(UIRotationGestureRecognizer *)rotaGesture{
    
    if(_rotaGesture==nil){
        
        _rotaGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rota:)];
    }
    
    return _rotaGesture;
}



/*
 *  重置
 */
-(void)reset{
    
    //缩放比例
    self.scrollView.zoomScale = 1.0f;
    
    //默认无图
    self.hasImage = NO;
    [self.photoImageView setImage:[UIImage imageNamed:@""]];
    self.photoImageView.frame=CGRectZero;
}

+(id)viewFromXIB{
    
    NSString *name=NSStringFromClass(self);
    
    UIView *xibView=[[[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil] firstObject];
    
    if(xibView==nil){
        NSLog(@"CoreXibView：从xib创建视图失败，当前类是：%@",name);
    }
    
    return xibView;
}

@end
