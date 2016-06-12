//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/uimodels/OneCopy.java
//
//  Created by liaomin on 15-5-4.
//

#line 1 "/Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/uimodels/OneCopy.java"

#include "JSONArray.h"
#include "JSONException.h"
#include "JSONObject.h"
#include "OneCopy.h"
#include "PhotoRecord.h"
#include "java/lang/Exception.h"
#include "java/util/ArrayList.h"


#line 13
@implementation ComFqHalcyonUimodelsOneCopy


#line 25
- (id)initWithInt:(int)type {
  if (self = [super init]) {
    photos_ =
#line 29
    [[JavaUtilArrayList alloc] init];
    
#line 26
    self->recordItemType_ = type;
  }
  return self;
}


#line 31
- (void)addPhotoWithComFqHalcyonEntityPhotoRecord:(ComFqHalcyonEntityPhotoRecord *)photo {
  
#line 33
  [((JavaUtilArrayList *) nil_chk(photos_)) addWithId:photo];
}


#line 39
- (int)getType {
  
#line 40
  return recordItemType_;
}


#line 43
- (void)setTypeWithInt:(int)type {
  
#line 44
  self->recordItemType_ = type;
}


#line 47
- (JavaUtilArrayList *)getPhotos {
  
#line 48
  return photos_;
}


#line 51
- (void)setRecrodIdWithInt:(int)id_ {
  
#line 52
  recordId_ = id_;
}


#line 55
- (int)getRecordId {
  
#line 56
  return recordId_;
}


#line 59
- (void)addPhotosWithJavaUtilArrayList:(JavaUtilArrayList *)photos {
  
#line 60
  [((JavaUtilArrayList *) nil_chk(photos)) addAllWithJavaUtilCollection:photos];
}


#line 63
- (void)setIndefyStateWithInt:(int)state {
  
#line 64
  indefyState_ = state;
}


#line 67
- (int)getIndefySate {
  
#line 68
  return indefyState_;
}


#line 71
- (FQJSONObject *)getJsonObj {
  
#line 72
  FQJSONObject *json = [[FQJSONObject alloc] init];
  FQJSONArray *jsonArray = [[FQJSONArray alloc] init];
  for (int i = 0; i < [((JavaUtilArrayList *) nil_chk(photos_)) size]; i++) {
    (void) [jsonArray putWithId:[((ComFqHalcyonEntityPhotoRecord *) nil_chk([photos_ getWithInt:i])) getJson]];
  }
  @try {
    if (recordId_ != 0) (void) [json putWithNSString:@"record_id" withInt:recordId_];
    (void) [json putWithNSString:@"photos" withId:jsonArray];
  }
  @catch (
#line 80
  FQJSONException *e) {
    [((FQJSONException *) nil_chk(e)) printStackTrace];
  }
  return json;
}


#line 86
- (void)setAtttributeByjsonWithFQJSONObject:(FQJSONObject *)json {
  
#line 87
  @try {
    recordId_ = [((FQJSONObject *) nil_chk(json)) optIntWithNSString:@"record_id"];
    FQJSONArray *array = [json optJSONArrayWithNSString:@"photos"];
    if ([((FQJSONArray *) nil_chk(array)) length] < 1) return;
    for (int i = 0; i < [array length]; i++) {
      ComFqHalcyonEntityPhotoRecord *photo = [[ComFqHalcyonEntityPhotoRecord alloc] init];
      [photo setAtttributeByjsonWithFQJSONObject:[array getJSONObjectWithInt:i]];
      [((JavaUtilArrayList *) nil_chk(photos_)) addWithId:photo];
    }
  }
  @catch (
#line 96
  JavaLangException *e) {
    [((JavaLangException *) nil_chk(e)) printStackTrace];
  }
}


#line 101
- (int)getOnePhotoId {
  
#line 102
  return [((ComFqHalcyonEntityPhotoRecord *) nil_chk([((JavaUtilArrayList *) nil_chk(photos_)) getWithInt:0])) getImageId];
}


#line 105
- (BOOL)isHavePhotoByIdWithInt:(int)id_ {
  
#line 106
  for (int i = 0; i < [((JavaUtilArrayList *) nil_chk(photos_)) size]; i++) {
    if (id_ == [((ComFqHalcyonEntityPhotoRecord *) nil_chk([photos_ getWithInt:i])) getImageId]) {
      return YES;
    }
  }
  return NO;
}


#line 114
- (BOOL)isHavePhotoByUrlWithNSString:(NSString *)url {
  
#line 115
  for (int i = 0; i < [((JavaUtilArrayList *) nil_chk(photos_)) size]; i++) {
    if ([((NSString *) nil_chk(url)) isEqual:[((ComFqHalcyonEntityPhotoRecord *) nil_chk([photos_ getWithInt:i])) getLocalPath]]) {
      return YES;
    }
  }
  return NO;
}

- (void)copyAllFieldsTo:(ComFqHalcyonUimodelsOneCopy *)other {
  [super copyAllFieldsTo:other];
  other->indefyState_ = indefyState_;
  other->photos_ = photos_;
  other->recordId_ = recordId_;
  other->recordItemType_ = recordItemType_;
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "initWithInt:", "OneCopy", NULL, 0x1, NULL },
    { "addPhotoWithComFqHalcyonEntityPhotoRecord:", "addPhoto", "V", 0x1, NULL },
    { "getType", NULL, "I", 0x1, NULL },
    { "setTypeWithInt:", "setType", "V", 0x1, NULL },
    { "getPhotos", NULL, "Ljava.util.ArrayList;", 0x1, NULL },
    { "setRecrodIdWithInt:", "setRecrodId", "V", 0x1, NULL },
    { "getRecordId", NULL, "I", 0x1, NULL },
    { "addPhotosWithJavaUtilArrayList:", "addPhotos", "V", 0x1, NULL },
    { "setIndefyStateWithInt:", "setIndefyState", "V", 0x1, NULL },
    { "getIndefySate", NULL, "I", 0x1, NULL },
    { "getJsonObj", NULL, "Lcom.fq.lib.json.JSONObject;", 0x1, NULL },
    { "setAtttributeByjsonWithFQJSONObject:", "setAtttributeByjson", "V", 0x1, NULL },
    { "getOnePhotoId", NULL, "I", 0x1, NULL },
    { "isHavePhotoByIdWithInt:", "isHavePhotoById", "Z", 0x1, NULL },
    { "isHavePhotoByUrlWithNSString:", "isHavePhotoByUrl", "Z", 0x1, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "serialVersionUID_", NULL, 0x1a, "J", NULL, .constantValue.asLong = ComFqHalcyonUimodelsOneCopy_serialVersionUID },
    { "recordId_", NULL, 0x2, "I", NULL,  },
    { "indefyState_", NULL, 0x2, "I", NULL,  },
    { "recordItemType_", NULL, 0x2, "I", NULL,  },
    { "photos_", NULL, 0x1, "Ljava.util.ArrayList;", NULL,  },
  };
  static J2ObjcClassInfo _ComFqHalcyonUimodelsOneCopy = { "OneCopy", "com.fq.halcyon.uimodels", NULL, 0x1, 15, methods, 5, fields, 0, NULL};
  return &_ComFqHalcyonUimodelsOneCopy;
}

@end