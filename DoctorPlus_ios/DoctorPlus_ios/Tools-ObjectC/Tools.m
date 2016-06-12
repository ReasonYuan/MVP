//
//  Tools.m
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/5/22.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "Tools.h"
#import "Platform.h"
#import "FileSystem.h"
#import "java/lang/system.h"
#import "java/util/UUID.h"
#import "Constants.h"

@implementation Tools

+(void)runOnOtherThread:(id (^)(void))run callback:(void (^)(id))callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        id value = run();
        dispatch_async(dispatch_get_main_queue(), ^{
            if(callback){
                callback(value);
            }
        });
    });
}

+(void)Post:(void (^)())run Delay:(NSTimeInterval)delay
{
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delay * NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^{
        if(run){
            run();
        }

    });
}

+(CGFloat)getMaxFontSizeInRect:(CGRect)rect
{
    static NSString* measureText = @"A";
    CGFloat defaultSize = 18.f;
    CGFloat rectHeight = CGRectGetHeight(rect);
    CGSize size = [measureText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:defaultSize]}];
    if(size.height == rectHeight)return defaultSize;
    if(size.height > rectHeight){
        while (size.height > rectHeight) {
            defaultSize --;
            size = [measureText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:defaultSize]}];
        }
    }else{
        while (size.height < rectHeight) {
            defaultSize ++;
            size = [measureText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:defaultSize]}];
        }
    }
    return  defaultSize;
}

+(CGSize)measureText:(NSString *)text Font:(UIFont *)font
{
    return [text sizeWithAttributes:@{NSFontAttributeName:font}];
}


+(CGFloat)measureText:(NSString*)text font:(UIFont*)font width:(CGFloat)width {
    CGSize constraint = CGSizeMake(width , 20000.0f);
    CGSize title_size;
    float totalHeight;
    
    SEL selector = @selector(boundingRectWithSize:options:attributes:context:);
    if ([text respondsToSelector:selector]) {
        title_size = [text boundingRectWithSize:constraint
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{ NSFontAttributeName : font }
                                        context:nil].size;
        
        totalHeight = ceil(title_size.height);
    } else {
        title_size = [text sizeWithFont:font
                      constrainedToSize:constraint
                          lineBreakMode:NSLineBreakByWordWrapping];
        totalHeight = title_size.height ;
    }
    
    CGFloat height = MAX(totalHeight, 40.0f);
    return height;
}

static NSMapTable* memoryCache = nil;

+(void)cacheObject:(id)obj ForKey:(id)key
{
    if(!memoryCache){
        memoryCache = [NSMapTable strongToWeakObjectsMapTable];
    }
    
    [memoryCache setObject:obj forKey:key];
    
}

+(id)getObjectForKey:(id)key
{
    if(!memoryCache){
        memoryCache = [NSMapTable strongToWeakObjectsMapTable];
    }
    
    return [memoryCache objectForKey:key];
}



+(UIImage*)createNinePathImageForImage:(UIImage *)image LeftMargin:(CGFloat)left RightMargin:(CGFloat)right TopMargin:(CGFloat)top BottomMargin:(CGFloat)bottom
{
    if(image){
        NSString* key = [NSString stringWithFormat:@"%ld",[image hash]];
        id cache = [self getObjectForKey:key];
        if(cache && [cache isKindOfClass:[UIImage class]]){
            return (UIImage*)cache;
        }else{
            UIImage* ninePathImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right)];
            [self cacheObject:ninePathImage ForKey:key];
            return ninePathImage;
        }
    };
    return nil;
}

+(BOOL)isNetWorkConnect{
    return ComFqLibPlatformPlatform_get_isNetWorkConnect_();
}

+(BOOL)isWifiConnect
{
    return ComFqLibPlatformPlatform_get_isNetWorkConnect_() && (ComFqLibPlatformPlatform_get_NETWORKSATE_WIFI_() == [[ComFqLibPlatformPlatform getInstance] getNetworkState]);
}

+(NSArray*)toNSarray:(JavaUtilArrayList*)javaArray
{
    NSMutableArray* nsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [javaArray size]; i++) {
        [nsArray addObject:[javaArray getWithInt:i]];
    }
    return nsArray;
}


+(NSString*)saveImage:(UIImage*)image
{
//    long long int time =[JavaLangSystem currentTimeMillis]+arc4random();
    NSString* pathInRecordCachePath = [NSString stringWithFormat:@"%@.jpg",[[JavaUtilUUID randomUUID] description]];
    NSString* filepath = [NSString stringWithFormat:@"%@%@",[[ComFqHalcyonExtendFilesystemFileSystem getInstance] getRecordCachePath],pathInRecordCachePath];
    [UIImageJPEGRepresentation(image, 1) writeToFile:filepath atomically:YES];
    return pathInRecordCachePath;
}


+(UIViewController*)getCurrentViewController:(UIView*)sourceView{
    //  return  ((AppDelegate*)[UIApplication sharedApplication].delegate).nav.visibleViewController;
    id target=sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

+(UIViewController*)getCurrentViewController{
    UIWindow* window =  [[[UIApplication sharedApplication] windows] firstObject];
    
//    do{
        if(window){
            UINavigationController* na = nil;
            if([window.rootViewController isKindOfClass:[UINavigationController class]]){
                na = (UINavigationController*)window.rootViewController;
            }else{
                na = window.rootViewController.navigationController;
            }
            if(na){
                UIViewController* currentController = [na.viewControllers lastObject];
                if(currentController){
//                    [currentController.view addSubview:self];
                    return currentController;
//                    break;
                }
            }
        }
    return nil;
//        [window addSubview:self];
//    }while (0);

}

+(BOOL)getProductionEnvironment:(int)production{
    if(production == 1) {
        return YES;
    }else if(production == 0) {
        return NO;
    }
    return NO;
}

+(NSString*)getChannel{
    if (ComFqLibToolsConstants_isInhouse_) {
        return @"Inhouse";
    }else{
        return @"AppStore";
    }
}

+(NSString*)getAppVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

#define DEFAULT_VOID_COLOR [UIColor whiteColor]
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    
    if ([cString length] < 6)
        return DEFAULT_VOID_COLOR;
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return DEFAULT_VOID_COLOR;
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}


+ (UIImage *) image:(UIImage*)image withTintColor:(UIColor *)tintColor
{
    return [self image:image withTintColor:tintColor blendMode:kCGBlendModeDestinationIn];
}

+ (UIImage *) image:(UIImage*)image withGradientTintColor:(UIColor *)tintColor
{
    return [self image:image withTintColor:tintColor blendMode:kCGBlendModeOverlay];
}

+ (UIImage *) image:(UIImage*)image withTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [image drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn) {
        [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}


@end
