

#import "IWPhotoView.h"
#import "TWPhoto.h"
#import "UIImageView+WebCache.h"

@interface IWPhotoView()
@property (nonatomic, weak) UIImageView *gifView;
@end

@implementation IWPhotoView


- (void)setPhoto:(TWPhoto *)photo
{
    _photo = photo;
    // 下载图片
    [self sd_setImageWithURL:[NSURL URLWithString:photo.image_url] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
}

@end
