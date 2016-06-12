//
//  UIImage+Thumbnail.h
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/5/22.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Thumbnail)

- (UIImage *)fixOrientation;

+(UIImage*)createThumbnailImageFromFile:(NSString*)path MaxWidth:(CGFloat)width;

+(UIImage*)createThumbnailImage:(UIImage*)image WidthWidth:(CGFloat)width;

+(UIImage*)createThumbnailImageFromFile:(NSString*)path MaxWidth:(CGFloat)width UseCache:(BOOL)fromCache;

+(void)createThumbnailImageFromFile:(NSString*)path MaxWidth:(CGFloat)width completed:(void (^)(UIImage* image))complete;

@end
