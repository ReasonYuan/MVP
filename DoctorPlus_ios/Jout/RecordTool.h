//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/lib/record/RecordTool.java
//
//  Created by liaomin on 15-5-4.
//

#ifndef _ComFqLibRecordRecordTool_H_
#define _ComFqLibRecordRecordTool_H_

@class ComFqHalcyonEntityRecordType;
@class FQJSONArray;
@class FQJSONObject;
@class JavaUtilArrayList;
@class JavaUtilHashMap;

#import "JreEmulation.h"

@interface ComFqLibRecordRecordTool : NSObject {
}

+ (void)addMoudleWithInt:(int)type
        withFQJSONObject:(FQJSONObject *)moudle;

+ (FQJSONObject *)getMouldJsonWithFQJSONArray:(FQJSONArray *)moudle
                             withFQJSONObject:(FQJSONObject *)data;

+ (FQJSONObject *)getMoudleByTypeWithInt:(int)type;

+ (JavaUtilArrayList *)getAllRecRecordWithJavaUtilArrayList:(JavaUtilArrayList *)mRecordTypes;

+ (BOOL)isTypeCatchWithComFqHalcyonEntityRecordType:(ComFqHalcyonEntityRecordType *)type;

+ (void)updateDataFromSnapWithJavaUtilArrayList:(JavaUtilArrayList *)types
                          withJavaUtilArrayList:(JavaUtilArrayList *)tps;

+ (void)addAndFormatTypesWithInt:(int)recordType
           withJavaUtilArrayList:(JavaUtilArrayList *)recordTypes;

+ (void)addUploadReocrdWithInt:(int)recordId
         withJavaUtilArrayList:(JavaUtilArrayList *)recordTypes;

+ (void)checkNewTypesWithComFqHalcyonEntityRecordType:(ComFqHalcyonEntityRecordType *)type;

- (id)init;

@end

FOUNDATION_EXPORT BOOL ComFqLibRecordRecordTool_initialized;
J2OBJC_STATIC_INIT(ComFqLibRecordRecordTool)

FOUNDATION_EXPORT JavaUtilHashMap *ComFqLibRecordRecordTool_mRecordMoudles_;
J2OBJC_STATIC_FIELD_GETTER(ComFqLibRecordRecordTool, mRecordMoudles_, JavaUtilHashMap *)

#endif // _ComFqLibRecordRecordTool_H_