//
//  QRCodeViewController.m
//  QRCodeDemo
//
//  Created by tianyaxu on 2018/2/9.
//  Copyright © 2018年 tianyaxu. All rights reserved.
//

#import "QRCodeViewController.h"
#import "UIImage+QRCodeCategory.h"
@interface QRCodeViewController ()

@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"二维码";
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 200, 200, 200)];
    [self.view addSubview:imageView];

    UIImage *image = [UIImage imageWithQRFromStr:@"haha" codeSize:200];
    imageView.image = image;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
