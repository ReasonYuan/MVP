//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/logic2/SurveyRecordLogic.java
//
//  Created by liaomin on 15-5-4.
//

#line 1 "/Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/logic2/SurveyRecordLogic.java"

#include "ApiSystem.h"
#include "Constants.h"
#include "FQHttpParams.h"
#include "FileHelper.h"
#include "FileSystem.h"
#include "HalcyonHttpResponseHandle.h"
#include "HttpRequestPotocol.h"
#include "JSONException.h"
#include "JSONObject.h"
#include "JsonHelper.h"
#include "Platform.h"
#include "SurveyRecordItem.h"
#include "SurveyRecordLogic.h"
#include "UriConstants.h"
#include "User.h"
#include "java/lang/Integer.h"
#include "java/lang/Throwable.h"
#include "java/util/ArrayList.h"
#include "java/util/HashMap.h"
#include "java/util/Iterator.h"


#line 26
@implementation ComFqHalcyonLogic2SurveyRecordLogic


#line 31
- (id)initWithComFqHalcyonLogic2SurveyRecordLogic_SurveyRecordCallBack:(id<ComFqHalcyonLogic2SurveyRecordLogic_SurveyRecordCallBack>)onCallBack {
  if (self = [super init]) {
    
#line 32
    self->onCallBack_ = onCallBack;
    
#line 33
    surItemList_ = [[JavaUtilArrayList alloc] init];
  }
  return self;
}


#line 41
- (void)surveyRecordWithInt:(int)recordId {
  
#line 42
  JavaUtilHashMap *map = [[JavaUtilHashMap alloc] init];
  (void) [map putWithId:@"user_id" withId:[JavaLangInteger valueOfWithInt:[((ComFqHalcyonEntityUser *) nil_chk([ComFqLibToolsConstants getUser])) getUserId]]];
  (void) [map putWithId:@"record_id" withId:[JavaLangInteger valueOfWithInt:recordId]];
  FQJSONObject *json = [ComFqLibJsonHelper createJsonWithJavaUtilMap:map];
  NSString *uri = [NSString stringWithFormat:@"%@/record/over_view_record.do", ComFqLibToolsUriConstants_Conn_get_URL_PUB_()];
  
#line 48
  HalcyonHttpResponseHandle *mHandle = [[ComFqHalcyonLogic2SurveyRecordLogic_$1 alloc] initWithComFqHalcyonLogic2SurveyRecordLogic:self withInt:recordId];
  
#line 75
  if (ComFqLibPlatformPlatform_get_isNetWorkConnect_()) {
    (void) [((ComFqHalcyonApiApiSystem *) nil_chk([ComFqHalcyonApiApiSystem getInstance])) requireWithNSString:uri withComFqHttpAsyncFQHttpParams:[[ComFqHttpAsyncFQHttpParams alloc] initWithFQJSONObject:json] withComFqHalcyonApiApiSystem_API_TYPEEnum:ComFqHalcyonApiApiSystem_API_TYPEEnum_get_DIRECT() withHalcyonHttpResponseHandle:mHandle];
  }
  else {
    
#line 78
    NSString *cache = [ComFqLibFileHelper readStringWithNSString:[NSString stringWithFormat:@"%@%drecord.survey", [((ComFqHalcyonExtendFilesystemFileSystem *) nil_chk([ComFqHalcyonExtendFilesystemFileSystem getInstance])) getUserCachePath], recordId] withBoolean:YES];
    if (cache != nil && ![cache isEqual:@""]) {
      @try {
        [mHandle handleWithInt:0 withNSString:cache withInt:1 withId:[[FQJSONObject alloc] initWithNSString:cache]];
      }
      @catch (
#line 82
      FQJSONException *e) {
        [((FQJSONException *) nil_chk(e)) printStackTrace];
      }
    }
    else {
      
#line 86
      (void) [((ComFqHalcyonApiApiSystem *) nil_chk([ComFqHalcyonApiApiSystem getInstance])) requireWithNSString:uri withComFqHttpAsyncFQHttpParams:[[ComFqHttpAsyncFQHttpParams alloc] initWithFQJSONObject:json] withComFqHalcyonApiApiSystem_API_TYPEEnum:ComFqHalcyonApiApiSystem_API_TYPEEnum_get_DIRECT() withHalcyonHttpResponseHandle:mHandle];
    }
  }
}

- (void)copyAllFieldsTo:(ComFqHalcyonLogic2SurveyRecordLogic *)other {
  [super copyAllFieldsTo:other];
  other->onCallBack_ = onCallBack_;
  other->surItemList_ = surItemList_;
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "initWithComFqHalcyonLogic2SurveyRecordLogic_SurveyRecordCallBack:", "SurveyRecordLogic", NULL, 0x1, NULL },
    { "surveyRecordWithInt:", "surveyRecord", "V", 0x1, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "onCallBack_", NULL, 0x2, "Lcom.fq.halcyon.logic2.SurveyRecordLogic$SurveyRecordCallBack;", NULL,  },
    { "surItemList_", NULL, 0x2, "Ljava.util.ArrayList;", NULL,  },
  };
  static J2ObjcClassInfo _ComFqHalcyonLogic2SurveyRecordLogic = { "SurveyRecordLogic", "com.fq.halcyon.logic2", NULL, 0x1, 2, methods, 2, fields, 0, NULL};
  return &_ComFqHalcyonLogic2SurveyRecordLogic;
}

@end

@interface ComFqHalcyonLogic2SurveyRecordLogic_SurveyRecordCallBack : NSObject
@end

@implementation ComFqHalcyonLogic2SurveyRecordLogic_SurveyRecordCallBack

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "onSurveyErrorWithInt:withNSString:", "onSurveyError", "V", 0x401, NULL },
    { "onSurveyResultWithInt:withJavaUtilArrayList:", "onSurveyResult", "V", 0x401, NULL },
  };
  static J2ObjcClassInfo _ComFqHalcyonLogic2SurveyRecordLogic_SurveyRecordCallBack = { "SurveyRecordCallBack", "com.fq.halcyon.logic2", "SurveyRecordLogic", 0x201, 2, methods, 0, NULL, 0, NULL};
  return &_ComFqHalcyonLogic2SurveyRecordLogic_SurveyRecordCallBack;
}

@end

@implementation ComFqHalcyonLogic2SurveyRecordLogic_$1


#line 51
- (void)onErrorWithInt:(int)code
 withJavaLangThrowable:(JavaLangThrowable *)e {
  
#line 52
  [((id<ComFqHalcyonLogic2SurveyRecordLogic_SurveyRecordCallBack>) nil_chk(this$0_->onCallBack_)) onSurveyErrorWithInt:code withNSString:[((JavaLangThrowable *) nil_chk(e)) getMessage]];
}


#line 56
- (void)handleWithInt:(int)responseCode
         withNSString:(NSString *)msg
              withInt:(int)type
               withId:(id)results {
  
#line 57
  if (responseCode == 0 && type == 1) {
    FQJSONObject *jsonObj = (FQJSONObject *) check_class_cast(results, [FQJSONObject class]);
    id<JavaUtilIterator> keys = [((FQJSONObject *) nil_chk(jsonObj)) keys];
    while ([((id<JavaUtilIterator>) nil_chk(keys)) hasNext]) {
      NSString *key = [keys next];
      NSString *value = [jsonObj optStringWithNSString:key];
      ComFqHalcyonEntitySurveyRecordItem *item = [[ComFqHalcyonEntitySurveyRecordItem alloc] init];
      [item setNameWithNSString:key];
      [item setContentWithNSString:value];
      [((JavaUtilArrayList *) nil_chk(this$0_->surItemList_)) addWithId:item];
    }
    [ComFqLibFileHelper saveFileWithNSString:[nil_chk(results) description] withNSString:[NSString stringWithFormat:@"%@%drecord.survey", [((ComFqHalcyonExtendFilesystemFileSystem *) nil_chk([ComFqHalcyonExtendFilesystemFileSystem getInstance])) getUserCachePath], val$recordId_] withBoolean:YES];
    [((id<ComFqHalcyonLogic2SurveyRecordLogic_SurveyRecordCallBack>) nil_chk(this$0_->onCallBack_)) onSurveyResultWithInt:responseCode withJavaUtilArrayList:this$0_->surItemList_];
  }
  else {
    
#line 71
    [((id<ComFqHalcyonLogic2SurveyRecordLogic_SurveyRecordCallBack>) nil_chk(this$0_->onCallBack_)) onSurveyErrorWithInt:responseCode withNSString:msg];
  }
}

- (id)initWithComFqHalcyonLogic2SurveyRecordLogic:(ComFqHalcyonLogic2SurveyRecordLogic *)outer$
                                          withInt:(int)capture$0 {
  this$0_ = outer$;
  val$recordId_ = capture$0;
  return [super init];
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "onErrorWithInt:withJavaLangThrowable:", "onError", "V", 0x1, NULL },
    { "handleWithInt:withNSString:withInt:withId:", "handle", "V", 0x1, NULL },
    { "initWithComFqHalcyonLogic2SurveyRecordLogic:withInt:", "init", NULL, 0x0, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "this$0_", NULL, 0x1012, "Lcom.fq.halcyon.logic2.SurveyRecordLogic;", NULL,  },
    { "val$recordId_", NULL, 0x1012, "I", NULL,  },
  };
  static J2ObjcClassInfo _ComFqHalcyonLogic2SurveyRecordLogic_$1 = { "$1", "com.fq.halcyon.logic2", "SurveyRecordLogic", 0x8000, 3, methods, 2, fields, 0, NULL};
  return &_ComFqHalcyonLogic2SurveyRecordLogic_$1;
}

@end