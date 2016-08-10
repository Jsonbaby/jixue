//
//  UIView+ViewController.m
//  project3
//
//  Created by ZC on 15/10/3.
//  Copyright © 2015年 丁俊耀. All rights reserved.
//

#import "UIView+ViewController.h"

@implementation UIView (ViewController)

- (UIViewController *)viewController {
    UIResponder *nextResponder = self.nextResponder;
    do {
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
        nextResponder = nextResponder.nextResponder;
    } while (nextResponder != nil);
    return nil;
}

@end
