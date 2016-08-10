//
//  TWMyStatus.h
//  即学即用
//
//  Created by Apple on 16/4/20.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>
@class TWMemberInfo;
@interface TWMyStatus : NSObject
@property (nonatomic, copy) NSString *trace_title;
@property (nonatomic, copy) NSString *trace_content;
@property (nonatomic, copy) NSString *liked;
@property (nonatomic, copy) NSString *trace_addtime;
@property (nonatomic, copy) NSString *trace_membername;
@property (nonatomic, copy) NSString *trace_real_title;
@property (nonatomic, copy) NSString *trace_memberavatar;
@property (nonatomic, copy) NSString *trace_memberid;
@property (nonatomic, copy) NSString *trace_id;
@property (nonatomic, strong) TWMemberInfo *member_info;
@property (nonatomic, copy) NSString *trace_title_forward;
@property (nonatomic, copy) NSString *trace_img_memid;
/** cell的高度 */
@property (nonatomic, assign, readonly) CGFloat cellHeight;
@property (nonatomic, copy) NSArray *photos;
@property (nonatomic, copy) NSMutableArray *comment_list;
@property (nonatomic, copy) NSString *trace_like_count;
@property (nonatomic, copy) NSString *trace_copycount;
@property (nonatomic, copy) NSString *trace_commentcount;
@end
