
//
//  TWMyStatus.m
//  即学即用
//
//  Created by Apple on 16/4/20.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWMyStatus.h"
#import <MJExtension.h>
#import "TWPhoto.h"
#import "IWPhotosView.h"
#import "TWComment.h"
#import "RegexKitLite.h"
@implementation TWMyStatus
{
    CGFloat _cellHeight;
}
+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"photos" : [TWPhoto class],@"comment_list" : [TWComment class]};
}
- (void)setComment_list:(NSMutableArray*) array{
    if(_comment_list != nil)
    {
        _comment_list = nil;
    }
    _comment_list = [array mutableCopy];
}
- (CGFloat)cellHeight
{
    if (!_cellHeight) {
        // 文字的最大尺寸
        CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 2 * 10, MAXFLOAT);
        
        
        // cell的高度
        // 文字部分的高度
        if (self.trace_real_title&&![self.trace_real_title isEqualToString:@""]) {
            
                // 计算文字的高度
                CGFloat textH = [self.trace_content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil].size.height;
                 _cellHeight = 55 +textH + 10 + 20 +8;
                NSString *emotionPattern = @"<img\\s*([\\w]*=(\"|\')([^\"\']*)(\"|\')\\s*)*/>";
                [self.trace_content enumerateStringsMatchedByRegex:emotionPattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
                    _cellHeight = 55 +textH + 10 + 20 +8 - captureCount*15;
                }];
            
            
        }else{
            // 计算文字的高度
            CGFloat textH = [self.trace_title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil].size.height;
             _cellHeight = 55 + textH + 10 + 8;
            NSString *emotionPattern = @"<img\\s*([\\w]*=(\"|\')([^\"\']*)(\"|\')\\s*)*/>";
            [self.trace_title enumerateStringsMatchedByRegex:emotionPattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
                _cellHeight = 55 +textH + 10 +8 - captureCount*15;
            }];
           
        }
        // 是否有图片
        if (self.photos) { // 图片帖子
            int count = (int)self.photos.count;
            CGSize size = [IWPhotosView photosViewSizeWithPhotosCount:count];
            
            _cellHeight += size.height ;
        
        }
        
        // 底部工具条的高度
        _cellHeight += 35 +5;

    }
    return _cellHeight;
}
MJCodingImplementation
@end
