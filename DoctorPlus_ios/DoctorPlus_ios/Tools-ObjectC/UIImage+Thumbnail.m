//
//  UIImage+Thumbnail.m
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/5/22.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "UIImage+Thumbnail.h"
#import <ImageIO/ImageIO.h>
#import "Tools.h"

@implementation UIImage (Thumbnail)


- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+(UIImage*)createThumbnailImageFromFile:(NSString*)filePath MaxWidth:(CGFloat)width
{
    return [UIImage createThumbnailImageFromFile:filePath MaxWidth:width UseCache:NO];
}


+(UIImage*)createThumbnailImageFromFile:(NSString *)filePath MaxWidth:(CGFloat)width UseCache:(BOOL)fromCache
{
    if(!filePath)return nil;
    if(fromCache){
        id cache = [Tools getObjectForKey:filePath];
        if(cache && [cache isKindOfClass:[UIImage class]]){
            return (UIImage*)cache;
        }
    }
    // use ImageIO to get a thumbnail for a file at a given path
    CGImageSourceRef    imageSource = nil;
    NSString *          path = [filePath stringByExpandingTildeInPath];//格式化路径
    CGImageRef          thumbnail = nil;
    // Create a CGImageSource from the URL.
    imageSource = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath: path], NULL);
    if (imageSource == NULL)
    {
        return nil;
    }
    CFStringRef imageSourceType = CGImageSourceGetType(imageSource);
    if (imageSourceType == NULL)
    {
        CFRelease(imageSource);
        return nil;
    }
    CFRelease(imageSourceType);
    CGFloat scale = [UIScreen mainScreen].scale;
    
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], (NSString *)kCGImageSourceCreateThumbnailFromImageAlways,
                             [NSNumber numberWithBool:YES], (NSString *)kCGImageSourceCreateThumbnailWithTransform,
                             [NSNumber numberWithFloat:width*scale], (NSString *)kCGImageSourceThumbnailMaxPixelSize, //new image size 800*600
                             nil];
    //create thumbnail picture
    thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (CFDictionaryRef)options);
    CFRelease(imageSource);
    UIImage* thumbnailImage = [UIImage imageWithCGImage:thumbnail];
    CGImageRelease(thumbnail);
    if(fromCache){
        [Tools cacheObject:thumbnailImage ForKey:filePath];
    }
    return thumbnailImage;
}

+(void)createThumbnailImageFromFile:(NSString *)filePath MaxWidth:(CGFloat)width completed:(void (^)(UIImage* image))complete
{
    [Tools runOnOtherThread:^id{
            return [self createThumbnailImageFromFile:filePath MaxWidth:width UseCache:YES];
    } callback:^(id image) {
        if(complete)complete(image);
    }];
}



+(UIImage*)createThumbnailImage:(UIImage *)image WidthWidth:(CGFloat)width
{
    CGSize size = CGSizeMake(width, width);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
