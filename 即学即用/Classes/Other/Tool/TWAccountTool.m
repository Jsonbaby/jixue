//
//  IWAccountTool.m
//  ItcastWeibo
//
//  Created by apple on 14-5-8.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "TWAccount.h"
#import "TWAccountTool.h"
#import "MJExtension.h"
#define TWAccountFile [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"account.data"]

@implementation TWAccountTool
+ (void)saveAccount:(TWAccount *)account
{
    // 计算账号的过期时间

    
    [NSKeyedArchiver archiveRootObject:account toFile:TWAccountFile];
}

+ (TWAccount *)account
{
    // 取出账号
    TWAccount *account = [NSKeyedUnarchiver unarchiveObjectWithFile:TWAccountFile];
    return account;
}


@end
