//
//  TWComment.h
//  即学即用
//
//  Created by tao wai on 16/5/7.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWComment : NSObject
@property (nonatomic, copy) NSString *comment_membername;
@property (nonatomic, copy) NSString *comment_addtime;
@property (nonatomic, copy) NSString *comment_content;
@property (nonatomic, copy) NSString *comment_memberavatar;

@property (nonatomic, assign, readonly) CGFloat cellHeight;
@end
