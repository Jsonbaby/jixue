//
//  TWFriendsStatusController.m
//  即学即用
//
//  Created by Apple on 16/4/5.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWFriendsController.h"
#import "TWGoodFriendViewController.h"
#import "TWGuanZhuViewController.h"
#import "TWFansViewController.h"
#import "TWAddPeopleViewController.h"
#import <AFNetworking.h>
#import "TWSearchViewController.h"
#import "TWBlackListController.h"
@interface TWFriendsController ()<UIScrollViewDelegate>
/** 标签栏底部的红色指示器 */
@property (nonatomic, weak) UISegmentedControl *sc;

/** 底部的所有内容 */
@property (nonatomic, weak) UIScrollView *contentView;
@end

@implementation TWFriendsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化子控制器
    [self setupChildVces];
    
    // 设置顶部的标签栏
    [self setupNav];
    // 底部的scrollView
    [self setupContentView];

}


/**
 * 初始化子控制器
 */
- (void)setupChildVces
{
    TWGoodFriendViewController *goodfriend = [[TWGoodFriendViewController alloc] init];
    
    [self addChildViewController:goodfriend];
    
    TWFansViewController *fans = [[TWFansViewController alloc] init];
    
    [self addChildViewController:fans];
    
    TWGuanZhuViewController *guanzhu = [[TWGuanZhuViewController alloc] init];
    
    [self addChildViewController:guanzhu];
    
    TWBlackListController *blackList = [[TWBlackListController alloc] init];
    
    [self addChildViewController:blackList];
  
}


/**
 * 设置顶部的标签栏
 */
- (void)setupNav
{
    // 设置导航栏右边的按钮
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:@"friendsRecommentIcon" highImage:@"friendsRecommentIcon-click" target:self action:@selector(addingFriend)];
     self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:@"friendsearch" highImage:@"friendsearchclick" target:self action:@selector(searchFriend)];
    // 设置背景色
    self.view.backgroundColor = TWGlobalBg;
    
    // 设置导航栏中间
    UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:@[@"好友",@"粉丝",@"关注",@"黑名单"]];
    [sc addTarget:self action:@selector(scClick:) forControlEvents:UIControlEventValueChanged];
    self.sc = sc;
    self.navigationItem.titleView = sc;
}

- (void)addingFriend
{
    TWAddPeopleViewController *pvc = [[TWAddPeopleViewController alloc] init];
    [self.navigationController pushViewController:pvc animated:YES];
}

- (void)searchFriend
{
    TWSearchViewController *svc = [[TWSearchViewController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)scClick:(UISegmentedControl *)sc
{
    // 滚动
    CGPoint offset = self.contentView.contentOffset;
    offset.x = sc.selectedSegmentIndex * self.contentView.width;
    [self.contentView setContentOffset:offset animated:YES];

}
/**
 * 底部的scrollView
 */
- (void)setupContentView
{
    // 不要自动调整inset
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIScrollView *contentView = [[UIScrollView alloc] init];
    contentView.frame = self.view.bounds;
    contentView.delegate = self;
    contentView.pagingEnabled = YES;
    [self.view insertSubview:contentView atIndex:0];
    contentView.contentSize = CGSizeMake(contentView.width * self.childViewControllers.count, 0);
    self.contentView = contentView;
    
    // 添加第一个控制器的view
    [self scrollViewDidEndScrollingAnimation:contentView];
}
#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // 当前的索引
    NSInteger index = scrollView.contentOffset.x / scrollView.width;
    self.sc.selectedSegmentIndex = index;
    // 取出子控制器
    UIViewController *vc = self.childViewControllers[index];
    vc.view.x = scrollView.contentOffset.x;
    vc.view.y = 0; // 设置控制器view的y值为0(默认是20)
    vc.view.height = scrollView.height-49; // 设置控制器view的height值为整个屏幕的高度(默认是比屏幕高度少个20)
    [scrollView addSubview:vc.view];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}




@end
