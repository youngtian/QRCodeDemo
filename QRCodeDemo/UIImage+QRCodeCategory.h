//
//  UIImage+QRCodeCategory.h
//  QRCodeDemo
//
//  Created by tianyaxu on 2018/2/9.
//  Copyright © 2018年 tianyaxu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QRCodeCategory)

+ (UIImage *)imageWithQRFromStr:(NSString *)networkAdress codeSize:(CGFloat)codeSize;

@end
