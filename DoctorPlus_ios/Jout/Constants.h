//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/liaomin/Documents/workspace/Android/DocPlusLogic/src/com/fq/lib/tools/Constants.java
//
//  Created by liaomin on 15-5-4.
//

#ifndef _ComFqLibToolsConstants_H_
#define _ComFqLibToolsConstants_H_

@class ComFqHalcyonEntityUser;
@class IOSByteArray;
@class JavaUtilArrayList;
@class JavaUtilHashMap;

#import "JreEmulation.h"

#define ComFqLibToolsConstants_CLIENT_DOCTOR_ANDORID 1
#define ComFqLibToolsConstants_CLIENT_DOCTOR_IOS 2
#define ComFqLibToolsConstants_CLIENT_HEALTH_ANDORID 3
#define ComFqLibToolsConstants_CLIENT_HEALTH_IOS 4
#define ComFqLibToolsConstants_FEMALE 1
#define ComFqLibToolsConstants_MALE 2
#define ComFqLibToolsConstants_ROLE_DOCTOR 1
#define ComFqLibToolsConstants_ROLE_DOCTOR_STUDENT 2
#define ComFqLibToolsConstants_ROLE_PATIENT 3

@interface ComFqLibToolsConstants : NSObject {
}

+ (void)setUserWithComFqHalcyonEntityUser:(ComFqHalcyonEntityUser *)user;

+ (ComFqHalcyonEntityUser *)getUser;

+ (BOOL)isLogined;

+ (NSString *)getShareTextWithInt:(int)type;

+ (NSString *)getShareTitle;

- (id)init;

@end

FOUNDATION_EXPORT BOOL ComFqLibToolsConstants_initialized;
J2OBJC_STATIC_INIT(ComFqLibToolsConstants)

FOUNDATION_EXPORT BOOL ComFqLibToolsConstants_TARGET_FOR_IOS_;
J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsConstants, TARGET_FOR_IOS_, BOOL)
J2OBJC_STATIC_FIELD_REF_GETTER(ComFqLibToolsConstants, TARGET_FOR_IOS_, BOOL)

FOUNDATION_EXPORT BOOL ComFqLibToolsConstants_DEBUG__;
J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsConstants, DEBUG__, BOOL)
J2OBJC_STATIC_FIELD_REF_GETTER(ComFqLibToolsConstants, DEBUG__, BOOL)

J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsConstants, MALE, short int)

J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsConstants, FEMALE, short int)

J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsConstants, ROLE_DOCTOR, int)

J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsConstants, ROLE_DOCTOR_STUDENT, int)

J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsConstants, ROLE_PATIENT, int)

J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsConstants, CLIENT_DOCTOR_ANDORID, int)

J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsConstants, CLIENT_DOCTOR_IOS, int)

J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsConstants, CLIENT_HEALTH_ANDORID, int)

J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsConstants, CLIENT_HEALTH_IOS, int)

FOUNDATION_EXPORT IOSByteArray *ComFqLibToolsConstants_KEY_STRING_;
J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsConstants, KEY_STRING_, IOSByteArray *)
J2OBJC_STATIC_FIELD_SETTER(ComFqLibToolsConstants, KEY_STRING_, IOSByteArray *)

FOUNDATION_EXPORT NSString *ComFqLibToolsConstants_KEY_CTS_;
J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsConstants, KEY_CTS_, NSString *)
J2OBJC_STATIC_FIELD_SETTER(ComFqLibToolsConstants, KEY_CTS_, NSString *)

FOUNDATION_EXPORT ComFqHalcyonEntityUser *ComFqLibToolsConstants_mUser_;
J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsConstants, mUser_, ComFqHalcyonEntityUser *)
J2OBJC_STATIC_FIELD_SETTER(ComFqLibToolsConstants, mUser_, ComFqHalcyonEntityUser *)

FOUNDATION_EXPORT JavaUtilArrayList *ComFqLibToolsConstants_tagList_;
J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsConstants, tagList_, JavaUtilArrayList *)
J2OBJC_STATIC_FIELD_SETTER(ComFqLibToolsConstants, tagList_, JavaUtilArrayList *)

FOUNDATION_EXPORT JavaUtilHashMap *ComFqLibToolsConstants_contactsMap_;
J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsConstants, contactsMap_, JavaUtilHashMap *)
J2OBJC_STATIC_FIELD_SETTER(ComFqLibToolsConstants, contactsMap_, JavaUtilHashMap *)

FOUNDATION_EXPORT JavaUtilArrayList *ComFqLibToolsConstants_contactsList_;
J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsConstants, contactsList_, JavaUtilArrayList *)
J2OBJC_STATIC_FIELD_SETTER(ComFqLibToolsConstants, contactsList_, JavaUtilArrayList *)

FOUNDATION_EXPORT JavaUtilArrayList *ComFqLibToolsConstants_alarms_;
J2OBJC_STATIC_FIELD_GETTER(ComFqLibToolsConstants, alarms_, JavaUtilArrayList *)
J2OBJC_STATIC_FIELD_SETTER(ComFqLibToolsConstants, alarms_, JavaUtilArrayList *)

#endif // _ComFqLibToolsConstants_H_