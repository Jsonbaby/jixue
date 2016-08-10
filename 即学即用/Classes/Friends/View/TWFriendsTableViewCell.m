//
//  TWFriendsTableViewCell.m
//  即学即用
//
//  Created by tao wai on 16/5/9.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWFriendsTableViewCell.h"

@implementation TWFriendsTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.iconView=[[UIImageView alloc]initWithFrame:CGRectMake(20, 10, 40, 40)];
        [self.contentView addSubview:self.iconView];
        
        
        self.titleView = [[UILabel alloc]initWithFrame:CGRectMake(70, 10, 250, 20)];
        self.titleView.font = [UIFont boldSystemFontOfSize:16];
        [self.contentView addSubview:self.titleView];
        
        
        self.priceView=[[UILabel alloc]initWithFrame:CGRectMake(70, 40, 250, 10)];
        self.priceView.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:self.priceView];
    }
    return self;

}


@end
