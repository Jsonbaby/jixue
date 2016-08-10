//
//  countButton.m
//  奥品街
//
//  Created by 吴玉铁 on 15/11/5.
//  Copyright © 2015年 铁哥. All rights reserved.
//

#import "CountButton.h"

@implementation CountButton{
    NSTimer *_timer;
}
//代码初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitle:@"发送验证码" forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        [self setTitle:@"60s秒后重新发送" forState:UIControlStateSelected];
        [self setBackgroundColor:[UIColor colorWithRed:106 / 255.0 green:144 / 255.0 blue:227 / 255.0 alpha:1.0]];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.number = 60;
    }
    return self;
}

//开始倒计时
- (void)startCountDown{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countSixty) userInfo:nil repeats:YES];
    self.enabled = NO;
    _number = 60;
    [self setTitle:@"60秒后重新发送" forState:UIControlStateNormal];
    //字体设小点
    self.titleLabel.font = [UIFont systemFontOfSize:12];
}

- (void)countSixty{
    //到0重置按钮
    if (_number == 0) {
        self.enabled = YES;
        _number = 60;
        [_timer invalidate];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        [self setTitle:@"发送验证码" forState:UIControlStateNormal];
        return;
    }
    _number --;
    NSString *string = [NSString stringWithFormat:@"%lds秒后重新发送",(long)_number];
    [self setTitle:string forState:UIControlStateNormal];
}



@end
