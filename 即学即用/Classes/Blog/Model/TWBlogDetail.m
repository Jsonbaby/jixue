//
//  TWBlogDetail.m
//  即学即用
//
//  Created by tao wai on 16/5/10.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWBlogDetail.h"
#import "TWComment.h"
@implementation TWBlogDetail
{
    CGFloat _cellHeight;
}
+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"comment_list" : [TWComment class]};
}
- (CGFloat)cellHeight
{
    if (!_cellHeight) {
        // 文字的最大尺寸
//        CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 2 * 10, MAXFLOAT);
//        
        
        // cell的高度
        // 文字部分的高度

//            CGFloat textH = [self.blog_content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size.height;
            _cellHeight = 55 + 10 +10;
                // 是否有图片
//        if (self.photos) { // 图片帖子
//            int count = (int)self.photos.count;
//            CGSize size = [IWPhotosView photosViewSizeWithPhotosCount:count];
//            
//            _cellHeight += size.height + 10;
//            
//        }
        
        // 底部工具条的高度
        _cellHeight += 35 + 10 + 10;
        //        if (_cellHeight >=1000) {
        //            _cellHeight = 250;
        //        }
    }
    return _cellHeight;
}

@end
