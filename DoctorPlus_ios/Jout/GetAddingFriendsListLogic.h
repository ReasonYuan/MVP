//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/logic2/GetAddingFriendsListLogic.java
//
//  Created by liaomin on 15-5-4.
//

#ifndef _ComFqHalcyonLogic2GetAddingFriendsListLogic_H_
#define _ComFqHalcyonLogic2GetAddingFriendsListLogic_H_

@class ComFqHalcyonLogic2GetAddingFriendsListLogic_GetAddingFriendsListLogicHandle;
@class JavaLangThrowable;
@class JavaUtilArrayList;
@protocol ComFqHalcyonLogic2GetAddingFriendsListLogic_GetAddingFriendsListLogicInterface;

#import "JreEmulation.h"
#include "FQHttpResponseInterface.h"
#include "HalcyonHttpResponseHandle.h"

@interface ComFqHalcyonLogic2GetAddingFriendsListLogic : NSObject {
 @public
  __weak id<ComFqHalcyonLogic2GetAddingFriendsListLogic_GetAddingFriendsListLogicInterface> mInterface_;
  JavaUtilArrayList *mFriendsListReq_;
  JavaUtilArrayList *mFriendsListRsp_;
  ComFqHalcyonLogic2GetAddingFriendsListLogic_GetAddingFriendsListLogicHandle *mHandle_;
}

- (id)initWithComFqHalcyonLogic2GetAddingFriendsListLogic_GetAddingFriendsListLogicInterface:(id<ComFqHalcyonLogic2GetAddingFriendsListLogic_GetAddingFriendsListLogicInterface>)mIn
                                                                                     withInt:(int)userId;

- (void)copyAllFieldsTo:(ComFqHalcyonLogic2GetAddingFriendsListLogic *)other;

@end

__attribute__((always_inline)) inline void ComFqHalcyonLogic2GetAddingFriendsListLogic_init() {}

J2OBJC_FIELD_SETTER(ComFqHalcyonLogic2GetAddingFriendsListLogic, mFriendsListReq_, JavaUtilArrayList *)
J2OBJC_FIELD_SETTER(ComFqHalcyonLogic2GetAddingFriendsListLogic, mFriendsListRsp_, JavaUtilArrayList *)
J2OBJC_FIELD_SETTER(ComFqHalcyonLogic2GetAddingFriendsListLogic, mHandle_, ComFqHalcyonLogic2GetAddingFriendsListLogic_GetAddingFriendsListLogicHandle *)

@protocol ComFqHalcyonLogic2GetAddingFriendsListLogic_GetAddingFriendsListLogicInterface < ComFqHttpPotocolFQHttpResponseInterface, NSObject, JavaObject >
- (void)onDataReturnWithJavaUtilArrayList:(JavaUtilArrayList *)mFriendsListReq
                    withJavaUtilArrayList:(JavaUtilArrayList *)mFriendsListRsp;

- (void)onErrorWithInt:(int)code
 withJavaLangThrowable:(JavaLangThrowable *)e;

@end

__attribute__((always_inline)) inline void ComFqHalcyonLogic2GetAddingFriendsListLogic_GetAddingFriendsListLogicInterface_init() {}

@interface ComFqHalcyonLogic2GetAddingFriendsListLogic_GetAddingFriendsListLogicHandle : HalcyonHttpResponseHandle {
 @public
  ComFqHalcyonLogic2GetAddingFriendsListLogic *this$0_;
}

- (void)onErrorWithInt:(int)code
 withJavaLangThrowable:(JavaLangThrowable *)e;

- (void)handleWithInt:(int)responseCode
         withNSString:(NSString *)msg
              withInt:(int)type
               withId:(id)results;

- (id)initWithComFqHalcyonLogic2GetAddingFriendsListLogic:(ComFqHalcyonLogic2GetAddingFriendsListLogic *)outer$;

@end

__attribute__((always_inline)) inline void ComFqHalcyonLogic2GetAddingFriendsListLogic_GetAddingFriendsListLogicHandle_init() {}

J2OBJC_FIELD_SETTER(ComFqHalcyonLogic2GetAddingFriendsListLogic_GetAddingFriendsListLogicHandle, this$0_, ComFqHalcyonLogic2GetAddingFriendsListLogic *)

#endif // _ComFqHalcyonLogic2GetAddingFriendsListLogic_H_