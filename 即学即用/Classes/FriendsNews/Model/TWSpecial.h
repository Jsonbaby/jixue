//
//  TWSpecial.h
//  即学即用
//
//  Created by tao wai on 16/5/16.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWSpecial : NSObject
/** 这段特殊文字的内容 */
@property (nonatomic, copy) NSString *text;
/** 这段特殊文字的范围 */
@property (nonatomic, assign) NSRange range;
@end
