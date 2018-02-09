//
//  UIImage+QRCodeCategory.m
//  QRCodeDemo
//
//  Created by tianyaxu on 2018/2/9.
//  Copyright © 2018年 tianyaxu. All rights reserved.
//

#import "UIImage+QRCodeCategory.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

@implementation UIImage (QRCodeCategory)

// 制作二维码方法
+ (UIImage *)imageWithQRFromStr:(NSString *)networkAdress codeSize:(CGFloat)codeSize{
    if (!networkAdress || (NSNull *)networkAdress == [NSNull null]) {
        return  nil;
    }
    codeSize = [self validateCodeSize:codeSize];
    CIImage *originImage = [self createQRFromAddress:networkAdress];
    UIImage *img = [self excludeFuzzyImageFormCIImage:originImage size:codeSize];
    return img;
}

// 验证二维码的尺寸的合法性
+ (CGFloat)validateCodeSize:(CGFloat)codeSize{
    codeSize = MAX(160, codeSize);
    codeSize = MIN(SCREEN_WIDTH - 80, codeSize);
    return codeSize;
}

// 利用系统的滤镜生成二维码图
+ (CIImage *)createQRFromAddress:(NSString *)networkAdress{
    // 对需要生成二维码的数据进行utf-8转码
    NSData *strData = [networkAdress dataUsingEncoding:NSUTF8StringEncoding];
    // 创建过滤器
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 添加数据
    [qrFilter setValue:strData forKey:@"inputMessage"];
    // 允许二维码的纠错范围，根据生成时使用的纠错级别而定，可以有7%~%30左右的损坏，分别有L(7%)，M(15%)，Q(25%)，和H(30%)
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    // 输出二维码
    return qrFilter.outputImage;
}

// 对图像进行清晰化处理
+ (UIImage *)excludeFuzzyImageFormCIImage:(CIImage *)image size:(CGFloat)size{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size / extent.size.width, size / extent.size.height);
    size_t wid = extent.size.width * scale;
    size_t hei = extent.size.height * scale;
    
    // 创建灰度色调空间
    CGColorSpaceRef coloeSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, wid, hei, 8, 0, coloeSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGColorSpaceRelease(coloeSpace);
    return [UIImage imageWithCGImage:scaledImage];
}

@end
