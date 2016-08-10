//
//  countButton.h
//  奥品街
//
//  Created by 吴玉铁 on 15/11/5.
//  Copyright © 2015年 铁哥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountButton : UIButton

@property (nonatomic,assign) NSInteger number;

//开始计数
- (void)startCountDown;



@end
