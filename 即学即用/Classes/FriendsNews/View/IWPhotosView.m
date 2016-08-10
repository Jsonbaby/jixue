

#import "IWPhotosView.h"
#import "TWPhoto.h"
#import "IWPhotoView.h"
#import "UIImage+ZLPhotoLib.h"
#import "ZLPhoto.h"
#import "UIButton+WebCache.h"
#import "TWMeViewController.h"
@interface IWPhotosView ()<ZLPhotoPickerBrowserViewControllerDelegate>
@property (nonatomic , strong) NSMutableArray *assets;
@end
@implementation IWPhotosView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        // 初始化9个子控件
        for (int i = 0; i<9; i++) {
            IWPhotoView *photoView = [[IWPhotoView alloc] init];
            photoView.userInteractionEnabled = YES;
            photoView.tag = i;
            [photoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTap:)]];
            [self addSubview:photoView];
        }
        self.backgroundColor = TWRGBColor(255, 255, 255);
    }
    return self;
}

- (NSMutableArray *)assets{

        _assets = [NSMutableArray arrayWithCapacity:self.photos.count];
        for (TWPhoto *twphoto in self.photos) {
            ZLPhotoPickerBrowserPhoto *photo = [[ZLPhotoPickerBrowserPhoto alloc] init];
            photo.photoURL = [NSURL URLWithString:twphoto.image_url];
            [_assets addObject:photo];
        }
    return _assets;
}

- (void)photoTap:(UITapGestureRecognizer *)recognizer
{
   
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    // 传入点击图片View的话，会有微信朋友圈照片的风格
//    [pickerBrowser showHeadPortrait:(UIImageView *)recognizer.view];
    // 数据源/delegate
    pickerBrowser.delegate = self;
    // 淡入淡出效果
    pickerBrowser.status = UIViewAnimationAnimationStatusFade;
    // 当前显示的分页数
    pickerBrowser.currentIndex = recognizer.view.tag;
   
    pickerBrowser.photos = self.assets;
    // 展示控制器
    UITabBarController *root = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UITableViewController *rootVc = root.selectedViewController;
   [pickerBrowser showPickerVc:rootVc];

   
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
   
    for (int i = 0; i<9; i++) {
        // 取出i位置对应的imageView
        IWPhotoView *photoView = self.subviews[i];
        
        // 判断这个imageView是否需要显示数据
        if (i < photos.count) {
            // 显示图片
            photoView.hidden = NO;
            
            // 传递模型数据
            photoView.photo = photos[i];
            
            // 设置子控件的frame
            int maxColumns = (photos.count == 4) ? 2 : 3;
            int col = i % maxColumns;
            int row = i / maxColumns;
            CGFloat photoX = col * ((TWScreenW-30)/3 + 5);
            CGFloat photoY = row * ((TWScreenW-30)/3 + 5);
            photoView.frame = CGRectMake(photoX, photoY, (TWScreenW-30)/3, (TWScreenW-30)/3);
            
            // Aspect : 按照图片的原来宽高比进行缩
            // UIViewContentModeScaleAspectFit : 按照图片的原来宽高比进行缩放(一定要看到整张图片)
            // UIViewContentModeScaleAspectFill :  按照图片的原来宽高比进行缩放(只能图片最中间的内容)
            // UIViewContentModeScaleToFill : 直接拉伸图片至填充整个imageView
            
            if (photos.count == 1) {
                photoView.contentMode = UIViewContentModeScaleAspectFill;
                photoView.clipsToBounds = YES;
            } else {
                photoView.contentMode = UIViewContentModeScaleAspectFill;
                photoView.clipsToBounds = YES;
            }
        } else { // 隐藏imageView
            photoView.hidden = YES;
        }
    }
}

+ (CGSize)photosViewSizeWithPhotosCount:(int)count
{
    // 一行最多有3列
    int maxColumns = (count == 4) ? 2 : 3;
    
    //  总行数
    int rows = (count + maxColumns - 1) / maxColumns;
    // 高度
    CGFloat photosH = rows * (TWScreenW-30)/3 + (rows - 1) * 5;
    
    // 总列数
    int cols = (count >= maxColumns) ? maxColumns : count;
    // 宽度
    CGFloat photosW = cols * (TWScreenW-30)/3 + (cols - 1) * 5;
    
    return CGSizeMake(photosW, photosH);
//    return CGSizeMake(0, 0);
    /**
     一共60条数据 == count
     一页10条 == size
     总页数 == pages
     pages = (count + size - 1)/size;
     */
}
@end