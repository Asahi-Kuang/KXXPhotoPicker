//
//  KXXPhotoPicker.h
//  KXXPhotoPicker
//
//  Created by Qingxu Kuang on 2016/10/22.
//  Copyright © 2016年 kxx.xxq. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^photoPickComplete)(UIImage *image);
@interface KXXPhotoPicker : UIViewController
@property (nonatomic, copy) photoPickComplete completeBlock;
@end
