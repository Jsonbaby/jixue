

#import <Foundation/Foundation.h>

@class TWAccount;

@interface TWAccountTool : NSObject
/**
 *  存储账号信息
 *
 *  @param account 需要存储的账号
 */
+ (void)saveAccount:(TWAccount *)account;

/**
 *  返回存储的账号信息
 */
+ (TWAccount *)account;



@end
