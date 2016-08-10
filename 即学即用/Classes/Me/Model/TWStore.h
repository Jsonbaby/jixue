//
//  TWStore.h
//  即学即用
//
//  Created by tao wai on 16/5/9.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWDetail.h"
#import "TWComment.h"
@interface TWStore : NSObject
@property (nonatomic, copy) NSString *favourite_add_time;
@property (nonatomic, copy) NSString *favourite_member_id;
@property (nonatomic, strong) TWDetail *detail;
@property (nonatomic, strong) NSArray *msg;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, copy) NSString *favourite_id;

/** cell的高度 */
@property (nonatomic, assign, readonly) CGFloat cellHeight;
@end
