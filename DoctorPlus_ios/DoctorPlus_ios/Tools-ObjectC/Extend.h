//
//  Extend.h
//  DoctorPlus_ios
//
//  Created by niko on 15/6/2.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IOSPrimitiveArray.h"
#import "IOSObjectArray.h"

@interface Extend : NSObject

+(void)setJavaIntArrayValue:(int)value forIndex:(int)index forArray:(IOSIntArray*)array;
+(void)setJavaObjectArrayValue:(id)value forIndex:(int)index forArray:(IOSObjectArray*)array;
@end
