//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/logic2/SearchHospitalLogic.java
//
//  Created by liaomin on 15-5-4.
//

#line 1 "/Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/logic2/SearchHospitalLogic.java"

#include "ApiSystem.h"
#include "Constants.h"
#include "FQHttpParams.h"
#include "Hospital.h"
#include "HttpRequestPotocol.h"
#include "JSONArray.h"
#include "JSONObject.h"
#include "JsonHelper.h"
#include "SearchHospitalLogic.h"
#include "UriConstants.h"
#include "User.h"
#include "java/lang/Integer.h"
#include "java/lang/Throwable.h"
#include "java/util/ArrayList.h"
#include "java/util/HashMap.h"


#line 23
@implementation ComFqHalcyonLogic2SearchHospitalLogic


#line 35
- (id)initWithComFqHalcyonLogic2SearchHospitalLogic_SearchHospitalCallBack:(id<ComFqHalcyonLogic2SearchHospitalLogic_SearchHospitalCallBack>)onCallBack {
  if (self = [super init]) {
    mHandle_ =
#line 91
    [[ComFqHalcyonLogic2SearchHospitalLogic_SearchHospitalHandle alloc] initWithComFqHalcyonLogic2SearchHospitalLogic:self];
    
#line 36
    mList_ = [[JavaUtilArrayList alloc] init];
    
#line 37
    self->onCallBack_ = onCallBack;
  }
  return self;
}


#line 45
- (void)searchHospitalWithNSString:(NSString *)hospitalName
                      withNSString:(NSString *)cityName {
  
#line 46
  JavaUtilHashMap *map = [[JavaUtilHashMap alloc] init];
  (void) [map putWithId:@"user_id" withId:[JavaLangInteger valueOfWithInt:[((ComFqHalcyonEntityUser *) nil_chk([ComFqLibToolsConstants getUser])) getUserId]]];
  (void) [map putWithId:@"hospital_name" withId:hospitalName];
  (void) [map putWithId:@"city_name" withId:cityName];
  FQJSONObject *json = [ComFqLibJsonHelper createJsonWithJavaUtilMap:map];
  NSString *uri = [NSString stringWithFormat:@"%@/pub/fuzzy_search_hospital.do", ComFqLibToolsUriConstants_Conn_get_URL_PUB_()];
  (void) [((ComFqHalcyonApiApiSystem *) nil_chk([ComFqHalcyonApiApiSystem getInstance])) requireWithNSString:uri withComFqHttpAsyncFQHttpParams:[[ComFqHttpAsyncFQHttpParams alloc] initWithFQJSONObject:json] withComFqHalcyonApiApiSystem_API_TYPEEnum:ComFqHalcyonApiApiSystem_API_TYPEEnum_get_DIRECT() withHalcyonHttpResponseHandle:mHandle_];
}


#line 60
- (void)searchHDRHospital {
  
#line 61
  JavaUtilHashMap *map = [[JavaUtilHashMap alloc] init];
  FQJSONObject *json = [ComFqLibJsonHelper createJsonWithJavaUtilMap:map];
  NSString *uri = [NSString stringWithFormat:@"%@/pub/getHospital.do", ComFqLibToolsUriConstants_Conn_get_URL_PUB_()];
  (void) [((ComFqHalcyonApiApiSystem *) nil_chk([ComFqHalcyonApiApiSystem getInstance])) requireWithNSString:uri withComFqHttpAsyncFQHttpParams:[[ComFqHttpAsyncFQHttpParams alloc] initWithFQJSONObject:json] withComFqHalcyonApiApiSystem_API_TYPEEnum:ComFqHalcyonApiApiSystem_API_TYPEEnum_get_DIRECT() withHalcyonHttpResponseHandle:mHandle_];
}

- (void)copyAllFieldsTo:(ComFqHalcyonLogic2SearchHospitalLogic *)other {
  [super copyAllFieldsTo:other];
  other->mHandle_ = mHandle_;
  other->mList_ = mList_;
  other->onCallBack_ = onCallBack_;
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "initWithComFqHalcyonLogic2SearchHospitalLogic_SearchHospitalCallBack:", "SearchHospitalLogic", NULL, 0x1, NULL },
    { "searchHospitalWithNSString:withNSString:", "searchHospital", "V", 0x1, NULL },
    { "searchHDRHospital", NULL, "V", 0x1, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "mList_", NULL, 0x2, "Ljava.util.ArrayList;", NULL,  },
    { "onCallBack_", NULL, 0x2, "Lcom.fq.halcyon.logic2.SearchHospitalLogic$SearchHospitalCallBack;", NULL,  },
    { "mHandle_", NULL, 0x2, "Lcom.fq.halcyon.logic2.SearchHospitalLogic$SearchHospitalHandle;", NULL,  },
  };
  static J2ObjcClassInfo _ComFqHalcyonLogic2SearchHospitalLogic = { "SearchHospitalLogic", "com.fq.halcyon.logic2", NULL, 0x1, 3, methods, 3, fields, 0, NULL};
  return &_ComFqHalcyonLogic2SearchHospitalLogic;
}

@end

@interface ComFqHalcyonLogic2SearchHospitalLogic_SearchHospitalCallBack : NSObject
@end

@implementation ComFqHalcyonLogic2SearchHospitalLogic_SearchHospitalCallBack

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "onSearchHospitalErrorWithInt:withNSString:", "onSearchHospitalError", "V", 0x401, NULL },
    { "onSearchHospitalResultWithJavaUtilArrayList:", "onSearchHospitalResult", "V", 0x401, NULL },
  };
  static J2ObjcClassInfo _ComFqHalcyonLogic2SearchHospitalLogic_SearchHospitalCallBack = { "SearchHospitalCallBack", "com.fq.halcyon.logic2", "SearchHospitalLogic", 0x201, 2, methods, 0, NULL, 0, NULL};
  return &_ComFqHalcyonLogic2SearchHospitalLogic_SearchHospitalCallBack;
}

@end


#line 67
@implementation ComFqHalcyonLogic2SearchHospitalLogic_SearchHospitalHandle


#line 70
- (void)onErrorWithInt:(int)code
 withJavaLangThrowable:(JavaLangThrowable *)e {
  
#line 71
  [((id<ComFqHalcyonLogic2SearchHospitalLogic_SearchHospitalCallBack>) nil_chk(this$0_->onCallBack_)) onSearchHospitalErrorWithInt:code withNSString:[((JavaLangThrowable *) nil_chk(e)) getMessage]];
}


#line 75
- (void)handleWithInt:(int)responseCode
         withNSString:(NSString *)msg
              withInt:(int)type
               withId:(id)results {
  if (responseCode == 0 && type == 2) {
    FQJSONArray *jsonArray = (FQJSONArray *) check_class_cast(results, [FQJSONArray class]);
    for (int i = 0; i < [((FQJSONArray *) nil_chk(jsonArray)) length]; i++) {
      ComFqHalcyonEntityHospital *hospital = [[ComFqHalcyonEntityHospital alloc] init];
      [hospital setAtttributeByjsonWithFQJSONObject:[jsonArray optJSONObjectWithInt:i]];
      [((JavaUtilArrayList *) nil_chk(this$0_->mList_)) addWithId:hospital];
    }
    [((id<ComFqHalcyonLogic2SearchHospitalLogic_SearchHospitalCallBack>) nil_chk(this$0_->onCallBack_)) onSearchHospitalResultWithJavaUtilArrayList:this$0_->mList_];
  }
  else {
    
#line 86
    [((id<ComFqHalcyonLogic2SearchHospitalLogic_SearchHospitalCallBack>) nil_chk(this$0_->onCallBack_)) onSearchHospitalErrorWithInt:responseCode withNSString:msg];
  }
}

- (id)initWithComFqHalcyonLogic2SearchHospitalLogic:(ComFqHalcyonLogic2SearchHospitalLogic *)outer$ {
  this$0_ = outer$;
  return [super init];
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "onErrorWithInt:withJavaLangThrowable:", "onError", "V", 0x1, NULL },
    { "handleWithInt:withNSString:withInt:withId:", "handle", "V", 0x1, NULL },
    { "initWithComFqHalcyonLogic2SearchHospitalLogic:", "init", NULL, 0x0, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "this$0_", NULL, 0x1012, "Lcom.fq.halcyon.logic2.SearchHospitalLogic;", NULL,  },
  };
  static J2ObjcClassInfo _ComFqHalcyonLogic2SearchHospitalLogic_SearchHospitalHandle = { "SearchHospitalHandle", "com.fq.halcyon.logic2", "SearchHospitalLogic", 0x0, 3, methods, 1, fields, 0, NULL};
  return &_ComFqHalcyonLogic2SearchHospitalLogic_SearchHospitalHandle;
}

@end