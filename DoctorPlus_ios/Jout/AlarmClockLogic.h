//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/logic2/AlarmClockLogic.java
//
//  Created by liaomin on 15-5-4.
//

#ifndef _ComFqHalcyonLogic2AlarmClockLogic_H_
#define _ComFqHalcyonLogic2AlarmClockLogic_H_

@class ComFqHalcyonLogic2AlarmClockLogic_AlarmClockLogicHandle;
@class JavaLangThrowable;
@protocol ComFqHalcyonLogic2AlarmClockLogic_AlarmClockLogicCallBack;
@protocol JavaUtilList;

#import "JreEmulation.h"
#include "HalcyonHttpResponseHandle.h"

@interface ComFqHalcyonLogic2AlarmClockLogic : NSObject {
 @public
  id<JavaUtilList> mClockList_;
  __weak id<ComFqHalcyonLogic2AlarmClockLogic_AlarmClockLogicCallBack> onCallBack_;
  ComFqHalcyonLogic2AlarmClockLogic_AlarmClockLogicHandle *mHandle_;
}

- (id)initWithComFqHalcyonLogic2AlarmClockLogic_AlarmClockLogicCallBack:(id<ComFqHalcyonLogic2AlarmClockLogic_AlarmClockLogicCallBack>)onCallBack;

- (void)copyAllFieldsTo:(ComFqHalcyonLogic2AlarmClockLogic *)other;

@end

__attribute__((always_inline)) inline void ComFqHalcyonLogic2AlarmClockLogic_init() {}

J2OBJC_FIELD_SETTER(ComFqHalcyonLogic2AlarmClockLogic, mClockList_, id<JavaUtilList>)
J2OBJC_FIELD_SETTER(ComFqHalcyonLogic2AlarmClockLogic, mHandle_, ComFqHalcyonLogic2AlarmClockLogic_AlarmClockLogicHandle *)

@protocol ComFqHalcyonLogic2AlarmClockLogic_AlarmClockLogicCallBack < NSObject, JavaObject >

- (void)onErrorCallBackWithInt:(int)code
                  withNSString:(NSString *)msg;

- (void)onResultCallBackWithInt:(int)code;

@end

__attribute__((always_inline)) inline void ComFqHalcyonLogic2AlarmClockLogic_AlarmClockLogicCallBack_init() {}

@interface ComFqHalcyonLogic2AlarmClockLogic_AlarmClockLogicHandle : HalcyonHttpResponseHandle {
 @public
  ComFqHalcyonLogic2AlarmClockLogic *this$0_;
}

- (void)onErrorWithInt:(int)code
 withJavaLangThrowable:(JavaLangThrowable *)e;

- (void)handleWithInt:(int)responseCode
         withNSString:(NSString *)msg
              withInt:(int)type
               withId:(id)results;

- (id)initWithComFqHalcyonLogic2AlarmClockLogic:(ComFqHalcyonLogic2AlarmClockLogic *)outer$;

@end

__attribute__((always_inline)) inline void ComFqHalcyonLogic2AlarmClockLogic_AlarmClockLogicHandle_init() {}

J2OBJC_FIELD_SETTER(ComFqHalcyonLogic2AlarmClockLogic_AlarmClockLogicHandle, this$0_, ComFqHalcyonLogic2AlarmClockLogic *)

#endif // _ComFqHalcyonLogic2AlarmClockLogic_H_