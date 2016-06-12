//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/logic2/SearchPatientLogic.java
//
//  Created by liaomin on 15-5-4.
//

#ifndef _ComFqHalcyonLogic2SearchPatientLogic_H_
#define _ComFqHalcyonLogic2SearchPatientLogic_H_

@class JavaLangThrowable;
@class JavaUtilArrayList;
@protocol ComFqHalcyonLogic2SearchPatientLogic_SearchMedicalCallBack;

#import "JreEmulation.h"
#include "HalcyonHttpResponseHandle.h"

@interface ComFqHalcyonLogic2SearchPatientLogic : NSObject {
 @public
  JavaUtilArrayList *medicalList_;
  __weak id<ComFqHalcyonLogic2SearchPatientLogic_SearchMedicalCallBack> onCallBack_;
}

- (id)initWithComFqHalcyonLogic2SearchPatientLogic_SearchMedicalCallBack:(id<ComFqHalcyonLogic2SearchPatientLogic_SearchMedicalCallBack>)onCallBack;

- (void)searchMedicalWithNSString:(NSString *)patientKey
                          withInt:(int)page
                          withInt:(int)pageSize;

- (void)searchMedicalWithNSString:(NSString *)patientKey;

- (void)copyAllFieldsTo:(ComFqHalcyonLogic2SearchPatientLogic *)other;

@end

__attribute__((always_inline)) inline void ComFqHalcyonLogic2SearchPatientLogic_init() {}

J2OBJC_FIELD_SETTER(ComFqHalcyonLogic2SearchPatientLogic, medicalList_, JavaUtilArrayList *)

@protocol ComFqHalcyonLogic2SearchPatientLogic_SearchMedicalCallBack < NSObject, JavaObject >

- (void)onSearchMedicalErrorWithInt:(int)code
                       withNSString:(NSString *)msg;

- (void)onSearchMedicalResultWithJavaUtilArrayList:(JavaUtilArrayList *)medicalList;

@end

__attribute__((always_inline)) inline void ComFqHalcyonLogic2SearchPatientLogic_SearchMedicalCallBack_init() {}

@interface ComFqHalcyonLogic2SearchPatientLogic_SearchMedicalHandle : HalcyonHttpResponseHandle {
 @public
  ComFqHalcyonLogic2SearchPatientLogic *this$0_;
  int mPage_;
}

- (id)initWithComFqHalcyonLogic2SearchPatientLogic:(ComFqHalcyonLogic2SearchPatientLogic *)outer$
                                           withInt:(int)page;

- (void)onErrorWithInt:(int)code
 withJavaLangThrowable:(JavaLangThrowable *)e;

- (void)handleCacheWithInt:(int)responseCode
              withNSString:(NSString *)msg
                   withInt:(int)type
                    withId:(id)results
               withBoolean:(BOOL)fromCache;

- (void)handleWithInt:(int)responseCode
         withNSString:(NSString *)msg
              withInt:(int)type
               withId:(id)results;

- (void)copyAllFieldsTo:(ComFqHalcyonLogic2SearchPatientLogic_SearchMedicalHandle *)other;

@end

__attribute__((always_inline)) inline void ComFqHalcyonLogic2SearchPatientLogic_SearchMedicalHandle_init() {}

J2OBJC_FIELD_SETTER(ComFqHalcyonLogic2SearchPatientLogic_SearchMedicalHandle, this$0_, ComFqHalcyonLogic2SearchPatientLogic *)

#endif // _ComFqHalcyonLogic2SearchPatientLogic_H_