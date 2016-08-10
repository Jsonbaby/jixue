

#import "TWAccount.h"

@implementation TWAccount

/**
 *  从文件中解析对象的时候调
 */
- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.key = [decoder decodeObjectForKey:@"key"];
        self.username = [decoder decodeObjectForKey:@"username"];
        self.member_avatar = [decoder decodeObjectForKey:@"member_avatar"];
        self.member_id = [decoder decodeObjectForKey:@"member_id"];
        self.member_nickname = [decoder decodeObjectForKey:@"member_nickname"];
    }
    return self;
}

/**
 *  将对象写入文件的时候调用
 */
- (void)encodeWithCoder:(NSCoder *)encoder
{
    
    [encoder encodeObject:self.key forKey:@"key"];
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.member_avatar forKey:@"member_avatar"];
    [encoder encodeObject:self.member_id forKey:@"member_id"];
    [encoder encodeObject:self.member_nickname forKey:@"member_nickname"];
    
}


@end
