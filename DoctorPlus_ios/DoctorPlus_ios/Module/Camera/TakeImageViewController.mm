//
//  TakeImageViewController.m
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/9/10.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

#import "TakeImageViewController.h"
#import "CameraScanner.h"
#import "TGCameraSlideDownView.h"
#import "TGCameraSlideUpView.h"
#import "TGCameraSlideView.h"
#import <opencv2/opencv.hpp>
#import "Tools.h"
#import "VideoCameraCover.h"
#import "CameraView.h"
#import "QBImagePickerController.h"
#import "PhotosManager.h"
#import "PhotoRecord.h"
#import "PhotosViewController.h"
#import "UIImage+Thumbnail.h"
#import "Platform.h"
#import "DoctorPlus_ios-Swift.h"
#import "CropView.h"
#import "JBCroppableView.h"
#import "FileSystem.h"
#import "Platform.h"

#define CROPVIEW_MARGIN_ALL 20
#define CAMERA_STATUS_NORMAL 0  //正常拍照状态
#define CAMERA_STATUS_EDIT   1  //编辑图片状态

@interface TakeImageViewController ()
@property (weak, nonatomic) IBOutlet CameraView *camera;
@property (weak, nonatomic) IBOutlet CropView *cropView;
@property (weak, nonatomic) IBOutlet UIView *normalBar;
@property (weak, nonatomic) IBOutlet UIView *sureBar;
@property (strong, nonatomic) IBOutlet TGCameraSlideUpView *upView;
@property (strong, nonatomic) IBOutlet TGCameraSlideDownView *downView;

@end

@interface TakeImageViewController()<CameraViewDelegate,QBImagePickerControllerDelegate,JBCroppableViewDelegate,UIAlertViewDelegate>

@end

@implementation TakeImageViewController {
    BOOL first;
    UIAlertView* uiAlertView;
    QBImagePickerController *imagePickerController;
    CustomIOS7AlertView* alertView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hiddenRightImage:YES];
    self.centerButton.hidden = NO;
    self.centerButton.highlighted = YES;
    first = NO;
    [self.centerButton addTarget:self action:@selector(onFlash:) forControlEvents:UIControlEventTouchUpInside];

}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(first){
        [TGCameraSlideView hideSlideUpView:_upView slideDownView:_downView atView:self.view completion:^{
            
        }];
        first = NO;
    }
    [_camera startPreview];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)onFlash:(UIButton*)sender
{
    _camera.enableFlash = !_camera.enableFlash;
    [Tools Post:^{
        if(_camera.enableFlash){
            self.centerButton.highlighted = NO;
        }else{
            self.centerButton.highlighted = YES;
        }
    } Delay:0];
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) { //没权限
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString* appName =[infoDictionary objectForKey:@"CFBundleDisplayName"];
        NSString* msg = [NSString stringWithFormat:@"请为%@开发相机权限：手机设置->隐私->相机->%@",appName,appName];
        uiAlertView = [[UIAlertView alloc] initWithTitle:@"无法启动相机" message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [uiAlertView show];
    }
    [Tools Post:^{
        _cropView.frame = CGRectMake(CROPVIEW_MARGIN_ALL, CROPVIEW_MARGIN_ALL, _camera.frame.size.width - 2*CROPVIEW_MARGIN_ALL, _camera.frame.size.height - 2*CROPVIEW_MARGIN_ALL);
    } Delay:0];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)setStatus:(NSInteger)status
{
    switch (status) {
        case CAMERA_STATUS_NORMAL:
        {
           
            
        }
            break;
        case CAMERA_STATUS_EDIT:
        {
            
        }
            break;
        default:
            break;
    }
}


-(void)selectImage:(UIImage*)image{
    [self setStatus:CAMERA_STATUS_EDIT];
}


-(void)dismissImagePickerController{
    if (self.presentedViewController != nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popToViewController:self animated:YES];
    }
    imagePickerController = nil;
}

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset
{
    long long imageDataSize = [[asset defaultRepresentation] size];
    uint8_t* imageDataBytes = (uint8_t*)malloc(imageDataSize);
    [[asset defaultRepresentation] getBytes:imageDataBytes fromOffset:0 length:imageDataSize error:nil];
    NSData *data = [NSData dataWithBytesNoCopy:imageDataBytes length:imageDataSize freeWhenDone:YES];
    UIImage* image = [UIImage imageWithData:data];
    //TODO
    [self dismissImagePickerController];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [self dismissImagePickerController];
}

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
}

- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [self dismissImagePickerController];
}

- (IBAction)chosePicture:(id)sender {
    imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = NO;
    imagePickerController.filterType = QBImagePickerControllerFilterTypePhotos;
    if(isPad){
        imagePickerController.numberOfColumnsInPortrait = 11;
    }else{
        imagePickerController.numberOfColumnsInPortrait = 5;
    }
    
    imagePickerController.filterType = QBImagePickerControllerFilterTypePhotos;
    [self.navigationController pushViewController:imagePickerController animated:YES];
    //    self.navigationController.navigationBarHidden = NO;
}


- (IBAction)takePhoto:(id)sender {
    static BOOL captureStillImage = NO;
    if (captureStillImage) {
        return;
    }
    captureStillImage = YES;
    if(!alertView)alertView =  [[UIAlertViewTool getInstance] showLoadingDialog:@"拍照中···"];
    [_camera takePhoto:^(UIImage * image) {
        if(alertView) {
            [alertView close];
            alertView = nil;
        }
        captureStillImage = NO;
        [Tools Post:^{
            self.centerButton.highlighted = YES;
        } Delay:0];
        if(image){
            
        }
    } playSound:YES];
}

- (IBAction)usePhoto:(id)sender {
   
}

- (IBAction)cancleUsePhoto:(id)sender {
     [self setStatus:CAMERA_STATUS_NORMAL];
}

@end
