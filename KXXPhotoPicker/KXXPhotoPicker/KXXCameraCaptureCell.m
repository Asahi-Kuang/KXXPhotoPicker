//
//  KXXCameraCaptureCell.m
//  KXXPhotoPicker
//
//  Created by Qingxu Kuang on 2016/10/22.
//  Copyright © 2016年 kxx.xxq. All rights reserved.
//

#import "KXXCameraCaptureCell.h"
#import <AVFoundation/AVFoundation.h>

@interface KXXCameraCaptureCell()
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *vedioPreviewLayer;
@end

@implementation KXXCameraCaptureCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        CALayer *iconLayer = [CALayer layer];
        [iconLayer setFrame:self.bounds];
        [iconLayer setContentsGravity:kCAGravityCenter];
        [iconLayer setContents:(UIImage *)[UIImage imageNamed:@"camera"].CGImage];
        [self.layer insertSublayer:iconLayer atIndex:0];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            AVCaptureDeviceInput *devieceInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:nil];
            _captureSession = [[AVCaptureSession alloc] init];
            [_captureSession addInput:devieceInput];
            [_captureSession startRunning];
            _vedioPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
            [_vedioPreviewLayer setFrame:self.bounds];
            [_vedioPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            [self.layer insertSublayer:_vedioPreviewLayer atIndex:0];
        }
        else {
            NSLog(@"没有找到您的摄像头，被你吃了吗？");
        }
    }
    return self;
}
@end
