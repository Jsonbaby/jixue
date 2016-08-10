//
//  UIBarButtonItem+TWExtension.h
//  即学即用
//
//  Created by Apple on 16/4/5.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (TWExtension)
+ (instancetype)itemWithImage:(NSString *)image highImage:(NSString *)highImage target:(id)target action:(SEL)action;
@end
