//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/logic2/DelPatientLogic.java
//
//  Created by liaomin on 15-5-4.
//

#line 1 "/Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/logic2/DelPatientLogic.java"

#include "ApiSystem.h"
#include "Constants.h"
#include "DelPatientLogic.h"
#include "FQHttpParams.h"
#include "HttpRequestPotocol.h"
#include "JSONObject.h"
#include "JsonHelper.h"
#include "UriConstants.h"
#include "User.h"
#include "java/lang/Integer.h"
#include "java/lang/Throwable.h"
#include "java/util/HashMap.h"


#line 17
@implementation ComFqHalcyonLogic2DelPatientLogic


#line 26
- (id)initWithComFqHalcyonLogic2DelPatientLogic_DelMedicalCallBack:(id<ComFqHalcyonLogic2DelPatientLogic_DelMedicalCallBack>)onCallBack {
  if (self = [super init]) {
    mHandle_ =
#line 58
    [[ComFqHalcyonLogic2DelPatientLogic_DelMedicalLogicHandle alloc] initWithComFqHalcyonLogic2DelPatientLogic:self];
    
#line 27
    self->onCallBack_ = onCallBack;
  }
  return self;
}


#line 30
- (void)delMedicalWithInt:(int)patientId {
  
#line 31
  JavaUtilHashMap *map = [[JavaUtilHashMap alloc] init];
  (void) [map putWithId:@"user_id" withId:[JavaLangInteger valueOfWithInt:[((ComFqHalcyonEntityUser *) nil_chk([ComFqLibToolsConstants getUser])) getUserId]]];
  (void) [map putWithId:@"patient_id" withId:[JavaLangInteger valueOfWithInt:patientId]];
  FQJSONObject *json = [ComFqLibJsonHelper createJsonWithJavaUtilMap:map];
  NSString *uri = [NSString stringWithFormat:@"%@/patient/delete.do", ComFqLibToolsUriConstants_Conn_get_URL_PUB_()];
  
#line 37
  (void) [((ComFqHalcyonApiApiSystem *) nil_chk([ComFqHalcyonApiApiSystem getInstance])) requireWithNSString:uri withComFqHttpAsyncFQHttpParams:[[ComFqHttpAsyncFQHttpParams alloc] initWithFQJSONObject:json] withComFqHalcyonApiApiSystem_API_TYPEEnum:ComFqHalcyonApiApiSystem_API_TYPEEnum_get_DIRECT() withHalcyonHttpResponseHandle:mHandle_];
}

- (void)copyAllFieldsTo:(ComFqHalcyonLogic2DelPatientLogic *)other {
  [super copyAllFieldsTo:other];
  other->mHandle_ = mHandle_;
  other->onCallBack_ = onCallBack_;
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "initWithComFqHalcyonLogic2DelPatientLogic_DelMedicalCallBack:", "DelPatientLogic", NULL, 0x1, NULL },
    { "delMedicalWithInt:", "delMedical", "V", 0x1, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "onCallBack_", NULL, 0x1, "Lcom.fq.halcyon.logic2.DelPatientLogic$DelMedicalCallBack;", NULL,  },
    { "mHandle_", NULL, 0x2, "Lcom.fq.halcyon.logic2.DelPatientLogic$DelMedicalLogicHandle;", NULL,  },
  };
  static J2ObjcClassInfo _ComFqHalcyonLogic2DelPatientLogic = { "DelPatientLogic", "com.fq.halcyon.logic2", NULL, 0x1, 2, methods, 2, fields, 0, NULL};
  return &_ComFqHalcyonLogic2DelPatientLogic;
}

@end

@interface ComFqHalcyonLogic2DelPatientLogic_DelMedicalCallBack : NSObject
@end

@implementation ComFqHalcyonLogic2DelPatientLogic_DelMedicalCallBack

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "onDelMedicalErrorWithInt:withNSString:", "onDelMedicalError", "V", 0x401, NULL },
    { "onDelMedicalSuccessWithInt:withNSString:", "onDelMedicalSuccess", "V", 0x401, NULL },
  };
  static J2ObjcClassInfo _ComFqHalcyonLogic2DelPatientLogic_DelMedicalCallBack = { "DelMedicalCallBack", "com.fq.halcyon.logic2", "DelPatientLogic", 0x201, 2, methods, 0, NULL, 0, NULL};
  return &_ComFqHalcyonLogic2DelPatientLogic_DelMedicalCallBack;
}

@end


#line 40
@implementation ComFqHalcyonLogic2DelPatientLogic_DelMedicalLogicHandle


#line 43
- (void)onErrorWithInt:(int)code
 withJavaLangThrowable:(JavaLangThrowable *)e {
  
#line 44
  [((id<ComFqHalcyonLogic2DelPatientLogic_DelMedicalCallBack>) nil_chk(this$0_->onCallBack_)) onDelMedicalErrorWithInt:code withNSString:[((JavaLangThrowable *) nil_chk(e)) getMessage]];
}


#line 48
- (void)handleWithInt:(int)responseCode
         withNSString:(NSString *)msg
              withInt:(int)type
               withId:(id)results {
  if (responseCode == 0) {
    [((id<ComFqHalcyonLogic2DelPatientLogic_DelMedicalCallBack>) nil_chk(this$0_->onCallBack_)) onDelMedicalSuccessWithInt:responseCode withNSString:msg];
  }
  else {
    
#line 53
    [((id<ComFqHalcyonLogic2DelPatientLogic_DelMedicalCallBack>) nil_chk(this$0_->onCallBack_)) onDelMedicalErrorWithInt:responseCode withNSString:msg];
  }
}

- (id)initWithComFqHalcyonLogic2DelPatientLogic:(ComFqHalcyonLogic2DelPatientLogic *)outer$ {
  this$0_ = outer$;
  return [super init];
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "onErrorWithInt:withJavaLangThrowable:", "onError", "V", 0x1, NULL },
    { "handleWithInt:withNSString:withInt:withId:", "handle", "V", 0x1, NULL },
    { "initWithComFqHalcyonLogic2DelPatientLogic:", "init", NULL, 0x0, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "this$0_", NULL, 0x1012, "Lcom.fq.halcyon.logic2.DelPatientLogic;", NULL,  },
  };
  static J2ObjcClassInfo _ComFqHalcyonLogic2DelPatientLogic_DelMedicalLogicHandle = { "DelMedicalLogicHandle", "com.fq.halcyon.logic2", "DelPatientLogic", 0x0, 3, methods, 1, fields, 0, NULL};
  return &_ComFqHalcyonLogic2DelPatientLogic_DelMedicalLogicHandle;
}

@end