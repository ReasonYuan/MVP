//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/entity/VisualizeCard.java
//
//  Created by liaomin on 15-5-4.
//

#ifndef _ComFqHalcyonEntityVisualizeCard_H_
#define _ComFqHalcyonEntityVisualizeCard_H_

#import "JreEmulation.h"
#include "HalcyonEntity.h"

#define ComFqHalcyonEntityVisualizeCard_serialVersionUID 1LL

@interface ComFqHalcyonEntityVisualizeCard : ComFqHalcyonEntityHalcyonEntity {
 @public
  NSString *cardName_;
  int imageId_;
}

- (NSString *)getCardName;

- (void)setCardNameWithNSString:(NSString *)cardName;

- (int)getImageId;

- (void)setImageIdWithInt:(int)imageId;

- (id)init;

- (void)copyAllFieldsTo:(ComFqHalcyonEntityVisualizeCard *)other;

@end

__attribute__((always_inline)) inline void ComFqHalcyonEntityVisualizeCard_init() {}

J2OBJC_FIELD_SETTER(ComFqHalcyonEntityVisualizeCard, cardName_, NSString *)

J2OBJC_STATIC_FIELD_GETTER(ComFqHalcyonEntityVisualizeCard, serialVersionUID, long long int)

#endif // _ComFqHalcyonEntityVisualizeCard_H_