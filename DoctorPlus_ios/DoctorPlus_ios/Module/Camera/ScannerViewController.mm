//
//  ScannerViewController.m
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/7/16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "ScannerViewController.h"
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


@interface ScannerViewController ()<CameraViewDelegate,QBImagePickerControllerDelegate,JBCroppableViewDelegate,UIAlertViewDelegate>
{
    QBImagePickerController *imagePickerController;
    ComFqHalcyonPracticePhotosManager* photosManager;
    BOOL addImage;
    UIImageView *preImageView;
    BOOL first;
    std::vector<bool> focus;
    CustomIOS7AlertView* dialog;
    BOOL autoShear;
    JBCroppableView* jbCroppableView;
    std::vector<cv::Point> rect; //计算剪切所得到的矩形区域
    CustomIOS7AlertView* alertView;
    UIAlertView* uiAlertView;
}

@property (strong, nonatomic) IBOutlet TGCameraSlideUpView *slideUpView;
@property (strong, nonatomic) IBOutlet TGCameraSlideDownView *slideDownView;
@property (weak, nonatomic) IBOutlet VideoCameraCover *coverView;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet CameraView *camera;
@property (weak, nonatomic) IBOutlet UILabel *savedNumlable;
@property (weak, nonatomic) IBOutlet UIButton *savedBtn;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;
@property (weak, nonatomic) IBOutlet CropView *cropView;

@property (weak, nonatomic) IBOutlet UIView *bottom_takepto;
@property (weak, nonatomic) IBOutlet UIView *bottom_normal;
@property (weak, nonatomic) IBOutlet UIButton *btn_usePhoto;

@end

@implementation ScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    autoShear = YES;
    alertView = nil;
    photosManager = [ComFqHalcyonPracticePhotosManager getInstance];
   
//    imagePickerController.clearsSelectionOnViewWillAppear = YES;
    _savedNumlable.layer.masksToBounds = YES;
    _savedNumlable.layer.cornerRadius = 10;
    _savedNumlable.hidden = YES;
    addImage = NO;
    preImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height)];
    preImageView.contentMode = UIViewContentModeScaleAspectFill;
    _previewImageView.hidden = YES;
    
    [self hiddenRightImage:YES];
    _camera.delegate = self;
    [self setRightBtnTittle:@"自动裁剪:开"];
    [self.bigRightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.bigRightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.bigRightBtn setFont:[UIFont systemFontOfSize:13]];
    first = YES;
    self.centerButton.hidden = NO;
    self.centerButton.highlighted = YES;
    [self.centerButton addTarget:self action:@selector(onFlash:) forControlEvents:UIControlEventTouchUpInside];
     [_takePhotoBtn setEnabled:NO];
    [_cropView setHidden:YES];
    [photosManager checkLoading];
    
    BOOL settting = [ComFqLibToolsConstants getUser].isOnlyWifi;
    if(settting && [[ComFqLibPlatformPlatform getInstance] getNetworkState] == ComFqLibPlatformPlatform_get_NETWORKSATE_OTHER_() && [photosManager haseUpLoadingPicture]){
        [Tools Post:^{
            dialog = [[UIAlertViewTool getInstance] showZbarDialog:@"当前正使用移动网络，是否确定上传图片" target:self actionOk:@selector(dialogOk) actionCancle:@selector(dialogCannel) actionOkStr:@"确认（不再提醒）" actionCancelStr:@"取消"];
        } Delay:.8f];
    }
}


-(void)onStatusChange:(BOOL)isSquare
{
    _btn_usePhoto.enabled = isSquare;
}

//相机的几个状态
-(void)setStatus:(NSInteger)status
{
    switch (status) {
        case CAMERA_STATUS_NORMAL:
        {
            _bottom_normal.hidden = NO;
            _bottom_takepto.hidden = YES;
            [_previewImageView setImage:nil];
            _previewImageView.hidden = YES;
            if(autoShear) _cropView.hidden = YES;
            else {
                _cropView.hidden = NO;
            }
            if(jbCroppableView && jbCroppableView.superview){
                [jbCroppableView removeFromSuperview];
                jbCroppableView = nil;
            }
            self.bigRightBtn.enabled = YES;

        }
            break;
        case CAMERA_STATUS_EDIT:
        {
            self.bigRightBtn.enabled = NO;
            _bottom_normal.hidden = YES;
            _bottom_takepto.hidden = NO;
            _previewImageView.hidden = NO;
            _cropView.hidden = YES;
        }
            break;
        default:
            break;
    }
}

-(void)onLeftBtnOnClick:(UIButton *)sender
{
    if(_bottom_normal.hidden){
        [self setStatus:CAMERA_STATUS_NORMAL];
    }else{
        [super onLeftBtnOnClick:sender];
    }
}

- (IBAction)usePhoto:(id)sender {
    NSArray* points = [jbCroppableView getPoints];
    UIImage* image = _previewImageView.image;
    image = [self shearImage:image withPoints:points];
    if(image){
        [self addPhoto:image fromSystmPicture:false];
        [self setStatus:CAMERA_STATUS_NORMAL];
    }
}
- (IBAction)cancleUsePhoto:(id)sender {
    [self setStatus:CAMERA_STATUS_NORMAL];
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
            NSArray* points = [self getEdge:image];
            [_previewImageView setImage:image];
            if(jbCroppableView) [jbCroppableView removeFromSuperview];
            jbCroppableView = [[JBCroppableView alloc] initWithImageView:_previewImageView];
            jbCroppableView.delegate = self;
            [self.containerView addSubview:jbCroppableView];
            if([points count] == 4) [jbCroppableView addPointsAt:points];
            else[jbCroppableView addPoints:4];
            [self setStatus:CAMERA_STATUS_EDIT];
        }
    } playSound:YES];
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

-(void)onRightBtnOnClick:(UIButton *)sender
{
    if(autoShear){
        [self setRightBtnTittle:@"自动裁剪:关"];
        [self.bigRightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.bigRightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
         [_takePhotoBtn setEnabled:YES];
        _cropView.hidden = NO;
        _cropView.frame = CGRectMake(CROPVIEW_MARGIN_ALL, CROPVIEW_MARGIN_ALL, _camera.frame.size.width - 2*CROPVIEW_MARGIN_ALL, _camera.frame.size.height - 2*CROPVIEW_MARGIN_ALL);
    }else{
        [self setRightBtnTittle:@"自动裁剪:开"];
        [self.bigRightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.bigRightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
         [_takePhotoBtn setEnabled:NO];
        _cropView.hidden = YES;
        
    }
    autoShear = !autoShear;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(first){
        [TGCameraSlideView hideSlideUpView:_slideUpView slideDownView:_slideDownView atView:self.view completion:^{
            
        }];
        first = NO;
    }
    [self setNum];
    [_camera startPreview];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_camera stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


void sortCorners(std::vector<cv::Point2f>& corners,
                 cv::Point2f center)
{
    std::vector<cv::Point2f> top, bot;
    
    for (int i = 0; i < corners.size(); i++)
    {
        if (corners[i].y < center.y)
            top.push_back(corners[i]);
        else
            bot.push_back(corners[i]);
    }
    corners.clear();
    
    if (top.size() == 2 && bot.size() == 2){
        cv::Point2f tl = top[0].x > top[1].x ? top[1] : top[0];
        cv::Point2f tr = top[0].x > top[1].x ? top[0] : top[1];
        cv::Point2f bl = bot[0].x > bot[1].x ? bot[1] : bot[0];
        cv::Point2f br = bot[0].x > bot[1].x ? bot[0] : bot[1];
        
        
        corners.push_back(tl);
        corners.push_back(tr);
        corners.push_back(br);
        corners.push_back(bl);
    }
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return finalImage;
}
- (IBAction)chosePicture:(id)sender {
    imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
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


-(void)dismissImagePickerController{
//    self.navigationController.navigationBarHidden = YES;
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
    [self addPhoto:image fromSystmPicture:YES];
    [self dismissImagePickerController];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [self dismissImagePickerController];
}

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    if(assets.count > 0){
        for (ALAsset* asset in assets) {
            long long imageDataSize = [[asset defaultRepresentation] size];
            uint8_t* imageDataBytes = (uint8_t*)malloc(imageDataSize);
            [[asset defaultRepresentation] getBytes:imageDataBytes fromOffset:0 length:imageDataSize error:nil];
            NSData *data = [NSData dataWithBytesNoCopy:imageDataBytes length:imageDataSize freeWhenDone:YES];
            UIImage* image = [UIImage imageWithData:data];
            [self addPhoto:image fromSystmPicture:YES];
        }
        [self dismissImagePickerController];
        JavaUtilArrayList* arrays = [photosManager getAllPhotos];
        int count = [arrays size] + (int)assets.count;
        if(count > 0){
            NSString* text = nil;
            if(count <= 99){
                text = [NSString stringWithFormat:@"%d",count];
            }else{
                text = @"99+";
            }
            [Tools Post:^{
                 self.savedNumlable.hidden = NO;
                [self.savedNumlable setText:text];
            } Delay:0.5f];
        }else{
            self.savedNumlable.hidden = YES;
        }

    } 
}
- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [self dismissImagePickerController];
}

- (IBAction)showSaved:(id)sender {
    [self.navigationController pushViewController:[[PhotosViewController alloc] init] animated:YES];
}


-(void)dialogOk
{
//    [[ComFqLibToolsConstants getUser] setOnlyWifiWithBoolean:NO];
    [SettingViewController setOnlyWifi:NO];
    [photosManager checkLoading];
    if(dialog){
        [dialog close];
        dialog = nil;
    }
}

-(void)dialogCannel
{
    if(dialog){
        [dialog close];
        dialog = nil;
    }
}

-(void)addPhoto:(UIImage*)image fromSystmPicture:(BOOL)sp
{
    if(!image) return;
    BOOL settting = [ComFqLibToolsConstants getUser].isOnlyWifi;
    
    if(settting && [[ComFqLibPlatformPlatform getInstance] getNetworkState] == ComFqLibPlatformPlatform_get_NETWORKSATE_OTHER_()){
        [Tools Post:^{
            dialog = [[UIAlertViewTool getInstance] showZbarDialog:@"当前正使用移动网络，是否确定上传图片" target:self actionOk:@selector(dialogOk) actionCancle:@selector(dialogCannel) actionOkStr:@"确认（不再提醒）" actionCancelStr:@"取消"];
        } Delay:.8f];
    }
    if(!sp){
        addImage = YES;
        preImageView.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
        [preImageView setImage:image];
        [self.containerView addSubview:preImageView];
        [UIView animateWithDuration:1.f animations:^{
            CGRect des =[[_savedBtn superview] convertRect:_savedBtn.frame toView:self.containerView];
            preImageView.frame = des;
        } completion:^(BOOL finished) {
            [preImageView removeFromSuperview];
            preImageView.image = nil;
            NSString* localPath = [Tools saveImage:image];
            [photosManager addPhotoWithNSString:localPath];
            [self setNum];
            addImage = NO;
        }];
        
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString* localPath = [Tools saveImage:image];
            dispatch_async(dispatch_get_main_queue(), ^{
                [photosManager addPhotoWithNSString:localPath];
            });
        });
    }
   
}

-(void)setNum
{
    JavaUtilArrayList* arrays = [photosManager getAllPhotos];
    int count = [arrays size];
    if(count > 0){
        self.savedNumlable.hidden = NO;
        NSString* text = nil;
        if(count <= 99){
            text = [NSString stringWithFormat:@"%d",count];
        }else{
            text = @"99+";
        }
        self.savedNumlable.text = text;
    }else{
        self.savedNumlable.hidden = YES;
    }
}

- (UIImage*) imageFromSampleBuffer:(CVImageBufferRef) imageBuffer // Create a CGImageRef from sample buffer data
{
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);   // Get information of the image
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);

    UIImage* image = [UIImage imageWithCGImage:newImage];
    CGImageRelease( newImage );
    return image;

}

-(void)adjust:(cv::Mat&)src
{
    CGSize frameSize = self.camera.frame.size;
    CGSize imageSize = CGSizeMake(src.cols, src.rows);
    if(frameSize.width / imageSize.width != frameSize.height / imageSize.height){
        CGFloat dstY = imageSize.width*frameSize.height/frameSize.width;
        CGFloat offset = (imageSize.height - dstY) / 2.f;
        if(offset < 0){
            CGFloat dstX = frameSize.width * imageSize.height / frameSize.height;
            offset = (imageSize.width - dstX) / 2.f;
            src = cv::Mat(src,cv::Range(0,src.rows),cv::Range(offset,src.cols-offset));
        }else {
            src = cv::Mat(src,cv::Range(offset,src.rows - offset),cv::Range(0,src.cols));
        }
    }
}

- (void)processImage:(CVImageBufferRef)imagebuffer{
    if(!autoShear) {
        std::vector<cv::Point2f> points;
        [_coverView setPoints:points Larged:false arcLength:0];
        return;
    }
    if(alertView) return;
    UIImage* image = [self imageFromSampleBuffer:imagebuffer];
    cv::Mat src = [self cvMatFromUIImage:image];
    [self adjust:src];
    _coverView.iamgeSize = image.size;
    image = nil;
    cv::Mat dst = src.clone();
    cv::cvtColor(dst, dst ,CV_BGR2GRAY);//转化为灰度空间
    cv::resize(src,src,cv::Size(288,352));
    std::vector<cv::Point> square;
    if(ISLARGETHANIOS8){
        cv::CameraScanner::findLargeSquare([self UIImageFromCVMat:src], square);
    }else{
        cv::CameraScanner::findLargeSquare(src, square);
    }
    _coverView.calculateImageSize =  CGSizeMake(src.cols, src.rows);
    float lenth = fabs(arcLength(cv::Mat(square),true));
    BOOL isLarged = lenth > 622;
    std::vector<cv::Point2f> points;
    rect = square;
    if(square.size() > 0){
        for (int i = 0; i < square.size(); i++) {
            cv::Point p = square[i];
            points.push_back(cv::Point2f(p.x,p.y));
        }
        
        do{
            cv::Size srcSize = src.size();
            cv::Size dstSize = dst.size();
            float wScale = dstSize.width / (float)srcSize.width;
            float hScale = dstSize.height / (float)srcSize.height;
            std::vector<cv::Point2f> square2;
            for (int i = 0; i < square.size(); i++) {
                square2.push_back(cv::Point2f(square[i].x*wScale,square[i].y*hScale));
            }
            cv::Point2f center(0,0);
            for (int i = 0; i < square2.size(); i++)
                center += square2[i];
            center *= (1. / square2.size());
            sortCorners(square2, center);
            if(square2.size() != 4){
                points.clear();
                [_coverView setPoints:points Larged:isLarged arcLength:lenth];
                break;
            }
            [_coverView setPoints:points Larged:isLarged arcLength:lenth];
            CGSize siz = getShearImageSize(square2);
            cv::Mat quad = cv::Mat::zeros(siz.height, siz.width, CV_8UC3);
            std::vector<cv::Point2f> quad_pts;
            quad_pts.push_back(cv::Point2f(0, 0));
            quad_pts.push_back(cv::Point2f(quad.cols, 0));
            quad_pts.push_back(cv::Point2f(quad.cols, quad.rows));
            quad_pts.push_back(cv::Point2f(0, quad.rows));
            cv::Mat transmtx = cv::getPerspectiveTransform(square2, quad_pts);
            cv::warpPerspective(dst, quad, transmtx, quad.size());
//            return;
             if(!_camera.isAdjustingFocus && [_coverView canShear]){
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self takePhotoAndShear];
                 });
             }
        }while (0) ;
    }else{
        [_coverView setPoints:points Larged:isLarged arcLength:lenth];
    }
}

-(BOOL)inFcous //是否在聚焦
{
    if(focus.size() > 3){
        focus.erase(focus.begin());
    }else{
        return YES;
    }
    for (int i = 0; i < focus.size(); i++) {
        bool f = focus[i];
        if(f)return YES;
    }
    return NO;
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    image = [image fixOrientation];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}

-(void)takePhotoAndShear{
    if(!alertView)alertView =  [[UIAlertViewTool getInstance] showLoadingDialog:@"拍照中···"];
    [_camera takePhoto:^(UIImage * image) {
        if(alertView) {
            [alertView close];
            alertView = nil;
        }
        cv::Mat src = [self cvMatFromUIImage:image];
        [self adjust:src];
        cv::Mat dst =src;
        cv::cvtColor(dst, dst ,CV_BGR2GRAY);//转化为灰度空间
        cv::resize(src,src,cv::Size(288,352));
        _coverView.calculateImageSize =  CGSizeMake(src.cols, src.rows);;
        auto shear = [&](std::vector<cv::Point>& square){
            std::vector<cv::Point2f> points;
            if(square.size() > 0){
                for (int i = 0; i < square.size(); i++) {
                    cv::Point p = square[i];
                    points.push_back(cv::Point2f(p.x,p.y));
                }
                do{
                    cv::Size srcSize = src.size();
                    cv::Size dstSize = dst.size();
                    float wScale = dstSize.width / (float)srcSize.width;
                    float hScale = dstSize.height / (float)srcSize.height;
                    std::vector<cv::Point2f> square2;
                    for (int i = 0; i < square.size(); i++) {
                        square2.push_back(cv::Point2f(square[i].x*wScale,square[i].y*hScale));
                    }
                    cv::Point2f center(0,0);
                    for (int i = 0; i < square2.size(); i++)
                        center += square2[i];
                    center *= (1. / square2.size());
                    sortCorners(square2, center);
                    if(square2.size() != 4){
                        points.clear();
                        break;
                    }
                    CGSize siz = getShearImageSize(square2);
                    //                return ;
                    cv::Mat quad = cv::Mat::zeros(siz.height, siz.width, CV_8UC3);
                    std::vector<cv::Point2f> quad_pts;
                    quad_pts.push_back(cv::Point2f(0, 0));
                    quad_pts.push_back(cv::Point2f(quad.cols, 0));
                    quad_pts.push_back(cv::Point2f(quad.cols, quad.rows));
                    quad_pts.push_back(cv::Point2f(0, quad.rows));
                    cv::Mat transmtx = cv::getPerspectiveTransform(square2, quad_pts);
                    cv::warpPerspective(dst, quad, transmtx, quad.size());
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImage* cImage = [self UIImageFromCVMat:quad];
                        PRINT_SIZE(cImage.size);
                        [self addPhoto:cImage fromSystmPicture:NO];
                    });
                    return true;
                }while (0) ;
               
            }
            return false;
        };
        
        std::vector<cv::Point> square;
        if(ISLARGETHANIOS8){
            cv::CameraScanner::findLargeSquare([self UIImageFromCVMat:src], square);
        }else{
            cv::CameraScanner::findLargeSquare(src, square);
        }
        if(!shear(square)){
            shear(rect);
        }
    } playSound:NO];
}

-(NSArray*)getEdge:(UIImage*)image{
    NSMutableArray* points = [[NSMutableArray alloc] init];
    cv::Mat src = [self cvMatFromUIImage:image];
    [self adjust:src];
    cv::resize(src,src,cv::Size(288,352));
    std::vector<cv::Point> square;
    if(ISLARGETHANIOS8){
        cv::CameraScanner::findLargeSquare(image, square);
    }else{
         cv::CameraScanner::findLargeSquare(src, square);
    }
    if(square.size() != 4) return points;
    cv::Size srcSize = src.size();
    cv::Size dstSize = cv::Size(_camera.frame.size.width,_camera.frame.size.height);
    float wScale = dstSize.width / (float)srcSize.width;
    float hScale = dstSize.height / (float)srcSize.height;
    for (int i = 0; i < square.size(); i++) {
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(square[i].x*wScale,square[i].y*hScale)]];
    }
    return points;
}

-(UIImage*)shearImage:(UIImage*)image withPoints:(NSArray*)points
{
    if(points.count != 4) return nil;
    cv::Mat src = [self cvMatFromUIImage:image];
    [self adjust:src];
    cv::cvtColor(src, src ,CV_BGR2GRAY);//转化为灰度空间
    std::vector<cv::Point2f> square;
    cv::Size srcSize = src.size();
    CGFloat scaleX = srcSize.width / self.camera.frame.size.width;
    CGFloat scaleY = srcSize.height / self.camera.frame.size.height;
    for (NSValue* p in points) {
        CGPoint point = p.CGPointValue;
        square.push_back(cv::Point(point.x*scaleX,point.y*scaleY));
    }
    cv::Point2f center(0,0);
    for (int i = 0; i < square.size(); i++)
        center += square[i];
    center *= (1. / square.size());
    sortCorners(square, center);
    CGSize siz = getShearImageSize(square);
    cv::Mat quad = cv::Mat::zeros(siz.height, siz.width, CV_8UC3);
    std::vector<cv::Point2f> quad_pts;
    quad_pts.push_back(cv::Point2f(0, 0));
    quad_pts.push_back(cv::Point2f(quad.cols, 0));
    quad_pts.push_back(cv::Point2f(quad.cols, quad.rows));
    quad_pts.push_back(cv::Point2f(0, quad.rows));
    cv::Mat transmtx = cv::getPerspectiveTransform(square, quad_pts);
    cv::warpPerspective(src, quad, transmtx, quad.size());
    UIImage* cImage = [self UIImageFromCVMat:quad];
    return cImage;
}

CGSize getShearImageSize(std::vector<cv::Point2f>& points){
    return CGSizeMake(fabs(points[0].x-points[1].x),fabs(points[1].y-points[2].y));
}



@end
