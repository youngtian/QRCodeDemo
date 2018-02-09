//
//  ScanViewController.m
//  QRCodeDemo
//
//  Created by tianyaxu on 2018/2/9.
//  Copyright © 2018年 tianyaxu. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
     NSTimer *_timer;
}
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *scanViewLayer;

@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *shadowLayer;
@property (nonatomic, strong) CAShapeLayer *scanRectLayer;

@property (nonatomic, assign) CGRect scanRect;
@property (nonatomic, strong) UILabel *remindLabel;
@property (nonatomic, strong) UIView *lineView;

#define SCANSPACEOFFSET 0.15f

#define SCREEN_WIDTH    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@end

@implementation ScanViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scanRect = CGRectMake((SCREEN_WIDTH - 220) / 2,(SCREEN_HEIGHT - 250) / 2, 220, 220);
    [self setupScanRect];
    [self.view addSubview:self.remindLabel];
    [self.view addSubview:self.lineView];
    
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(lineViewMoveAction) userInfo:nil repeats:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_timer invalidate];
    _timer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"扫描二维码";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时操作
        [self start];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 回到主线程刷新界面
            [self.view.layer insertSublayer:self.scanViewLayer atIndex:0];
        });
    });
}

// 扫描线
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(self.scanRect.origin.x, self.scanRect.origin.y - 2, self.scanRect.size.width, 2)];
        _lineView.backgroundColor = [UIColor orangeColor];
    }
    return _lineView;
}

// 扫描动画
- (void)lineViewMoveAction {
    [UIView animateWithDuration:1.8 animations:^{
        CGAffineTransform t = self.lineView.transform;
        self.lineView.transform = CGAffineTransformTranslate(t, 0, 220);
    } completion:^(BOOL finished) {
        self.lineView.transform = CGAffineTransformIdentity;
    }];
}

// 提示文本
- (UILabel *)remindLabel {
    if (!_remindLabel) {
        CGRect textRect = self.scanRect;
        textRect.origin.y += CGRectGetHeight(textRect) + 20;
        textRect.origin.x -= textRect.origin.x - 50;
        textRect.size.height = 25.f;
        
        _remindLabel = [[UILabel alloc] initWithFrame:textRect];
        _remindLabel.font = [UIFont systemFontOfSize:15.f * SCREEN_WIDTH / 375.f];
        _remindLabel.textColor = [UIColor whiteColor];
        _remindLabel.textAlignment = NSTextAlignmentCenter;
        _remindLabel.text = @"将二维码/条码放入框内，即可自动扫描";
        _remindLabel.backgroundColor = [UIColor clearColor];
        [_remindLabel sizeToFit];
    }
    return _remindLabel;
}

// 会话对象
- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh]; // 高质量采集
        
    }
    return _session;
}

// 视频输入设备
- (AVCaptureDeviceInput *)input {
    if (!_input) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        _input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    }
    return _input;
}

// 数据输出对象
- (AVCaptureMetadataOutput *)output {
    if (!_output) {
        _output = [[AVCaptureMetadataOutput alloc] init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    return _output;
}

// 扫描视图
- (AVCaptureVideoPreviewLayer *)scanViewLayer {
    if (!_scanViewLayer) {
        _scanViewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _scanViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _scanViewLayer.frame = self.view.layer.bounds;
    }
    return _scanViewLayer;
}

// 配置输入输出设置
- (void)setupIODevice {
    if ([self.session canAddInput:self.input]) {
        [_session addInput:_input];
    }
    
    if ([self.session canAddOutput:self.output]) {
        [_session addOutput:_output];
        _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    }
}

// 配置扫描范围
- (void)setupScanRect {
    CGFloat size = SCREEN_WIDTH * (1 - 2 * SCANSPACEOFFSET);
    CGFloat minY = (SCREEN_HEIGHT - size) * 0.5 / SCREEN_HEIGHT;
    CGFloat maxY = (SCREEN_HEIGHT + size) * 0.5 / SCREEN_HEIGHT;
    self.output.rectOfInterest = CGRectMake(minY, SCANSPACEOFFSET, maxY, 1 - SCANSPACEOFFSET * 2);
    
    [self.view.layer addSublayer:self.shadowLayer];
    [self.view.layer addSublayer:self.scanRectLayer];
}

// 扫描框
- (CAShapeLayer *)scanRectLayer {
    if (!_scanRectLayer) {
        CGRect scanRect = self.scanRect;
        scanRect.origin.x -= 1;
        scanRect.origin.y -= 1;
        scanRect.size.width += 1;
        scanRect.size.height += 1;
        
        _scanRectLayer = [CAShapeLayer layer];
        _scanRectLayer.path = [UIBezierPath bezierPathWithRect:scanRect].CGPath;
        _scanRectLayer.fillColor = [UIColor clearColor].CGColor;
        _scanRectLayer.strokeColor = [UIColor orangeColor].CGColor;
    }
    return _scanRectLayer;
}

// 阴影层
- (CAShapeLayer *)shadowLayer {
    if (!_shadowLayer) {
        _shadowLayer = [CAShapeLayer layer];
        _shadowLayer.path = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
        _shadowLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.75].CGColor;
        _shadowLayer.mask = self.maskLayer;
    }
    return _shadowLayer;
}

// 遮掩层
- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer = [self generateMaskLayerWithRect:self.view.bounds exceptRect:self.scanRect];
    }
    return _maskLayer;
}

// 生成空缺部分rect的layer
- (CAShapeLayer *)generateMaskLayerWithRect:(CGRect)rect exceptRect:(CGRect)exceptRect {
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    if (!CGRectContainsRect(rect, exceptRect)) {
        return nil;
    }
    if (CGRectEqualToRect(rect, CGRectZero)) {
        maskLayer.path = [UIBezierPath bezierPathWithRect:rect].CGPath;
        return maskLayer;
    }
    
    CGFloat boundsInitX = CGRectGetMinX(rect);
    CGFloat boundsInitY = CGRectGetMinY(rect);
    CGFloat boundsWidth = CGRectGetWidth(rect);
    CGFloat boundsHeight = CGRectGetHeight(rect);
    
    CGFloat minX = CGRectGetMinX(exceptRect);
    CGFloat maxX = CGRectGetMaxX(exceptRect);
    CGFloat minY = CGRectGetMinY(exceptRect);
    CGFloat maxY = CGRectGetMaxY(exceptRect);
    CGFloat width = CGRectGetWidth(exceptRect);
    
    /** 添加路径*/
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(boundsInitX, boundsInitY, minX, boundsHeight)];
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(minX, boundsInitY, width, minY)]];
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(maxX, boundsInitY, boundsWidth - maxX, boundsHeight)]];
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(minX, maxY, width, boundsHeight - maxY)]];
    maskLayer.path = path.CGPath;
    
    return maskLayer;
}

#pragma mark - operate
// 开始视频会话
- (void)start {
    [self.session startRunning];
}

// 停止视频会话
- (void)stop {
    [self.session stopRunning];
}

#pragma mark - delegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        [self stop];
        
        // 扫描结果
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        NSString *strValue = metadataObject.stringValue;
        NSLog(@"%@", strValue);
    }
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
