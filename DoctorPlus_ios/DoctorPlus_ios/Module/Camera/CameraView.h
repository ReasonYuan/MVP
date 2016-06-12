//
//  CameraView.h
//  ;
//
//  Created by liaomin on 14-9-25.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraArcView : UIView

@end

@protocol CameraViewDelegate <NSObject>

- (void)processImage:(CVImageBufferRef)imagebuffer;

@end

@interface CameraView : UIView<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession *session;
    AVCaptureStillImageOutput *captureOutput;
    UIImageOrientation g_orientation;
    AVCaptureDevice *device ;
    AVCaptureDeviceInput *captureInput;
    UITapGestureRecognizer *tapGestureRecognizer;
}

@property (nonatomic, weak) AVCaptureVideoPreviewLayer *preview;

@property (nonatomic,assign) id<CameraViewDelegate> delegate;

@property (nonatomic,assign) BOOL autoFocus;//是否自动聚焦

@property (nonatomic,assign) BOOL enableFlash;//是否开启闪光灯

@property (nonatomic,readonly) BOOL isAdjustingFocus;

-(void)stop;
-(void)changeDeivce;
-(void)takePhoto:(void (^)(UIImage *))completion playSound:(BOOL)play;
-(void)startPreview;
@end
