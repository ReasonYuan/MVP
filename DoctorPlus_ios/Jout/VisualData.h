//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/entity/visualize/VisualData.java
//
//  Created by liaomin on 15-5-4.
//

#ifndef _ComFqHalcyonEntityVisualizeVisualData_H_
#define _ComFqHalcyonEntityVisualizeVisualData_H_

@class ComFqHalcyonEntityVisualizeVisualizeEntity_VISUALTYPEEnum;
@class JavaUtilArrayList;

#import "JreEmulation.h"
#include "VisualizeEntity.h"

#define ComFqHalcyonEntityVisualizeVisualData_serialVersionUID 1LL

@interface ComFqHalcyonEntityVisualizeVisualData : ComFqHalcyonEntityVisualizeVisualizeEntity {
 @public
  NSString *dataColumn_;
  JavaUtilArrayList *recordIds_;
}

- (id)initWithComFqHalcyonEntityVisualizeVisualizeEntity_VISUALTYPEEnum:(ComFqHalcyonEntityVisualizeVisualizeEntity_VISUALTYPEEnum *)tp;

- (void)setDataColumnWithNSString:(NSString *)data;

- (void)setRecordIdsWithJavaUtilArrayList:(JavaUtilArrayList *)ids;

- (NSString *)getURL;

- (NSString *)getPraDataType;

- (NSString *)getPraDataColumn;

- (NSString *)getPraRecordIds;

- (void)copyAllFieldsTo:(ComFqHalcyonEntityVisualizeVisualData *)other;

@end

__attribute__((always_inline)) inline void ComFqHalcyonEntityVisualizeVisualData_init() {}

J2OBJC_FIELD_SETTER(ComFqHalcyonEntityVisualizeVisualData, dataColumn_, NSString *)
J2OBJC_FIELD_SETTER(ComFqHalcyonEntityVisualizeVisualData, recordIds_, JavaUtilArrayList *)

J2OBJC_STATIC_FIELD_GETTER(ComFqHalcyonEntityVisualizeVisualData, serialVersionUID, long long int)

#endif // _ComFqHalcyonEntityVisualizeVisualData_H_