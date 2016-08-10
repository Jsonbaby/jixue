//
//  TWBlogTableViewCell.m
//  即学即用
//
//  Created by Apple on 16/4/15.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWBlogTableViewCell.h"

@implementation TWBlogTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)layoutSubviews
{
    
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(10, 10, 40, 40);
    self.detailTextLabel.x = 60;
    self.textLabel.x =60;
    
    
}
@end
