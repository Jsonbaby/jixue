//
//  ImageTool.h
//  ShuoHua
//
//  Created by k1er on 14-11-3.
//  Copyright (c) 2014年 HMN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageTool : NSObject

+ (UIImage *)image:(UIImage*)image byScalingToSize:(CGSize)targetSize;

@end
