//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/entity/SurveyRecordItem.java
//
//  Created by liaomin on 15-5-4.
//

#line 1 "/Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/entity/SurveyRecordItem.java"

#include "SurveyRecordItem.h"


#line 4
@implementation ComFqHalcyonEntitySurveyRecordItem


#line 11
- (NSString *)getName {
  
#line 12
  return name_SurveyRecordItem_;
}


#line 14
- (void)setNameWithNSString:(NSString *)name {
  
#line 15
  self->name_SurveyRecordItem_ = name;
}


#line 17
- (NSString *)getContent {
  
#line 18
  return content_;
}


#line 20
- (void)setContentWithNSString:(NSString *)content {
  
#line 21
  self->content_ = content;
}

- (id)init {
  return [super init];
}

- (void)copyAllFieldsTo:(ComFqHalcyonEntitySurveyRecordItem *)other {
  [super copyAllFieldsTo:other];
  other->content_ = content_;
  other->name_SurveyRecordItem_ = name_SurveyRecordItem_;
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "getName", NULL, "Ljava.lang.String;", 0x1, NULL },
    { "setNameWithNSString:", "setName", "V", 0x1, NULL },
    { "getContent", NULL, "Ljava.lang.String;", 0x1, NULL },
    { "setContentWithNSString:", "setContent", "V", 0x1, NULL },
    { "init", NULL, NULL, 0x1, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "serialVersionUID_SurveyRecordItem_", "serialVersionUID", 0x1a, "J", NULL, .constantValue.asLong = ComFqHalcyonEntitySurveyRecordItem_serialVersionUID },
    { "name_SurveyRecordItem_", "name", 0x2, "Ljava.lang.String;", NULL,  },
    { "content_", NULL, 0x2, "Ljava.lang.String;", NULL,  },
  };
  static J2ObjcClassInfo _ComFqHalcyonEntitySurveyRecordItem = { "SurveyRecordItem", "com.fq.halcyon.entity", NULL, 0x1, 5, methods, 3, fields, 0, NULL};
  return &_ComFqHalcyonEntitySurveyRecordItem;
}

@end