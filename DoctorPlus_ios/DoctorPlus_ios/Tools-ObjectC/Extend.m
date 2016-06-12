//
//  Extend.m
//  DoctorPlus_ios
//
//  Created by niko on 15/6/2.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "Extend.h"

@implementation Extend

+(void)setJavaIntArrayValue:(int)value forIndex:(int)index forArray:(IOSIntArray *)array
{
    if(array->size_ > index){
        array->buffer_[index] = value;
    }
}

+(void)setJavaObjectArrayValue:(id)value forIndex:(int)index forArray:(IOSObjectArray*)array{
    if(array->size_ > index){
        array->buffer_[index] = value;
    }
}

@end
