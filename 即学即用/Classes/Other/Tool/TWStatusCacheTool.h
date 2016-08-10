//
//  TWStatusCacheTool.h
//  即学即用
//
//  Created by tao wai on 16/5/16.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TWMyStatus;
@interface TWStatusCacheTool : NSObject
/**
 *  缓存一条微博
 *
 *  @param status 需要缓存的微博数据
 */
+ (void)addStatus:(TWMyStatus *)status;

/**
 *  缓存N条微博
 *
 *  @param statusArray 需要缓存的微博数据
 */
+ (void)addStatuses:(NSMutableArray *)statusArray;

/**
 *  根据请求参数获得微博数据
 *
 *  @param param 请求参数
 *
 *  @return 模型数组
 */
+ (NSArray *)statuesWithParam:(NSMutableDictionary *)param;
@end
