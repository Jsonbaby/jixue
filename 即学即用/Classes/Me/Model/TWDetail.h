//
//  TWDetail.h
//  即学即用
//
//  Created by tao wai on 16/5/9.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWDetail : NSObject
@property (nonatomic, copy) NSString *trace_title;
@property (nonatomic, copy) NSString *trace_content;
@property (nonatomic, copy) NSString *trace_real_title;
@property (nonatomic, copy) NSString *trace_id;
@property (nonatomic, copy) NSString *trace_addtime;
@property (nonatomic, copy) NSString *trace_memberavatar;
@property (nonatomic, copy) NSString *trace_membername;

@property (nonatomic, copy) NSString *blog_title;
@property (nonatomic, copy) NSString *blog_content;
@property (nonatomic, copy) NSString *blog_member_name;
@property (nonatomic, copy) NSString *blog_add_time;
@property (nonatomic, copy) NSString *blog_id;
@end
