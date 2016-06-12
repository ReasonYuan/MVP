//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/entity/HomeOneDayData.java
//
//  Created by liaomin on 15-5-4.
//

#line 1 "/Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/entity/HomeOneDayData.java"

#include "HomeData.h"
#include "HomeOneDayData.h"
#include "IOSClass.h"
#include "JSONArray.h"
#include "JSONException.h"
#include "JSONObject.h"
#include "TimeFormatUtils.h"
#include "java/lang/IllegalArgumentException.h"
#include "java/util/ArrayList.h"
#include "java/util/Calendar.h"


#line 15
@implementation ComFqHalcyonEntityHomeOneDayData


#line 40
- (int)getmRecRecongnizedNum {
  
#line 41
  return mRecRecongnizedNum_;
}


#line 44
- (void)setmRecRecongnizedNumWithInt:(int)mRecRecongnizedNum {
  
#line 45
  self->mRecRecongnizedNum_ = mRecRecongnizedNum;
}


#line 48
- (JavaUtilArrayList *)getDatas {
  
#line 49
  return mHomeDatas_;
}


#line 52
- (int)getDataCount {
  
#line 53
  return [((JavaUtilArrayList *) nil_chk(mHomeDatas_)) size];
}


#line 56
- (ComFqHalcyonEntityHomeData *)getDataWithInt:(int)index {
  
#line 57
  return [((JavaUtilArrayList *) nil_chk(mHomeDatas_)) getWithInt:index];
}


#line 60
- (ComFqHalcyonEntityHomeOneDayData_CurrSateEnum *)getCurrentSate {
  
#line 61
  return mCurrState_;
}


#line 64
- (long long int)getTimeMillis {
  
#line 65
  return [((JavaUtilCalendar *) nil_chk(mCalendar_)) getTimeInMillis];
}


#line 68
- (JavaUtilCalendar *)getCalendar {
  
#line 69
  return mCalendar_;
}


#line 72
- (int)getMonth {
  
#line 73
  return [((JavaUtilCalendar *) nil_chk(mCalendar_)) getWithInt:JavaUtilCalendar_MONTH];
}


#line 76
- (int)getDayOfWeek {
  
#line 77
  return [((JavaUtilCalendar *) nil_chk(mCalendar_)) getWithInt:JavaUtilCalendar_DAY_OF_WEEK] - 1;
}


#line 80
- (int)getDayOfMonth {
  
#line 81
  return [((JavaUtilCalendar *) nil_chk(mCalendar_)) getWithInt:JavaUtilCalendar_DAY_OF_MONTH];
}


#line 84
- (BOOL)isHaveUnReadData {
  
#line 85
  for (ComFqHalcyonEntityHomeData * __strong data in nil_chk(mHomeDatas_)) {
    if (![((ComFqHalcyonEntityHomeData *) nil_chk(data)) isRead]) {
      return YES;
    }
  }
  return NO;
}


#line 93
- (void)setCalendarWithLong:(long long int)timeMillis {
  [((JavaUtilCalendar *) nil_chk(mCalendar_)) setTimeInMillisWithLong:timeMillis];
  
#line 97
  int state = [ComFqLibToolsTimeFormatUtils dataCompareWithLong:timeMillis];
  switch (state) {
    case -1:
    mCurrState_ = ComFqHalcyonEntityHomeOneDayData_CurrSateEnum_get_BEFO();
    
#line 100
    break;
    case 0:
    mCurrState_ = ComFqHalcyonEntityHomeOneDayData_CurrSateEnum_get_CURR();
    
#line 102
    break;
    case 1:
    mCurrState_ = ComFqHalcyonEntityHomeOneDayData_CurrSateEnum_get_AFTER();
    
#line 104
    break;
  }
}


#line 109
- (void)setAtttributeByjsonWithFQJSONObject:(FQJSONObject *)json {
  
#line 110
  [super setAtttributeByjsonWithFQJSONObject:json];
  
#line 112
  NSString *date = [((FQJSONObject *) nil_chk(json)) optStringWithNSString:@"date"];
  if (date != nil && ![@"" isEqual:date]) {
    long long int time = [ComFqLibToolsTimeFormatUtils getTimeMillisByDateWithNSString:date];
    [self setCalendarWithLong:time];
  }
  [((JavaUtilArrayList *) nil_chk(mHomeDatas_)) clear];
  FQJSONArray *array = [json optJSONArrayWithNSString:@"followups"];
  for (int i = 0; i < [((FQJSONArray *) nil_chk(array)) length]; i++) {
    @try {
      ComFqHalcyonEntityHomeData *data = [[ComFqHalcyonEntityHomeData alloc] init];
      [data setAtttributeByjsonWithFQJSONObject:[array getJSONObjectWithInt:i]];
      [mHomeDatas_ addWithId:data];
    }
    @catch (
#line 124
    FQJSONException *e) {
      [((FQJSONException *) nil_chk(e)) printStackTrace];
    }
  }
}

- (id)init {
  if (self = [super init]) {
    mHomeDatas_ =
#line 25
    [[JavaUtilArrayList alloc] init];
    mCalendar_ =
#line 27
    [JavaUtilCalendar getInstance];
    mRecRecongnizedNum_ =
#line 34
    0;
  }
  return self;
}

- (void)copyAllFieldsTo:(ComFqHalcyonEntityHomeOneDayData *)other {
  [super copyAllFieldsTo:other];
  other->mCalendar_ = mCalendar_;
  other->mCurrState_ = mCurrState_;
  other->mHomeDatas_ = mHomeDatas_;
  other->mRecRecongnizedNum_ = mRecRecongnizedNum_;
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "getmRecRecongnizedNum", NULL, "I", 0x1, NULL },
    { "setmRecRecongnizedNumWithInt:", "setmRecRecongnizedNum", "V", 0x1, NULL },
    { "getDatas", NULL, "Ljava.util.ArrayList;", 0x1, NULL },
    { "getDataCount", NULL, "I", 0x1, NULL },
    { "getDataWithInt:", "getData", "Lcom.fq.halcyon.entity.HomeData;", 0x1, NULL },
    { "getCurrentSate", NULL, "Lcom.fq.halcyon.entity.HomeOneDayData$CurrSate;", 0x1, NULL },
    { "getTimeMillis", NULL, "J", 0x1, NULL },
    { "getCalendar", NULL, "Ljava.util.Calendar;", 0x1, NULL },
    { "getMonth", NULL, "I", 0x1, NULL },
    { "getDayOfWeek", NULL, "I", 0x1, NULL },
    { "getDayOfMonth", NULL, "I", 0x1, NULL },
    { "isHaveUnReadData", NULL, "Z", 0x1, NULL },
    { "setCalendarWithLong:", "setCalendar", "V", 0x1, NULL },
    { "setAtttributeByjsonWithFQJSONObject:", "setAtttributeByjson", "V", 0x1, NULL },
    { "init", NULL, NULL, 0x1, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "serialVersionUID_HomeOneDayData_", "serialVersionUID", 0x1a, "J", NULL, .constantValue.asLong = ComFqHalcyonEntityHomeOneDayData_serialVersionUID },
    { "mHomeDatas_", NULL, 0x2, "Ljava.util.ArrayList;", NULL,  },
    { "mCalendar_", NULL, 0x2, "Ljava.util.Calendar;", NULL,  },
    { "mCurrState_", NULL, 0x2, "Lcom.fq.halcyon.entity.HomeOneDayData$CurrSate;", NULL,  },
    { "mRecRecongnizedNum_", NULL, 0x2, "I", NULL,  },
  };
  static J2ObjcClassInfo _ComFqHalcyonEntityHomeOneDayData = { "HomeOneDayData", "com.fq.halcyon.entity", NULL, 0x1, 15, methods, 5, fields, 0, NULL};
  return &_ComFqHalcyonEntityHomeOneDayData;
}

@end

#line 17

BOOL ComFqHalcyonEntityHomeOneDayData_CurrSateEnum_initialized = NO;

ComFqHalcyonEntityHomeOneDayData_CurrSateEnum *ComFqHalcyonEntityHomeOneDayData_CurrSateEnum_values[3];

@implementation ComFqHalcyonEntityHomeOneDayData_CurrSateEnum

- (id)copyWithZone:(NSZone *)zone {
  return self;
}

- (id)initWithNSString:(NSString *)__name withInt:(int)__ordinal {
  return [super initWithNSString:__name withInt:__ordinal];
}

+ (void)initialize {
  if (self == [ComFqHalcyonEntityHomeOneDayData_CurrSateEnum class]) {
    ComFqHalcyonEntityHomeOneDayData_CurrSateEnum_BEFO = [[ComFqHalcyonEntityHomeOneDayData_CurrSateEnum alloc] initWithNSString:@"BEFO" withInt:0];
    ComFqHalcyonEntityHomeOneDayData_CurrSateEnum_CURR = [[ComFqHalcyonEntityHomeOneDayData_CurrSateEnum alloc] initWithNSString:@"CURR" withInt:1];
    ComFqHalcyonEntityHomeOneDayData_CurrSateEnum_AFTER = [[ComFqHalcyonEntityHomeOneDayData_CurrSateEnum alloc] initWithNSString:@"AFTER" withInt:2];
    ComFqHalcyonEntityHomeOneDayData_CurrSateEnum_initialized = YES;
  }
}

+ (IOSObjectArray *)values {
  return [IOSObjectArray arrayWithObjects:ComFqHalcyonEntityHomeOneDayData_CurrSateEnum_values count:3 type:[IOSClass classWithClass:[ComFqHalcyonEntityHomeOneDayData_CurrSateEnum class]]];
}

+ (ComFqHalcyonEntityHomeOneDayData_CurrSateEnum *)valueOfWithNSString:(NSString *)name {
  for (int i = 0; i < 3; i++) {
    ComFqHalcyonEntityHomeOneDayData_CurrSateEnum *e = ComFqHalcyonEntityHomeOneDayData_CurrSateEnum_values[i];
    if ([name isEqual:[e name]]) {
      return e;
    }
  }
  @throw [[JavaLangIllegalArgumentException alloc] initWithNSString:name];
  return nil;
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "init", NULL, NULL, 0x1, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "BEFO", "BEFO", 0x4019, "Lcom.fq.halcyon.entity.HomeOneDayData$CurrSate;", &ComFqHalcyonEntityHomeOneDayData_CurrSateEnum_BEFO,  },
    { "CURR", "CURR", 0x4019, "Lcom.fq.halcyon.entity.HomeOneDayData$CurrSate;", &ComFqHalcyonEntityHomeOneDayData_CurrSateEnum_CURR,  },
    { "AFTER", "AFTER", 0x4019, "Lcom.fq.halcyon.entity.HomeOneDayData$CurrSate;", &ComFqHalcyonEntityHomeOneDayData_CurrSateEnum_AFTER,  },
  };
  static const char *superclass_type_args[] = {"Lcom.fq.halcyon.entity.HomeOneDayData$CurrSate;"};
  static J2ObjcClassInfo _ComFqHalcyonEntityHomeOneDayData_CurrSateEnum = { "CurrSate", "com.fq.halcyon.entity", "HomeOneDayData", 0x4019, 1, methods, 3, fields, 1, superclass_type_args};
  return &_ComFqHalcyonEntityHomeOneDayData_CurrSateEnum;
}

@end