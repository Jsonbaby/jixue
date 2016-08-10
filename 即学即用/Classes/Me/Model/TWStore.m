//
//  TWStore.m
//  即学即用
//
//  Created by tao wai on 16/5/9.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWStore.h"
#import "TWPhoto.h"
#import "IWPhotosView.h"
#import "RegexKitLite.h"
@implementation TWStore
{
    CGFloat _cellHeight;
}


+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"msg" : [TWComment class],@"photos" : [TWPhoto class]};
}

- (CGFloat)cellHeight
{
    if (!_cellHeight) {
        // 文字的最大尺寸
        CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 2 * 10, MAXFLOAT);
        
        
        // cell的高度
        // 文字部分的高度
        if (self.detail.blog_content) {
            // 计算文字的高度
            CGFloat textH = [self.detail.blog_content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil].size.height;
            _cellHeight = 55 +textH + 10 + 20;
            NSString *emotionPattern = @"<img\\s*([\\w]*=(\"|\')([^\"\']*)(\"|\')\\s*)*/>";
            [self.self.detail.blog_content enumerateStringsMatchedByRegex:emotionPattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
                _cellHeight = 55 +textH + 10 + 20 - captureCount*15;
            }];
        }else{
            if (self.detail.trace_real_title&&![self.detail.trace_real_title isEqualToString:@""]) {
                CGFloat textH = [self.detail.trace_content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil].size.height;
                _cellHeight = 55 + textH + 10 +10+20;
                NSString *emotionPattern = @"<img\\s*([\\w]*=(\"|\')([^\"\']*)(\"|\')\\s*)*/>";
                [self.detail.trace_content enumerateStringsMatchedByRegex:emotionPattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
                    _cellHeight = 55 +textH + 10 + 10 +8 - captureCount*15;
                }];
            }else{
                // 计算文字的高度
                CGFloat textH = [self.detail.trace_title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil].size.height;
                _cellHeight = 55 + textH + 10 +10;
                NSString *emotionPattern = @"<img\\s*([\\w]*=(\"|\')([^\"\']*)(\"|\')\\s*)*/>";
                [self.self.detail.trace_title enumerateStringsMatchedByRegex:emotionPattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
                    _cellHeight = 55 +textH + 10 + 10 - captureCount*15;
                }];
            }
        }
        // 是否有图片
                if (self.photos) { // 图片帖子
                    int count = (int)self.photos.count;
                    CGSize size = [IWPhotosView photosViewSizeWithPhotosCount:count];
        
                    _cellHeight += size.height + 10 ;
        
                }
        
        // 底部工具条的高度
        _cellHeight += 5;
        //        if (_cellHeight >=1000) {
        //            _cellHeight = 250;
        //        }
    }
    return _cellHeight;
}
@end
