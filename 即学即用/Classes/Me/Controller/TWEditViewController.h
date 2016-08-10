//
//  TWEditViewController.h
//  即学即用
//
//  Created by Apple on 16/4/7.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TWEditViewController;
@protocol TWEditViewControllerDelegate <NSObject>

@optional
- (void)editViewController:(TWEditViewController *)editVc didSaveName:(NSString *)name;

@end
@interface TWEditViewController : UIViewController
@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) id<TWEditViewControllerDelegate> delegate;
@end
