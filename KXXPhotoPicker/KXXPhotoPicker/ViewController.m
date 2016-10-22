//
//  ViewController.m
//  KXXPhotoPicker
//
//  Created by Qingxu Kuang on 2016/10/22.
//  Copyright © 2016年 kxx.xxq. All rights reserved.
//

#import "ViewController.h"
#import "KXXPhotoPicker.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openPhotoPicker:(UIButton *)sender {
    KXXPhotoPicker *picker = [KXXPhotoPicker new];
    picker.completeBlock = ^(UIImage *image) {
        [self.imageView setImage:image];
    };
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}
@end
