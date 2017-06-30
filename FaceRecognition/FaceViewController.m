//
//  FaceViewController.m
//  FaceRecognition
//
//  Created by liyang on 17/2/29.
//  Copyright © 2017年 kosienDGL. All rights reserved.
//

#import "FaceViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface FaceViewController ()<AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>
//硬件设备
@property (nonatomic, strong) AVCaptureDevice *device;
//输入流
@property (nonatomic, strong) AVCaptureDeviceInput *input;
//输出流
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;      //用于二维码识别以及人脸识别
//协调输入输出流的数据
@property (nonatomic, strong) AVCaptureSession *session;
//预览层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

//遮脸图片
@property (nonatomic, strong) UIImageView *faceImageView;
@end

@implementation FaceViewController


#pragma mark - 获取硬件设备
- (AVCaptureDevice *)device
{
    if (_device == nil) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([_device lockForConfiguration:nil]) {   //上锁（调整device属性的时候需要上锁）
            //自动闪光灯
            if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
                [_device setFlashMode:AVCaptureFlashModeAuto];
            }
            //自动白平衡
            if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
                [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            }
            //自动对焦
            if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [_device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            }
            //自动曝光
            if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [_device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            [_device unlockForConfiguration];//解锁
        }
    }
    return _device;
}

#pragma mark - 获取硬件的输入流
- (AVCaptureDeviceInput *)input
{
    if (_input == nil) {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    return _input;
}

#pragma mark - 输出流
- (AVCaptureMetadataOutput *)metadataOutput
{
    if (_metadataOutput == nil) {
        _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        _metadataOutput.rectOfInterest = self.view.bounds;  //设置扫描区域
    }
    return _metadataOutput;
}

#pragma mark - 协调输入和输出数据的会话
- (AVCaptureSession *)session
{
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
        if ([_session canAddInput:self.input]) {
            [_session addInput:self.input];
        }
        if ([_session canAddOutput:self.metadataOutput]) {
            [_session addOutput:self.metadataOutput];
            //设置扫描类型
            if ([self.metadataType isEqualToString:@"1"]) {
                //人脸识别
                self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
            } else if ([self.metadataType isEqualToString:@"2"]) {
                //二维码识别
                self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                                            AVMetadataObjectTypeEAN13Code,
                                                            AVMetadataObjectTypeEAN8Code,
                                                            AVMetadataObjectTypeCode128Code];
            }
        }
    }
    return _session;
}

#pragma mark - 预览图像的层
- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (_previewLayer == nil) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.frame = self.view.layer.bounds;
    }
    return _previewLayer;
}


#pragma mark -
#pragma mark -

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.session startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.session stopRunning];
    self.session = nil;
    [self.previewLayer removeFromSuperlayer];
    [super viewWillDisappear:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //把previewLayer添加到self.view.layer上
    [self.view.layer addSublayer:self.previewLayer];
    
    //设置导航栏右边按钮
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(switchCamera)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

#pragma mark - 切换前后置摄像头
- (void)switchCamera
{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[self.input device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            self.faceImageView.hidden = YES;
        }else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.input];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.input = newInput;
            } else {
                [self.session addInput:self.input];
            }
            [self.session commitConfiguration];
        }
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}

#pragma mark - 遮脸图片
- (UIImageView *)faceImageView
{
    if (_faceImageView == nil) {
        _faceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"face.jpg"]];
        [self.view addSubview:_faceImageView];
        _faceImageView.hidden = YES;
    }
    return _faceImageView;
}



#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"扫描完成 = %zd个 == %@", metadataObjects.count, metadataObjects);
    
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        if ([self.metadataType isEqualToString:@"1"]) {
            //人脸识别结果
            AVMetadataObject *faceData = [self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
            NSLog(@"faceData == %@", faceData);
            self.faceImageView.frame = faceData.bounds;
            self.faceImageView.hidden = NO;
            
        } else if ([self.metadataType isEqualToString:@"2"]) {
            //二维码识别结果
            [self.session stopRunning];
            NSLog(@"qrcode is : %@", metadataObject.stringValue);
        }
    } else {
        //
        self.faceImageView.hidden = YES;
    }
}












- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
