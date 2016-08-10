//
//  TWBlogDetail.h
//  即学即用
//
//  Created by tao wai on 16/5/10.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWBlogDetail : NSObject
@property (nonatomic, copy) NSString *blog_add_time;
@property (nonatomic, copy) NSString *member_name;
@property (nonatomic, copy) NSString *blog_time;
@property (nonatomic, copy) NSString *blog_content;
@property (nonatomic, copy) NSString *blog_title;
@property (nonatomic, strong) NSArray *comment_list;
@property (nonatomic, copy) NSString *blog_member_id;
@property (nonatomic, copy) NSString *blog_id;
/** cell的高度 */
@property (nonatomic, assign, readonly) CGFloat cellHeight;
@end
