//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/lib/JsonHelper.java
//
//  Created by liaomin on 15-5-4.
//

#ifndef _ComFqLibJsonHelper_H_
#define _ComFqLibJsonHelper_H_

@class FQJSONArray;
@class FQJSONObject;
@protocol ComFqHttpPotocolFQHttpResponseInterface;
@protocol JavaUtilMap;

#import "JreEmulation.h"

#define ComFqLibJsonHelper_REC_CODE_SUCC 0

@interface ComFqLibJsonHelper : NSObject {
}

+ (FQJSONObject *)createJsonWithJavaUtilMap:(id<JavaUtilMap>)map;

+ (FQJSONObject *)createJsonForDebugWithJavaUtilMap:(id<JavaUtilMap>)map;

+ (FQJSONArray *)parseJsonArrayWithNSString:(NSString *)jsonString;

+ (FQJSONObject *)parseJsonObjectWithNSString:(NSString *)jsonObject;

+ (FQJSONArray *)parseJsonArrayWithFQJSONObject:(FQJSONObject *)json
    withComFqHttpPotocolFQHttpResponseInterface:(id<ComFqHttpPotocolFQHttpResponseInterface>)inf;

+ (FQJSONObject *)parseJsonObjectWithFQJSONObject:(FQJSONObject *)json
      withComFqHttpPotocolFQHttpResponseInterface:(id<ComFqHttpPotocolFQHttpResponseInterface>)inf;

+ (FQJSONObject *)loadJsonObjectByFileWithNSString:(NSString *)path
                                      withNSString:(NSString *)name;

- (id)init;

@end

__attribute__((always_inline)) inline void ComFqLibJsonHelper_init() {}

FOUNDATION_EXPORT NSString *ComFqLibJsonHelper_TAG_;
J2OBJC_STATIC_FIELD_GETTER(ComFqLibJsonHelper, TAG_, NSString *)
J2OBJC_STATIC_FIELD_SETTER(ComFqLibJsonHelper, TAG_, NSString *)

FOUNDATION_EXPORT NSString *ComFqLibJsonHelper_REQ_RECORD_;
J2OBJC_STATIC_FIELD_GETTER(ComFqLibJsonHelper, REQ_RECORD_, NSString *)

FOUNDATION_EXPORT NSString *ComFqLibJsonHelper_REC_CODE_;
J2OBJC_STATIC_FIELD_GETTER(ComFqLibJsonHelper, REC_CODE_, NSString *)

FOUNDATION_EXPORT NSString *ComFqLibJsonHelper_REC_MSG_;
J2OBJC_STATIC_FIELD_GETTER(ComFqLibJsonHelper, REC_MSG_, NSString *)

FOUNDATION_EXPORT NSString *ComFqLibJsonHelper_REC_RESULT_;
J2OBJC_STATIC_FIELD_GETTER(ComFqLibJsonHelper, REC_RESULT_, NSString *)

J2OBJC_STATIC_FIELD_GETTER(ComFqLibJsonHelper, REC_CODE_SUCC, int)

#endif // _ComFqLibJsonHelper_H_