//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/logic/GetImagePathLogic.java
//
//  Created by liaomin on 15-5-4.
//

#ifndef _ComFqHalcyonLogicGetImagePathLogic_H_
#define _ComFqHalcyonLogicGetImagePathLogic_H_

@class JavaLangThrowable;
@class JavaUtilArrayList;
@protocol ComFqHalcyonLogicGetImagePathLogic_ImagePathCallBack;
@protocol ComFqHalcyonLogicGetImagePathLogic_RecordImageCallback;

#import "JreEmulation.h"
#include "HalcyonHttpResponseHandle.h"

@interface ComFqHalcyonLogicGetImagePathLogic : NSObject {
 @public
  id<ComFqHalcyonLogicGetImagePathLogic_ImagePathCallBack> mCallback_;
}

- (id)init;

- (id)initWithComFqHalcyonLogicGetImagePathLogic_ImagePathCallBack:(id<ComFqHalcyonLogicGetImagePathLogic_ImagePathCallBack>)callback;

- (void)getImagePathWithInt:(int)recordItemId;

- (void)getRecordImagesWithInt:(int)recordId
withComFqHalcyonLogicGetImagePathLogic_RecordImageCallback:(id<ComFqHalcyonLogicGetImagePathLogic_RecordImageCallback>)callback;

- (void)copyAllFieldsTo:(ComFqHalcyonLogicGetImagePathLogic *)other;

@end

__attribute__((always_inline)) inline void ComFqHalcyonLogicGetImagePathLogic_init() {}

J2OBJC_FIELD_SETTER(ComFqHalcyonLogicGetImagePathLogic, mCallback_, id<ComFqHalcyonLogicGetImagePathLogic_ImagePathCallBack>)

@protocol ComFqHalcyonLogicGetImagePathLogic_ImagePathCallBack < NSObject, JavaObject >

- (void)dobackWithJavaUtilArrayList:(JavaUtilArrayList *)photos;

@end

__attribute__((always_inline)) inline void ComFqHalcyonLogicGetImagePathLogic_ImagePathCallBack_init() {}

@protocol ComFqHalcyonLogicGetImagePathLogic_RecordImageCallback < NSObject, JavaObject >

- (void)callRecrodImagesWithJavaUtilArrayList:(JavaUtilArrayList *)photos;

@end

__attribute__((always_inline)) inline void ComFqHalcyonLogicGetImagePathLogic_RecordImageCallback_init() {}

@interface ComFqHalcyonLogicGetImagePathLogic_$1 : HalcyonHttpResponseHandle {
 @public
  ComFqHalcyonLogicGetImagePathLogic *this$0_;
}

- (void)onErrorWithInt:(int)code
 withJavaLangThrowable:(JavaLangThrowable *)e;

- (void)handleWithInt:(int)responseCode
         withNSString:(NSString *)msg
              withInt:(int)type
               withId:(id)results;

- (id)initWithComFqHalcyonLogicGetImagePathLogic:(ComFqHalcyonLogicGetImagePathLogic *)outer$;

@end

__attribute__((always_inline)) inline void ComFqHalcyonLogicGetImagePathLogic_$1_init() {}

J2OBJC_FIELD_SETTER(ComFqHalcyonLogicGetImagePathLogic_$1, this$0_, ComFqHalcyonLogicGetImagePathLogic *)

@interface ComFqHalcyonLogicGetImagePathLogic_$2 : HalcyonHttpResponseHandle {
 @public
  id<ComFqHalcyonLogicGetImagePathLogic_RecordImageCallback> val$callback_;
}

- (void)onErrorWithInt:(int)code
 withJavaLangThrowable:(JavaLangThrowable *)e;

- (void)handleWithInt:(int)responseCode
         withNSString:(NSString *)msg
              withInt:(int)type
               withId:(id)results;

- (id)initWithComFqHalcyonLogicGetImagePathLogic_RecordImageCallback:(id<ComFqHalcyonLogicGetImagePathLogic_RecordImageCallback>)capture$0;

@end

__attribute__((always_inline)) inline void ComFqHalcyonLogicGetImagePathLogic_$2_init() {}

J2OBJC_FIELD_SETTER(ComFqHalcyonLogicGetImagePathLogic_$2, val$callback_, id<ComFqHalcyonLogicGetImagePathLogic_RecordImageCallback>)

#endif // _ComFqHalcyonLogicGetImagePathLogic_H_