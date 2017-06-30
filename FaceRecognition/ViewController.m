//
//  ViewController.m
//  FaceRecognition
//
//  Created by liyang on 17/2/29.
//  Copyright © 2017年 kosienDGL. All rights reserved.
//

#import "ViewController.h"
#import "FaceViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"人脸/二维码识别";
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    button1.backgroundColor = [UIColor redColor];
    [button1 setTitle:@"人脸识别" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(click1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(100, 230, 100, 100)];
    button2.backgroundColor = [UIColor redColor];
    [button2 setTitle:@"二维码识别" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(click2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
}

//人脸识别
- (void)click1
{
    FaceViewController *VC = [[FaceViewController alloc] init];
    VC.metadataType = @"1";
    [self.navigationController pushViewController:VC animated:YES];
}

//二维码识别
- (void)click2
{
    FaceViewController *VC = [[FaceViewController alloc] init];
    VC.metadataType = @"2";
    [self.navigationController pushViewController:VC animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
