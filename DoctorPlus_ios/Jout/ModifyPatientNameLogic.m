//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/logic2/ModifyPatientNameLogic.java
//
//  Created by liaomin on 15-5-4.
//

#line 1 "/Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/logic2/ModifyPatientNameLogic.java"

#include "ApiSystem.h"
#include "Constants.h"
#include "FQHttpParams.h"
#include "HttpRequestPotocol.h"
#include "JSONObject.h"
#include "JsonHelper.h"
#include "ModifyPatientNameLogic.h"
#include "UriConstants.h"
#include "User.h"
#include "java/lang/Integer.h"
#include "java/lang/Throwable.h"
#include "java/util/HashMap.h"


#line 14
@implementation ComFqHalcyonLogic2ModifyPatientNameLogic


#line 18
- (id)initWithComFqHalcyonLogic2ModifyPatientNameLogic_ModifyPatientNameCallBack:(id<ComFqHalcyonLogic2ModifyPatientNameLogic_ModifyPatientNameCallBack>)onCallBack {
  if (self = [super init]) {
    
#line 19
    self->onCallBack_ = onCallBack;
  }
  return self;
}


#line 22
- (void)modifyNameWithInt:(int)patientId
             withNSString:(NSString *)patientName {
  
#line 23
  JavaUtilHashMap *map = [[JavaUtilHashMap alloc] init];
  (void) [map putWithId:@"user_id" withId:[JavaLangInteger valueOfWithInt:[((ComFqHalcyonEntityUser *) nil_chk([ComFqLibToolsConstants getUser])) getUserId]]];
  (void) [map putWithId:@"patient_id" withId:[JavaLangInteger valueOfWithInt:patientId]];
  (void) [map putWithId:@"patient_name" withId:patientName];
  FQJSONObject *json = [ComFqLibJsonHelper createJsonWithJavaUtilMap:map];
  NSString *uri = [NSString stringWithFormat:@"%@/patient/rename.do", ComFqLibToolsUriConstants_Conn_get_URL_PUB_()];
  (void) [((ComFqHalcyonApiApiSystem *) nil_chk([ComFqHalcyonApiApiSystem getInstance])) requireWithNSString:uri withComFqHttpAsyncFQHttpParams:[[ComFqHttpAsyncFQHttpParams alloc] initWithFQJSONObject:json] withComFqHalcyonApiApiSystem_API_TYPEEnum:ComFqHalcyonApiApiSystem_API_TYPEEnum_get_DIRECT() withHalcyonHttpResponseHandle:[[ComFqHalcyonLogic2ModifyPatientNameLogic_ModifyNameHandler alloc] initWithComFqHalcyonLogic2ModifyPatientNameLogic:self]];
}

- (void)copyAllFieldsTo:(ComFqHalcyonLogic2ModifyPatientNameLogic *)other {
  [super copyAllFieldsTo:other];
  other->onCallBack_ = onCallBack_;
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "initWithComFqHalcyonLogic2ModifyPatientNameLogic_ModifyPatientNameCallBack:", "ModifyPatientNameLogic", NULL, 0x1, NULL },
    { "modifyNameWithInt:withNSString:", "modifyName", "V", 0x1, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "onCallBack_", NULL, 0x2, "Lcom.fq.halcyon.logic2.ModifyPatientNameLogic$ModifyPatientNameCallBack;", NULL,  },
  };
  static J2ObjcClassInfo _ComFqHalcyonLogic2ModifyPatientNameLogic = { "ModifyPatientNameLogic", "com.fq.halcyon.logic2", NULL, 0x1, 2, methods, 1, fields, 0, NULL};
  return &_ComFqHalcyonLogic2ModifyPatientNameLogic;
}

@end


#line 32
@implementation ComFqHalcyonLogic2ModifyPatientNameLogic_ModifyNameHandler


#line 35
- (void)onErrorWithInt:(int)code
 withJavaLangThrowable:(JavaLangThrowable *)e {
  
#line 36
  [((id<ComFqHalcyonLogic2ModifyPatientNameLogic_ModifyPatientNameCallBack>) nil_chk(this$0_->onCallBack_)) modifyNameErrorWithInt:code withNSString:[((JavaLangThrowable *) nil_chk(e)) getMessage]];
}


#line 40
- (void)handleWithInt:(int)responseCode
         withNSString:(NSString *)msg
              withInt:(int)type
               withId:(id)results {
  if (responseCode == 0) {
    [((id<ComFqHalcyonLogic2ModifyPatientNameLogic_ModifyPatientNameCallBack>) nil_chk(this$0_->onCallBack_)) modifyNameSuccessWithInt:responseCode withNSString:msg];
  }
  else {
    
#line 45
    [((id<ComFqHalcyonLogic2ModifyPatientNameLogic_ModifyPatientNameCallBack>) nil_chk(this$0_->onCallBack_)) modifyNameErrorWithInt:responseCode withNSString:msg];
  }
}

- (id)initWithComFqHalcyonLogic2ModifyPatientNameLogic:(ComFqHalcyonLogic2ModifyPatientNameLogic *)outer$ {
  this$0_ = outer$;
  return [super init];
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "onErrorWithInt:withJavaLangThrowable:", "onError", "V", 0x1, NULL },
    { "handleWithInt:withNSString:withInt:withId:", "handle", "V", 0x1, NULL },
    { "initWithComFqHalcyonLogic2ModifyPatientNameLogic:", "init", NULL, 0x0, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "this$0_", NULL, 0x1012, "Lcom.fq.halcyon.logic2.ModifyPatientNameLogic;", NULL,  },
  };
  static J2ObjcClassInfo _ComFqHalcyonLogic2ModifyPatientNameLogic_ModifyNameHandler = { "ModifyNameHandler", "com.fq.halcyon.logic2", "ModifyPatientNameLogic", 0x0, 3, methods, 1, fields, 0, NULL};
  return &_ComFqHalcyonLogic2ModifyPatientNameLogic_ModifyNameHandler;
}

@end

@interface ComFqHalcyonLogic2ModifyPatientNameLogic_ModifyPatientNameCallBack : NSObject
@end

@implementation ComFqHalcyonLogic2ModifyPatientNameLogic_ModifyPatientNameCallBack

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "modifyNameSuccessWithInt:withNSString:", "modifyNameSuccess", "V", 0x401, NULL },
    { "modifyNameErrorWithInt:withNSString:", "modifyNameError", "V", 0x401, NULL },
  };
  static J2ObjcClassInfo _ComFqHalcyonLogic2ModifyPatientNameLogic_ModifyPatientNameCallBack = { "ModifyPatientNameCallBack", "com.fq.halcyon.logic2", "ModifyPatientNameLogic", 0x201, 2, methods, 0, NULL, 0, NULL};
  return &_ComFqHalcyonLogic2ModifyPatientNameLogic_ModifyPatientNameCallBack;
}

@end