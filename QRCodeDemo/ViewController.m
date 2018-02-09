//
//  ViewController.m
//  QRCodeDemo
//
//  Created by tianyaxu on 2018/2/8.
//  Copyright © 2018年 tianyaxu. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"
#import "QRCodeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Home";
    
    UIButton *qrCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    qrCodeBtn.frame = CGRectMake(100, 200, 200, 40);
    [qrCodeBtn setTitle:@"生成二维码" forState:UIControlStateNormal];
    [qrCodeBtn setBackgroundColor:[UIColor brownColor]];
    qrCodeBtn.tag = 500;
    [qrCodeBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:qrCodeBtn];
    
    UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    scanBtn.frame = CGRectMake(100, 270, 200, 40);
    [scanBtn setTitle:@"扫描二维码" forState:UIControlStateNormal];
    [scanBtn setBackgroundColor:[UIColor brownColor]];
    scanBtn.tag = 501;
    [scanBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanBtn];
}

- (void)btnAction:(UIButton *)btn {
    if (btn.tag == 500) {
        QRCodeViewController *qrVC = [[QRCodeViewController alloc] init];
        [self.navigationController pushViewController:qrVC animated:YES];
    } else {
        ScanViewController *scanVC = [[ScanViewController alloc] init];
        [self.navigationController pushViewController:scanVC animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
