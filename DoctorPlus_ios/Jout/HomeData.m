//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/entity/HomeData.java
//
//  Created by liaomin on 15-5-4.
//

#line 1 "/Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/entity/HomeData.java"

#include "HomeData.h"
#include "JSONObject.h"


#line 10
@implementation ComFqHalcyonEntityHomeData


#line 44
- (NSString *)getmFollowUpName {
  
#line 45
  return mFollowUpName_;
}


#line 48
- (void)setmFollowUpNameWithNSString:(NSString *)mFollowUpName {
  
#line 49
  self->mFollowUpName_ = mFollowUpName;
}


#line 52
- (NSString *)getmPatientName {
  
#line 53
  return mPatientName_;
}


#line 56
- (void)setmPatientNameWithNSString:(NSString *)mPatientName {
  
#line 57
  self->mPatientName_ = mPatientName;
}


#line 60
- (int)getmFollowUpId {
  
#line 61
  return mFollowUpId_;
}


#line 64
- (void)setmFollowUpIdWithInt:(int)mFollowUpId {
  
#line 65
  self->mFollowUpId_ = mFollowUpId;
}


#line 68
- (NSString *)getmImgPath {
  
#line 69
  return mImgPath_;
}


#line 72
- (void)setmImgPathWithNSString:(NSString *)mImgPath {
  
#line 73
  self->mImgPath_ = mImgPath;
}


#line 76
- (int)getmImgID {
  
#line 77
  return mImgID_;
}


#line 80
- (void)setmImgIDWithInt:(int)mImgID {
  
#line 81
  self->mImgID_ = mImgID;
}


#line 84
- (BOOL)isRead {
  
#line 85
  return mReadFlag_ == ComFqHalcyonEntityHomeData_READ_STATE_YES;
}


#line 88
- (void)setReadWithInt:(int)readFlag {
  
#line 89
  self->mReadFlag_ = readFlag;
}


#line 97
- (void)setAtttributeByjsonWithFQJSONObject:(FQJSONObject *)json {
  
#line 98
  [super setAtttributeByjsonWithFQJSONObject:json];
  self->mFollowUpId_ = [((FQJSONObject *) nil_chk(json)) optIntWithNSString:@"timer_id"];
  self->mImgPath_ = [json optStringWithNSString:@"image_path"];
  self->mImgID_ = [json optIntWithNSString:@"image_id"];
  mReadFlag_ = [json optIntWithNSString:@"read_flag"];
  self->mFollowUpName_ = [json optStringWithNSString:@"followup_name"];
  self->mPatientName_ = [json optStringWithNSString:@"name"];
}


#line 108
- (FQJSONObject *)getJson {
  return [super getJson];
}

- (id)init {
  return [super init];
}

- (void)copyAllFieldsTo:(ComFqHalcyonEntityHomeData *)other {
  [super copyAllFieldsTo:other];
  other->mFollowUpId_ = mFollowUpId_;
  other->mFollowUpName_ = mFollowUpName_;
  other->mImgID_ = mImgID_;
  other->mImgPath_ = mImgPath_;
  other->mPatientName_ = mPatientName_;
  other->mReadFlag_ = mReadFlag_;
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "getmFollowUpName", NULL, "Ljava.lang.String;", 0x1, NULL },
    { "setmFollowUpNameWithNSString:", "setmFollowUpName", "V", 0x1, NULL },
    { "getmPatientName", NULL, "Ljava.lang.String;", 0x1, NULL },
    { "setmPatientNameWithNSString:", "setmPatientName", "V", 0x1, NULL },
    { "getmFollowUpId", NULL, "I", 0x1, NULL },
    { "setmFollowUpIdWithInt:", "setmFollowUpId", "V", 0x1, NULL },
    { "getmImgPath", NULL, "Ljava.lang.String;", 0x1, NULL },
    { "setmImgPathWithNSString:", "setmImgPath", "V", 0x1, NULL },
    { "getmImgID", NULL, "I", 0x1, NULL },
    { "setmImgIDWithInt:", "setmImgID", "V", 0x1, NULL },
    { "isRead", NULL, "Z", 0x1, NULL },
    { "setReadWithInt:", "setRead", "V", 0x1, NULL },
    { "setAtttributeByjsonWithFQJSONObject:", "setAtttributeByjson", "V", 0x1, NULL },
    { "getJson", NULL, "Lcom.fq.lib.json.JSONObject;", 0x1, NULL },
    { "init", NULL, NULL, 0x1, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "READ_STATE_NO_", NULL, 0x1c, "I", NULL, .constantValue.asInt = ComFqHalcyonEntityHomeData_READ_STATE_NO },
    { "READ_STATE_YES_", NULL, 0x19, "I", NULL, .constantValue.asInt = ComFqHalcyonEntityHomeData_READ_STATE_YES },
    { "serialVersionUID_HomeData_", "serialVersionUID", 0x1a, "J", NULL, .constantValue.asLong = ComFqHalcyonEntityHomeData_serialVersionUID },
    { "mFollowUpId_", NULL, 0x2, "I", NULL,  },
    { "mImgPath_", NULL, 0x2, "Ljava.lang.String;", NULL,  },
    { "mImgID_", NULL, 0x2, "I", NULL,  },
    { "mReadFlag_", NULL, 0x2, "I", NULL,  },
    { "mFollowUpName_", NULL, 0x2, "Ljava.lang.String;", NULL,  },
    { "mPatientName_", NULL, 0x2, "Ljava.lang.String;", NULL,  },
  };
  static J2ObjcClassInfo _ComFqHalcyonEntityHomeData = { "HomeData", "com.fq.halcyon.entity", NULL, 0x1, 15, methods, 9, fields, 0, NULL};
  return &_ComFqHalcyonEntityHomeData;
}

@end