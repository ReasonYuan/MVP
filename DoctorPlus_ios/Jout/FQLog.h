//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/lib/tools/FQLog.java
//
//  Created by liaomin on 15-5-4.
//

#ifndef _ComFqLibToolsFQLog_H_
#define _ComFqLibToolsFQLog_H_

#import "JreEmulation.h"

#define ComFqLibToolsFQLog_DEBUG TRUE

@interface ComFqLibToolsFQLog : NSObject {
}

+ (void)printWithNSString:(NSString *)TAG
             withNSString:(NSString *)msg;

+ (void)iWithNSString:(NSString *)msg;

+ (void)iWithNSString:(NSString *)TAG
         withNSString:(NSString *)msg;

+ (void)wWithNSString:(NSString *)TAG
         withNSString:(NSString *)msg;

+ (void)eWithNSString:(NSString *)TAG
         withNSString:(NSString *)msg;

+ (void)vWithNSString:(NSString *)TAG
         withNSString:(NSString *)msg;

- (id)init;

@end

__attribute__((always_inline)) inline void ComFqLibToolsFQLog_init() {}

J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsFQLog, DEBUG, BOOL)

#endif // _ComFqLibToolsFQLog_H_