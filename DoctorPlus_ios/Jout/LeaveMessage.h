//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/halcyon/entity/LeaveMessage.java
//
//  Created by liaomin on 15-5-4.
//

#ifndef _ComFqHalcyonEntityLeaveMessage_H_
#define _ComFqHalcyonEntityLeaveMessage_H_

@class FQJSONObject;

#import "JreEmulation.h"
#include "HalcyonEntity.h"

#define ComFqHalcyonEntityLeaveMessage_serialVersionUID 1LL

@interface ComFqHalcyonEntityLeaveMessage : ComFqHalcyonEntityHalcyonEntity {
 @public
  NSString *mDate_;
  NSString *mName_;
  NSString *mMessage_;
  int roleType_;
}

- (void)test;

- (int)getRoleType;

- (void)setRoleTypeWithInt:(int)roleType;

- (NSString *)getmDate;

- (void)setmDateWithNSString:(NSString *)mDate;

- (NSString *)getmName;

- (void)setmNameWithNSString:(NSString *)mName;

- (NSString *)getmMessage;

- (void)setmMessageWithNSString:(NSString *)mMessage;

- (void)setAtttributeByjsonWithFQJSONObject:(FQJSONObject *)json;

- (id)init;

- (void)copyAllFieldsTo:(ComFqHalcyonEntityLeaveMessage *)other;

@end

__attribute__((always_inline)) inline void ComFqHalcyonEntityLeaveMessage_init() {}

J2OBJC_FIELD_SETTER(ComFqHalcyonEntityLeaveMessage, mDate_, NSString *)
J2OBJC_FIELD_SETTER(ComFqHalcyonEntityLeaveMessage, mName_, NSString *)
J2OBJC_FIELD_SETTER(ComFqHalcyonEntityLeaveMessage, mMessage_, NSString *)

J2OBJC_STATIC_FIELD_GETTER(ComFqHalcyonEntityLeaveMessage, serialVersionUID, long long int)

#endif // _ComFqHalcyonEntityLeaveMessage_H_
