//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/entity/RecordItemSamp.java
//
//  Created by liaomin on 15-5-4.
//

#line 1 "/Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/entity/RecordItemSamp.java"

#include "JSONArray.h"
#include "JSONObject.h"
#include "PhotoRecord.h"
#include "RecordItemSamp.h"
#include "TimeFormatUtils.h"
#include "java/util/ArrayList.h"


#line 14
@implementation ComFqHalcyonEntityRecordItemSamp


#line 56
- (NSString *)getUuid {
  
#line 57
  return uuid_;
}


#line 60
- (void)setUuidWithNSString:(NSString *)uuid {
  
#line 61
  self->uuid_ = uuid;
}


#line 64
- (int)getRecordType {
  
#line 65
  return recordType_;
}


#line 68
- (void)setReocrdTypeWithInt:(int)type {
  
#line 69
  recordType_ = type;
}


#line 72
- (void)setPhotosWithJavaUtilArrayList:(JavaUtilArrayList *)photos {
  
#line 73
  mPhotos_ = photos;
}


#line 76
- (BOOL)isShared {
  
#line 77
  return isShared__;
}


#line 80
- (JavaUtilArrayList *)getPhotos {
  
#line 81
  if (mPhotos_ == nil) mPhotos_ = [[JavaUtilArrayList alloc] init];
  return mPhotos_;
}


#line 85
- (int)getRecStatus {
  
#line 86
  return recStatus_;
}


#line 88
- (void)setRecStatusWithInt:(int)recStatus {
  
#line 89
  self->recStatus_ = recStatus;
}


#line 91
- (int)getRecordItemId {
  
#line 92
  return recordItemId_;
}


#line 94
- (void)setRecordItemIdWithInt:(int)recordItemId {
  
#line 95
  self->recordItemId_ = recordItemId;
}


#line 97
- (NSString *)getUploadTime {
  
#line 98
  return uploadTime_;
}


#line 100
- (void)setUploadTimeWithNSString:(NSString *)uploadTime {
  
#line 101
  self->uploadTime_ = uploadTime;
}


#line 103
- (void)setImageCountWithInt:(int)count {
  
#line 104
  self->imageCount_ = count;
}


#line 106
- (int)getImageCount {
  
#line 107
  if (imageCount_ > 0) {
    return imageCount_;
  }
  else
#line 109
  if (mPhotos_ != nil) {
    
#line 111
    return [mPhotos_ size];
  }
  return 0;
}


#line 115
- (void)setRecordInfoIdWithInt:(int)infoId {
  
#line 116
  self->recordInfoId_ = infoId;
}


#line 118
- (int)getRecordInfoId {
  
#line 119
  return self->recordInfoId_;
}


#line 121
- (NSString *)getInfoAbstract {
  
#line 122
  return self->infoabst_;
}

- (void)setAtttributeByjsonWithFQJSONObject:(FQJSONObject *)json {
  
#line 128
  self->recStatus_ = [((FQJSONObject *) nil_chk(json)) optIntWithNSString:@"rec_status"];
  self->imageCount_ = [json optIntWithNSString:@"image_count"];
  self->recordItemId_ = [json optIntWithNSString:@"record_item_id"];
  self->recordInfoId_ = [json optIntWithNSString:@"record_info_id"];
  self->infoabst_ = [json optStringWithNSString:@"info_abstract"];
  self->isShared__ = [json optBooleanWithNSString:@"is_shared"];
  
#line 135
  uploadTime_ = [json optStringWithNSString:@"upload_time"];
  
#line 137
  if (![@"" isEqual:uploadTime_]) {
    long long int date = [ComFqLibToolsTimeFormatUtils getTimeMillisByDateWithSecondsWithNSString:uploadTime_ withNSString:@"yyyy-MM-dd HH:mm"];
    if (date != 0) {
      self->uploadTime_ = [ComFqLibToolsTimeFormatUtils getTimeByFormatWithLong:date withNSString:@"yyyy-MM-dd"];
    }
  }
  
#line 144
  mPhotos_ = [[JavaUtilArrayList alloc] init];
  if (isShared__) {
    ComFqHalcyonEntityPhotoRecord *photo = [[ComFqHalcyonEntityPhotoRecord alloc] init];
    [photo setRecordInfoIdWithInt:recordInfoId_];
    [photo setIsSharedWithBoolean:YES];
    [mPhotos_ addWithId:photo];
  }
  else {
    
#line 151
    FQJSONArray *images = [json optJSONArrayWithNSString:@"images"];
    
#line 153
    if (images != nil) {
      for (int i = 0; i < [images length]; i++) {
        ComFqHalcyonEntityPhotoRecord *photo = [[ComFqHalcyonEntityPhotoRecord alloc] init];
        [photo setAtttributeByjsonWithFQJSONObject:[images optJSONObjectWithInt:i]];
        [photo setRecordInfoIdWithInt:recordInfoId_];
        [mPhotos_ addWithId:photo];
      }
    }
  }
}

- (id)init {
  return [super init];
}

- (void)copyAllFieldsTo:(ComFqHalcyonEntityRecordItemSamp *)other {
  [super copyAllFieldsTo:other];
  other->imageCount_ = imageCount_;
  other->infoabst_ = infoabst_;
  other->isShared__ = isShared__;
  other->mPhotos_ = mPhotos_;
  other->recStatus_ = recStatus_;
  other->recordInfoId_ = recordInfoId_;
  other->recordItemId_ = recordItemId_;
  other->recordType_ = recordType_;
  other->uploadTime_ = uploadTime_;
  other->uuid_ = uuid_;
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "getUuid", NULL, "Ljava.lang.String;", 0x1, NULL },
    { "setUuidWithNSString:", "setUuid", "V", 0x1, NULL },
    { "getRecordType", NULL, "I", 0x1, NULL },
    { "setReocrdTypeWithInt:", "setReocrdType", "V", 0x1, NULL },
    { "setPhotosWithJavaUtilArrayList:", "setPhotos", "V", 0x1, NULL },
    { "isShared", NULL, "Z", 0x1, NULL },
    { "getPhotos", NULL, "Ljava.util.ArrayList;", 0x1, NULL },
    { "getRecStatus", NULL, "I", 0x1, NULL },
    { "setRecStatusWithInt:", "setRecStatus", "V", 0x1, NULL },
    { "getRecordItemId", NULL, "I", 0x1, NULL },
    { "setRecordItemIdWithInt:", "setRecordItemId", "V", 0x1, NULL },
    { "getUploadTime", NULL, "Ljava.lang.String;", 0x1, NULL },
    { "setUploadTimeWithNSString:", "setUploadTime", "V", 0x1, NULL },
    { "setImageCountWithInt:", "setImageCount", "V", 0x1, NULL },
    { "getImageCount", NULL, "I", 0x1, NULL },
    { "setRecordInfoIdWithInt:", "setRecordInfoId", "V", 0x1, NULL },
    { "getRecordInfoId", NULL, "I", 0x1, NULL },
    { "getInfoAbstract", NULL, "Ljava.lang.String;", 0x1, NULL },
    { "setAtttributeByjsonWithFQJSONObject:", "setAtttributeByjson", "V", 0x1, NULL },
    { "init", NULL, NULL, 0x1, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "REC_NONE_DATA_", NULL, 0x19, "I", NULL, .constantValue.asInt = ComFqHalcyonEntityRecordItemSamp_REC_NONE_DATA },
    { "REC_UPLOAD_", NULL, 0x19, "I", NULL, .constantValue.asInt = ComFqHalcyonEntityRecordItemSamp_REC_UPLOAD },
    { "REC_ING_", NULL, 0x19, "I", NULL, .constantValue.asInt = ComFqHalcyonEntityRecordItemSamp_REC_ING },
    { "REC_SUCC_", NULL, 0x19, "I", NULL, .constantValue.asInt = ComFqHalcyonEntityRecordItemSamp_REC_SUCC },
    { "REC_FAIL_", NULL, 0x19, "I", NULL, .constantValue.asInt = ComFqHalcyonEntityRecordItemSamp_REC_FAIL },
    { "serialVersionUID_RecordItemSamp_", "serialVersionUID", 0x1a, "J", NULL, .constantValue.asLong = ComFqHalcyonEntityRecordItemSamp_serialVersionUID },
    { "recordType_", NULL, 0x2, "I", NULL,  },
    { "recStatus_", NULL, 0x2, "I", NULL,  },
    { "recordItemId_", NULL, 0x2, "I", NULL,  },
    { "recordInfoId_", NULL, 0x2, "I", NULL,  },
    { "imageCount_", NULL, 0x2, "I", NULL,  },
    { "uploadTime_", NULL, 0x2, "Ljava.lang.String;", NULL,  },
    { "infoabst_", NULL, 0x2, "Ljava.lang.String;", NULL,  },
    { "mPhotos_", NULL, 0x2, "Ljava.util.ArrayList;", NULL,  },
    { "isShared__", "isShared", 0x2, "Z", NULL,  },
    { "uuid_", NULL, 0x2, "Ljava.lang.String;", NULL,  },
  };
  static J2ObjcClassInfo _ComFqHalcyonEntityRecordItemSamp = { "RecordItemSamp", "com.fq.halcyon.entity", NULL, 0x1, 20, methods, 16, fields, 0, NULL};
  return &_ComFqHalcyonEntityRecordItemSamp;
}

@end