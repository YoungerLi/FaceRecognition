//
//  FaceViewController.h
//  FaceRecognition
//
//  Created by liyang on 17/2/29.
//  Copyright © 2017年 kosienDGL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaceViewController : UIViewController


/**
 识别类型：人脸识别/二维码识别
 metadataType == @"1"   人脸识别
 metadataType == @"2"   二维码识别
 */
@property (nonatomic, copy) NSString *metadataType;

@end
