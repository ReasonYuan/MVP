//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/lib/tools/UserProfileManager.java
//
//  Created by liaomin on 15-5-4.
//

#ifndef _ComFqLibToolsUserProfileManager_H_
#define _ComFqLibToolsUserProfileManager_H_

@class ComFqHalcyonEntityUser;
@class ComFqHalcyonExtendFilesystemFileSystem;
@class ComFqHalcyonLogic2ResetDoctorInfoLogic;
@class JavaIoFile;
@class JavaLangThrowable;
@protocol ComFqLibToolsUserProfileManager_OnResultCallBack;
@protocol ComFqLibToolsUserProfileManager_OnUploadCallBack;

#import "JreEmulation.h"
#include "HalcyonHttpResponseHandle.h"
#include "ResetDoctorInfoLogic.h"

@interface ComFqLibToolsUserProfileManager : NSObject {
 @public
  ComFqHalcyonLogic2ResetDoctorInfoLogic *resetDoctorInfoLogic_;
  ComFqHalcyonEntityUser *mUser_;
  NSString *localTempImageFileName_;
}

+ (ComFqLibToolsUserProfileManager *)instance;

- (ComFqHalcyonEntityUser *)getUser;

- (void)clear;

- (JavaIoFile *)getLocalTempFileUri;

- (NSString *)getlocaltempimageFileName;

- (NSString *)getlocaltempimageFilegetAbsolutePath;

- (void)getInvientWithComFqHalcyonEntityUser:(ComFqHalcyonEntityUser *)mUser
withComFqLibToolsUserProfileManager_OnResultCallBack:(id<ComFqLibToolsUserProfileManager_OnResultCallBack>)callBack;

- (BOOL)isFirstLogin;

- (NSString *)getSelectZhiChengWithId:(id)obj
                          withBoolean:(BOOL)mIsDoctor;

- (void)upLoadHeadWithComFqLibToolsUserProfileManager_OnUploadCallBack:(id<ComFqLibToolsUserProfileManager_OnUploadCallBack>)callBack;

- (void)reqModyName;

- (void)reqModyHospWithInt:(int)hosId
              withNSString:(NSString *)hosName;

- (void)reqModyDeptWithInt:(int)deptId
                   withInt:(int)secId
              withNSString:(NSString *)name;

- (void)reqModyGender;

- (void)reqModyDes;

- (void)reqModyUniversity;

- (void)reqModyEntranceTimeWithNSString:(NSString *)time;

- (id)init;

- (void)copyAllFieldsTo:(ComFqLibToolsUserProfileManager *)other;

@end

__attribute__((always_inline)) inline void ComFqLibToolsUserProfileManager_init() {}

J2OBJC_FIELD_SETTER(ComFqLibToolsUserProfileManager, resetDoctorInfoLogic_, ComFqHalcyonLogic2ResetDoctorInfoLogic *)
J2OBJC_FIELD_SETTER(ComFqLibToolsUserProfileManager, mUser_, ComFqHalcyonEntityUser *)
J2OBJC_FIELD_SETTER(ComFqLibToolsUserProfileManager, localTempImageFileName_, NSString *)

FOUNDATION_EXPORT ComFqLibToolsUserProfileManager *ComFqLibToolsUserProfileManager_mInstance_;
J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsUserProfileManager, mInstance_, ComFqLibToolsUserProfileManager *)
J2OBJC_STATIC_FIELD_SETTER(ComFqLibToolsUserProfileManager, mInstance_, ComFqLibToolsUserProfileManager *)

@protocol ComFqLibToolsUserProfileManager_OnResultCallBack < NSObject, JavaObject >

- (void)onResultWithNSString:(NSString *)msg;

@end

__attribute__((always_inline)) inline void ComFqLibToolsUserProfileManager_OnResultCallBack_init() {}

@protocol ComFqLibToolsUserProfileManager_OnUploadCallBack < NSObject, JavaObject >

- (void)onError;

- (void)onsuccess;

@end

__attribute__((always_inline)) inline void ComFqLibToolsUserProfileManager_OnUploadCallBack_init() {}

@interface ComFqLibToolsUserProfileManager_$1 : NSObject < ComFqHalcyonLogic2ResetDoctorInfoLogic_InvientCallback > {
 @public
  id<ComFqLibToolsUserProfileManager_OnResultCallBack> val$callBack_;
  ComFqHalcyonEntityUser *val$mUser_;
}

- (void)doInvientBackWithNSString:(NSString *)invient;

- (id)initWithComFqLibToolsUserProfileManager_OnResultCallBack:(id<ComFqLibToolsUserProfileManager_OnResultCallBack>)capture$0
                                    withComFqHalcyonEntityUser:(ComFqHalcyonEntityUser *)capture$1;

@end

__attribute__((always_inline)) inline void ComFqLibToolsUserProfileManager_$1_init() {}

J2OBJC_FIELD_SETTER(ComFqLibToolsUserProfileManager_$1, val$callBack_, id<ComFqLibToolsUserProfileManager_OnResultCallBack>)
J2OBJC_FIELD_SETTER(ComFqLibToolsUserProfileManager_$1, val$mUser_, ComFqHalcyonEntityUser *)

@interface ComFqLibToolsUserProfileManager_$2 : HalcyonHttpResponseHandle {
 @public
  ComFqLibToolsUserProfileManager *this$0_;
  id<ComFqLibToolsUserProfileManager_OnUploadCallBack> val$callBack_;
  ComFqHalcyonExtendFilesystemFileSystem *val$fileSys_;
}

- (void)onErrorWithInt:(int)code
 withJavaLangThrowable:(JavaLangThrowable *)e;

- (void)handleWithInt:(int)responseCode
         withNSString:(NSString *)msg
              withInt:(int)type
               withId:(id)results;

- (id)initWithComFqLibToolsUserProfileManager:(ComFqLibToolsUserProfileManager *)outer$
withComFqLibToolsUserProfileManager_OnUploadCallBack:(id<ComFqLibToolsUserProfileManager_OnUploadCallBack>)capture$0
   withComFqHalcyonExtendFilesystemFileSystem:(ComFqHalcyonExtendFilesystemFileSystem *)capture$1;

@end

__attribute__((always_inline)) inline void ComFqLibToolsUserProfileManager_$2_init() {}

J2OBJC_FIELD_SETTER(ComFqLibToolsUserProfileManager_$2, this$0_, ComFqLibToolsUserProfileManager *)
J2OBJC_FIELD_SETTER(ComFqLibToolsUserProfileManager_$2, val$callBack_, id<ComFqLibToolsUserProfileManager_OnUploadCallBack>)
J2OBJC_FIELD_SETTER(ComFqLibToolsUserProfileManager_$2, val$fileSys_, ComFqHalcyonExtendFilesystemFileSystem *)

#endif // _ComFqLibToolsUserProfileManager_H_