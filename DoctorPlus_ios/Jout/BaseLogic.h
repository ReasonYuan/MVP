//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/logic/BaseLogic.java
//
//  Created by liaomin on 15-5-4.
//

#ifndef _ComFqHalcyonLogicBaseLogic_H_
#define _ComFqHalcyonLogicBaseLogic_H_

@class JavaLangThrowable;

#import "JreEmulation.h"

@protocol ComFqHalcyonLogicBaseLogic < NSObject, JavaObject >

- (void)updateUIWithInt:(int)type;

- (void)onLogicErrorWithInt:(int)code
      withJavaLangThrowable:(JavaLangThrowable *)e;

@end

__attribute__((always_inline)) inline void ComFqHalcyonLogicBaseLogic_init() {}

#endif // _ComFqHalcyonLogicBaseLogic_H_