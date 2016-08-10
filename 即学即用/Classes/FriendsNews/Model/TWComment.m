//
//  TWComment.m
//  即学即用
//
//  Created by tao wai on 16/5/7.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWComment.h"
#import <MJExtension.h>
@implementation TWComment
{
    CGFloat _cellHeight;
}

- (CGFloat)cellHeight
{
    if (!_cellHeight) {
        // 文字的最大尺寸
        CGSize maxSize = CGSizeMake(TWScreenW-55, MAXFLOAT);
        
            // 计算文字的高度
        CGFloat textH = [self.comment_content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size.height;
        _cellHeight = 55 + textH + 10 ;
    
    }
    return _cellHeight;
}

MJCodingImplementation
@end
