//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/HalcyonHttpResponseHandle.java
//
//  Created by liaomin on 15-5-4.
//

#ifndef _ComFqHalcyonHalcyonHttpResponseHandle_H_
#define _ComFqHalcyonHalcyonHttpResponseHandle_H_

@class FQJSONObject;

#import "JreEmulation.h"
#include "FQJsonResponseHandle.h"

#define HalcyonHttpResponseHandle_HALCYON_HTTP_RESPONSE_CODE_SUCCESS 0

@interface HalcyonHttpResponseHandle : FQJsonResponseHandle {
 @public
  BOOL loadCache_;
  NSString *path_;
  NSString *name_;
}

- (void)setPathWithNSString:(NSString *)path
               withNSString:(NSString *)name;

- (BOOL)isLoadCache;

- (void)setLoadCacheWithBoolean:(BOOL)loadCache;

- (void)handleJsonWithFQJSONObject:(FQJSONObject *)json;

- (void)handleJsonWithFQJSONObject:(FQJSONObject *)json
                       withBoolean:(BOOL)isformNet;

- (void)handleWithInt:(int)responseCode
         withNSString:(NSString *)msg
              withInt:(int)type
               withId:(id)results;

- (id)init;

- (void)copyAllFieldsTo:(HalcyonHttpResponseHandle *)other;

@end

__attribute__((always_inline)) inline void HalcyonHttpResponseHandle_init() {}

J2OBJC_FIELD_SETTER(HalcyonHttpResponseHandle, path_, NSString *)
J2OBJC_FIELD_SETTER(HalcyonHttpResponseHandle, name_, NSString *)

J2OBJC_STATIC_FIELD_GETTER(HalcyonHttpResponseHandle, HALCYON_HTTP_RESPONSE_CODE_SUCCESS, int)

#endif // _ComFqHalcyonHalcyonHttpResponseHandle_H_
