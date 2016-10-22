//
//  KXXNormalCell.m
//  KXXPhotoPicker
//
//  Created by Qingxu Kuang on 2016/10/22.
//  Copyright © 2016年 kxx.xxq. All rights reserved.
//

#import "KXXNormalCell.h"

@implementation KXXNormalCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.iconImage setContentMode:UIViewContentModeCenter];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
