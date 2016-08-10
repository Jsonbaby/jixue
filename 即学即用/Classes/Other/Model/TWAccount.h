

//  帐号模型

#import <Foundation/Foundation.h>

@interface TWAccount : NSObject <NSCoding>
@property (nonatomic, copy) NSString *key;
/**
 *  姓名
 */
@property (nonatomic, copy) NSString *username;
/**
 *  头像的URL
 */
@property (nonatomic, copy) NSString *member_avatar;

@property (nonatomic, copy) NSString *member_id;

@property (nonatomic, copy) NSString *member_nickname;
@end
