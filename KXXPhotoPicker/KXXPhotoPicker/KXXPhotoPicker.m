//
//  KXXPhotoPicker.m
//  KXXPhotoPicker
//
//  Created by Qingxu Kuang on 2016/10/22.
//  Copyright © 2016年 kxx.xxq. All rights reserved.
//

#import "KXXPhotoPicker.h"
#import "KXXCameraCaptureCell.h"
#import "KXXNormalCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

static NSString *cameraCellIdentifier = @"cameraCell";
static NSString *normalCellIdentifier = @"normalCell";
@interface KXXPhotoPicker ()<UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (strong, nonatomic) NSMutableArray          *photoUrlArray;
@property (strong, nonatomic) UIImagePickerController *imagePickerVC;
@end

@implementation KXXPhotoPicker

#pragma mark - lazy loading
- (NSMutableArray *)photoUrlArray {
    if (!_photoUrlArray) {
        _photoUrlArray = @[].mutableCopy;
    }
    return _photoUrlArray;
}

- (UIImagePickerController *)imagePickerVC {
    if (!_imagePickerVC) {
        _imagePickerVC = [[UIImagePickerController alloc] init];
        [_imagePickerVC setAllowsEditing:YES];
        [_imagePickerVC setDelegate:self];
    }
    return _imagePickerVC;
}
#pragma mark --

#pragma mark - life cycle
- (void)viewDidLoad {
    [self collectionViewConfigure];
    [self getPhotoImages];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark --

#pragma mark - methods
- (void)collectionViewConfigure {
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setItemSize:CGSizeMake((SCREEN_WIDTH-2)/3, (SCREEN_WIDTH-2)/3)];
    [flow setMinimumLineSpacing:1.f];
    [flow setMinimumInteritemSpacing:1.f];
    [flow setHeaderReferenceSize:CGSizeZero];
    [_photoCollectionView setCollectionViewLayout:flow animated:YES];
    [_photoCollectionView setDelegate:self];
    [_photoCollectionView setDataSource:self];
    [_photoCollectionView registerClass:[KXXCameraCaptureCell class] forCellWithReuseIdentifier:cameraCellIdentifier];
    [_photoCollectionView registerNib:[UINib nibWithNibName:@"KXXNormalCell" bundle:nil] forCellWithReuseIdentifier:normalCellIdentifier];
}

- (void)getPhotoImages {
    dispatch_async(dispatch_get_main_queue(), ^{
        ALAssetsLibraryAccessFailureBlock failure = ^(NSError *error) {
            if (error) {
                NSLog(@"获取相册资源失败 -->%@", error.localizedDescription);
                return;
            }
        };
        
        ALAssetsGroupEnumerationResultsBlock result = ^(ALAsset *result,NSUInteger idx,BOOL *stop) {
            if (result != NULL) {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    [self.photoUrlArray addObject:result.defaultRepresentation.url];
                }
            }
        };
        
        ALAssetsLibraryGroupsEnumerationResultsBlock groupResult = ^(ALAssetsGroup *group,BOOL *stop) {
            if (group) {
                [group enumerateAssetsUsingBlock:result];
                // refresh data
                [_photoCollectionView reloadData];
            }
        };
        
        ALAssetsLibrary *library = [ALAssetsLibrary new];
        [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:groupResult failureBlock:failure];
    });
    
}

- (void)presentImagePickerControllerWithSourceType:(UIImagePickerControllerSourceType)type {
    [self.imagePickerVC setSourceType:type];
    [self presentViewController:self.imagePickerVC animated:YES completion:^{
        
    }];
}
#pragma mark --

#pragma mark - uicollectionview delegate && dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (self.photoUrlArray.count + 1);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (indexPath.row == 0) {
        // camera cell
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cameraCellIdentifier forIndexPath:indexPath];
    }
    else {
        // normal cell
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:normalCellIdentifier forIndexPath:indexPath];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) return;
    KXXNormalCell *nCell = (KXXNormalCell *)cell;
    if (self.photoUrlArray.count) {
        ALAssetsLibrary *library = [ALAssetsLibrary new];
        NSURL *url = [self.photoUrlArray objectAtIndex:indexPath.row-1];
        [library assetForURL:url resultBlock:^(ALAsset *asset) {
            UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
            [nCell.iconImage setImage:image];
        } failureBlock:^(NSError *error) {
            if (error) {
                NSLog(@"取出照片失败 --->%@", error.localizedDescription);
            }
        }];
    }
    else {
        NSLog(@"相册没有照片。");
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (TARGET_IPHONE_SIMULATOR) {
            NSLog(@"模拟器想用照相机？？？图样图森破");
            return;
        }
        [self presentImagePickerControllerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else {
        ALAssetsLibrary *library = [ALAssetsLibrary new];
        NSURL *url = [self.photoUrlArray objectAtIndex:indexPath.row-1];
        __block UIImage *resultImage = nil;
        [library assetForURL:url resultBlock:^(ALAsset *asset) {
            resultImage = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
        } failureBlock:^(NSError *error) {
            if (error) {
                NSLog(@"取出照片失败 --->%@", error.localizedDescription);
            }
        }];

        [self dismissViewControllerAnimated:YES completion:^{
            self.completeBlock(resultImage);
        }];
    }
}

#pragma mark --

#pragma mark - uinavigationdelegate && uiimagepickercontrollerdelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:^{
            if (info) {
                UIImage *resultImage = [info objectForKey:UIImagePickerControllerEditedImage];
                self.completeBlock(resultImage);
            }
        }];
        
    }];
}
#pragma mark --

#pragma mark - selectors
- (IBAction)goPhotoAlbum:(UIButton *)sender {
    [self presentImagePickerControllerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)cancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
#pragma mark --

@end
