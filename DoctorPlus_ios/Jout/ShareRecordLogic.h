//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/logic2/ShareRecordLogic.java
//
//  Created by liaomin on 15-5-4.
//

#ifndef _ComFqHalcyonLogic2ShareRecordLogic_H_
#define _ComFqHalcyonLogic2ShareRecordLogic_H_

@class ComFqHalcyonLogic2ShareRecordLogic_ShareRecordHandle;
@class JavaLangThrowable;
@class JavaUtilArrayList;
@protocol ComFqHalcyonLogic2ShareRecordLogic_ShareRecordCallBack;

#import "JreEmulation.h"
#include "HalcyonHttpResponseHandle.h"

@interface ComFqHalcyonLogic2ShareRecordLogic : NSObject {
 @public
  __weak id<ComFqHalcyonLogic2ShareRecordLogic_ShareRecordCallBack> onCallBack_;
  ComFqHalcyonLogic2ShareRecordLogic_ShareRecordHandle *mHandle_;
}

- (id)initWithComFqHalcyonLogic2ShareRecordLogic_ShareRecordCallBack:(id<ComFqHalcyonLogic2ShareRecordLogic_ShareRecordCallBack>)onCallBack;

- (void)sharePatientWithInt:(int)patientId
      withJavaUtilArrayList:(JavaUtilArrayList *)doctorIds;

- (void)shareRecordWithJavaUtilArrayList:(JavaUtilArrayList *)recordIds
                   withJavaUtilArrayList:(JavaUtilArrayList *)doctorIds;

- (void)shareRecordItemWithJavaUtilArrayList:(JavaUtilArrayList *)recordItemIds
                       withJavaUtilArrayList:(JavaUtilArrayList *)doctorIds;

- (void)copyAllFieldsTo:(ComFqHalcyonLogic2ShareRecordLogic *)other;

@end

__attribute__((always_inline)) inline void ComFqHalcyonLogic2ShareRecordLogic_init() {}

J2OBJC_FIELD_SETTER(ComFqHalcyonLogic2ShareRecordLogic, mHandle_, ComFqHalcyonLogic2ShareRecordLogic_ShareRecordHandle *)

@protocol ComFqHalcyonLogic2ShareRecordLogic_ShareRecordCallBack < NSObject, JavaObject >

- (void)shareRecordErrorWithInt:(int)code
                   withNSString:(NSString *)msg;

- (void)shareRecordSuccessWithInt:(int)code
                     withNSString:(NSString *)msg;

@end

__attribute__((always_inline)) inline void ComFqHalcyonLogic2ShareRecordLogic_ShareRecordCallBack_init() {}

@interface ComFqHalcyonLogic2ShareRecordLogic_ShareRecordHandle : HalcyonHttpResponseHandle {
 @public
  ComFqHalcyonLogic2ShareRecordLogic *this$0_;
}

- (void)onErrorWithInt:(int)code
 withJavaLangThrowable:(JavaLangThrowable *)e;

- (void)handleWithInt:(int)responseCode
         withNSString:(NSString *)msg
              withInt:(int)type
               withId:(id)results;

- (id)initWithComFqHalcyonLogic2ShareRecordLogic:(ComFqHalcyonLogic2ShareRecordLogic *)outer$;

@end

__attribute__((always_inline)) inline void ComFqHalcyonLogic2ShareRecordLogic_ShareRecordHandle_init() {}

J2OBJC_FIELD_SETTER(ComFqHalcyonLogic2ShareRecordLogic_ShareRecordHandle, this$0_, ComFqHalcyonLogic2ShareRecordLogic *)

#endif // _ComFqHalcyonLogic2ShareRecordLogic_H_