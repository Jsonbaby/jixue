//
//  TWBlog.h
//  即学即用
//
//  Created by Apple on 16/4/15.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWBlog : NSObject
@property (nonatomic, copy) NSString *blog_id;
@property (nonatomic, copy) NSString *blog_title;
@property (nonatomic, copy) NSString *blog_content;
@property (nonatomic, copy) NSString *blog_add_time;
@property (nonatomic, copy) NSString *member_avatar;
@end
