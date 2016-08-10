//
//  TWStatusCacheTool.m
//  即学即用
//
//  Created by tao wai on 16/5/16.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWStatusCacheTool.h"
#import <FMDB.h>
#import "TWMyStatus.h"
#import "TWAccountTool.h"
#import "TWAccount.h"
@implementation TWStatusCacheTool
static FMDatabaseQueue *_queue;

+ (void)setup
{
    // 0.获得沙盒中的数据库文件名
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"statuses.sqlite"];
    
    // 1.创建队列
    _queue = [FMDatabaseQueue databaseQueueWithPath:path];
    
    // 2.创表
    [_queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"create table if not exists t_status (id integer primary key autoincrement, key text, status blob);"];
    }];
}

+ (void)addStatuses:(NSMutableArray *)statusArray
{
    for (TWMyStatus *status in statusArray) {
        [self addStatus:status];
    }
}

+ (void)addStatus:(TWMyStatus *)status
{
    [self setup];
    
    [_queue inDatabase:^(FMDatabase *db) {
        // 1.获得需要存储的数据
        NSString *accessToken = [TWAccountTool account].key;
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:status];
        
        // 2.存储数据
        [db executeUpdate:@"insert into t_status (key, status) values(?, ?)", accessToken, data];
    }];
    
    [_queue close];
}

+ (NSArray *)statuesWithParam:(NSMutableDictionary *)param
{
    [self setup];
    
    // 1.定义数组
    __block NSMutableArray *statusArray = nil;
    
    // 2.使用数据库
    [_queue inDatabase:^(FMDatabase *db) {
        // 创建数组
        statusArray = [NSMutableArray array];
        
        // accessToken
        NSString *accessToken = [TWAccountTool account].key;
        
        FMResultSet *rs = nil;

        rs = [db executeQuery:@"select * from t_status where key = ?;", accessToken];

        while (rs.next) {
            NSData *data = [rs dataForColumn:@"status"];
            TWMyStatus *status = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [statusArray addObject:status];
        }
    }];
    [_queue close];
    
    // 3.返回数据
    return statusArray;
}
@end
