//
//  TWBaseFriendController.m
//  即学即用
//
//  Created by Apple on 16/4/6.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWBaseFriendController.h"
#import <SVProgressHUD.h>
#import <MJExtension.h>
#import "TWFriend.h"
#import "UIImageView+WebCache.h"
#import "TWFriendsTableViewCell.h"

@interface TWBaseFriendController ()

@end

@implementation TWBaseFriendController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.friends.count;
    
}





- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 70;
    
}





@end
