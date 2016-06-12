//
//  CameraView.m
//  CameraWithAVFoudation
//
//  Created by Reason on 15-01-20.
//
//

#import "CameraView.h"
#import "FileSystem.h"
#import "java/lang/system.h"
#import "Tools.h"

@interface CameraView ()
{
    long long int lastCapture;
    CGFloat captureInterval;
    BOOL isFocus;
}

@end

 static SystemSoundID soundID = 0;

@implementation CameraView

@synthesize preview;

-(void)takePhoto:(void (^)(UIImage *))completion  playSound:(BOOL)play
{
    if( !play ){
        AudioServicesPlaySystemSound(soundID);
    }

    //get connection
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    if(videoConnection){
        if([captureOutput isCapturingStillImage]) return;
        [captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
         ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
             if( error == nil &&imageSampleBuffer ){
                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                 UIImage *image = [UIImage imageWithData:imageData];
                 completion(image);
             }
         }];
        @try {
            if(_enableFlash){
                [device setTorchModeOnWithLevel:0.8 error:nil];
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
       
    }else{
         completion(nil);
    }
    self.enableFlash = NO;
}



-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) [self onViewCreate];
    return  self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self onViewCreate];
    return self;
}

-(void)onViewCreate{
    if (soundID == 0) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"photoShutter2" ofType:@"caf"];
        NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    }
    isFocus = NO;
    captureInterval = 1000/5.f;
    lastCapture = [JavaLangSystem currentTimeMillis];
    self.alpha = 1;
    _autoFocus = YES;
    _enableFlash = NO;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapGestureRecognizer addTarget:self action:@selector(touchGestureHandle:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    
    // 开始实时取景
    //1.创建会话层
    session = [[AVCaptureSession alloc] init];
    if ([session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
        session.sessionPreset = AVCaptureSessionPresetPhoto;
    } else if([session canSetSessionPreset:AVCaptureSessionPresetHigh]){
        [session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    
    //2.创建、配置输入设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *tmp in devices)
    {
        if ([tmp position] == AVCaptureDevicePositionBack)
        {
            device = tmp;
        }
    }
    if(!device)device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device lockForConfiguration:nil]) {
        
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        
        if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }

        [device unlockForConfiguration];
    }

    
    NSError *error;
    captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!captureInput)
    {
        NSLog(@"Error: %@", error);
        return;
    }
    [session addInput:captureInput];
    
    //3.创建、配置输出
    captureOutput = [[AVCaptureStillImageOutput alloc] init];

    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [captureOutput setOutputSettings:outputSettings];
    [session addOutput:captureOutput];
    

    AVCaptureVideoDataOutput* avCaptureOutput = [[AVCaptureVideoDataOutput alloc] init];
    avCaptureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [avCaptureOutput setSampleBufferDelegate:self queue:queue];
    
    avCaptureOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                     nil];
    [session addOutput:avCaptureOutput];
    
    AVCaptureConnection *conn = [avCaptureOutput connectionWithMediaType:AVMediaTypeVideo];

    [conn setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

//int fps = 0;
//long long int last = 0;

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    long long int now = [JavaLangSystem currentTimeMillis];
    if((now - lastCapture >= captureInterval) && self.delegate){
//     fps ++;
//    if(now - last >= 1000){
//        NSLog(@"fps:->%d",fps);
//        fps  = 0;
//        last = now;
//    }
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer,0);
        [self.delegate processImage:imageBuffer];
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        lastCapture = now;
    }
}


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    session = nil;
}

-(void)touchGestureHandle:(UIGestureRecognizer*) gesture{
//    if(!_autoFocus){
        CGPoint touchPoint = [gesture locationInView:self];
        CGPoint pointOfInterest = [self pointOfInterestWithTouchPoint:[gesture locationInView:nil]];
        double focusX = pointOfInterest.y;
        double focusY = 1 - pointOfInterest.x;
        pointOfInterest.x = focusX;
        pointOfInterest.y = focusY;
        if([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [self showFocusView:self withTouchPoint:touchPoint];
            if([device lockForConfiguration:nil]) {
                
                if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                    [device setFocusPointOfInterest:pointOfInterest];
                    [device setFocusMode:AVCaptureFocusModeAutoFocus];
                   
                }
                
                if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                    [device setExposurePointOfInterest:pointOfInterest];
                    [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                }

            }
            [device unlockForConfiguration];
        }
//    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if( [keyPath isEqualToString:@"adjustingFocus"] ){
        isFocus = [ [change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];
        if(!isFocus && self.autoFocus && device){
//            [self showFocusView:self withTouchPoint:CGPointMake(self.frame.size.width/2.f, self.frame.size.height/2.f)];
            if ([device lockForConfiguration:nil]) {

                if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                    [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                }
                
                if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                    [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                }
                
                [device unlockForConfiguration];
            }

        }
    }
}


-(BOOL)isAdjustingFocus
{
    return isFocus;
}

- (CGPoint)pointOfInterestWithTouchPoint:(CGPoint)touchPoint
{
    CGSize screenSize = [UIScreen.mainScreen bounds].size;
    
    CGPoint pointOfInterest;
    pointOfInterest.x = touchPoint.x / screenSize.width;
    pointOfInterest.y = touchPoint.y / screenSize.height;
    
    return pointOfInterest;
}

- (void)showFocusView:(UIView *)focusView withTouchPoint:(CGPoint)touchPoint
{
    CGFloat width = self.frame.size.width / 6.f;
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    view.center = touchPoint;
    view.tag = -1;
    view.image = [UIImage imageNamed:@"camera_focus_kuang.png"];
    UIImageView *plusView = [[UIImageView alloc] initWithFrame:CGRectMake(width/3.f,width/3.f, width/3.f, width/3.f)];
    plusView.image = [UIImage imageNamed:@"camera_focus_plus.png"];
    [view addSubview:plusView];
    for (id subview in [focusView subviews]) {
        if ([subview tag] == -1) {
            [subview removeFromSuperview];
        }
    }
    [focusView addSubview:view];
    [UIView animateWithDuration:.25f animations:^{
        view.frame = CGRectMake(0, 0, width*.6, width*.6);
        plusView.frame = CGRectMake(width*.6/3.f,width*.6/3.f, width*.6/3.f, width*.6/3.f);
        view.center = touchPoint;
    } completion:^(BOOL finished) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [NSThread sleepForTimeInterval:1];
            while ([device isAdjustingFocus] ||
                   [device isAdjustingExposure] ||
                   [device isAdjustingWhiteBalance]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                view.transform =  CGAffineTransformIdentity;
                [UIView animateWithDuration:.25f animations:^{
                    view.transform = CGAffineTransformScale(view.transform, .01, .01);
                } completion:^(BOOL finished) {
                    if (finished) {
                        [view removeFromSuperview];
                    }
                }];
            });
        });

    }];

}

-(void)layoutSubviews{
    [super layoutSubviews];
    if(preview){
        preview.frame = self.frame;
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
}


-(void)setEnableFlash:(BOOL)enableFlash
{
    if(device && [device lockForConfiguration:nil]) {
        AVCaptureTorchMode torchModel = enableFlash?AVCaptureTorchModeOn:AVCaptureTorchModeOff;
        if([device isTorchModeSupported:torchModel]){
            [device setTorchMode:torchModel];
            _enableFlash = enableFlash;
            if(enableFlash){
                [device setTorchModeOnWithLevel:0.8 error:nil];
            }
        }
        AVCaptureFlashMode flashModel = enableFlash?AVCaptureFlashModeOn:AVCaptureFlashModeOff;
        if([device isFlashModeSupported:flashModel]){
            [device setFlashMode:flashModel];
            
        }
    }
    if(device)[device unlockForConfiguration];

}

-(void)setAutoFocus:(BOOL)autoFocus
{
    _autoFocus = autoFocus;
    @try {
        if(device && [device lockForConfiguration:nil]) {
            [device setFocusMode:_autoFocus?AVCaptureFocusModeAutoFocus:AVCaptureFocusModeLocked];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        if(device)[device unlockForConfiguration];
    }
    
}

-(void)startPreview{
    [self addGestureRecognizer:tapGestureRecognizer];
    [device addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
    [session startRunning];
    if (preview == nil) {
        preview = [AVCaptureVideoPreviewLayer layerWithSession: session];
        preview.frame = self.frame;
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.layer insertSublayer:preview atIndex:0];
    }
}

-(void)stop
{
    [session stopRunning];
    [device removeObserver:self forKeyPath:@"adjustingFocus"];
    [self removeGestureRecognizer:tapGestureRecognizer];
}

- (void)orientationDidChange:(NSNotification *)note
{
    if(!preview) return;
    [CATransaction begin];
    if ( [[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight) {
        g_orientation = UIImageOrientationUp;
        preview.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        
    }else if ( [[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft){
        g_orientation = UIImageOrientationDown;
        preview.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        
    }else if ( [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait){
        g_orientation = UIImageOrientationRight;
        preview.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        
    }else if ( [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown){
        g_orientation = UIImageOrientationLeft;
        preview.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }
    [CATransaction commit];
}

-(void)changeDeivce
{
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *tmpDevice in devices) {
        if ([tmpDevice hasMediaType:AVMediaTypeVideo]) {
            if (device != tmpDevice) {
                device = tmpDevice;
                [session beginConfiguration];
                [session removeInput:captureInput];
                NSError *error;
                captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                if (!captureInput)
                {
                    NSLog(@"Error: %@", error);
                    return;
                }
                [session addInput:captureInput];
                [session commitConfiguration];
                break;
            }
        }
    }

}

-(void)foucusStatus:(BOOL)isadjusting
{
    
}

@end

@interface CameraArcView()
{
    UIColor* mColor;
}

@end

@implementation CameraArcView

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:[UIColor clearColor]];
    mColor = backgroundColor;
}

-(void)drawRect:(CGRect)rect
{
    if(self.hidden) return;
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context)
    {
        [mColor set];
        CGFloat width = rect.size.width;
        CGFloat heigth = rect.size.height;
        
        CGFloat r = sqrt(width*width+heigth*heigth)/2.f;
        CGContextAddArc(context, width/2.f, r, r, 0, 2*M_PI, 0);
        CGContextDrawPath(context, kCGPathFill);
    }

}

@end
