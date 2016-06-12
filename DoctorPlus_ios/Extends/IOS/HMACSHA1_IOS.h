//
//  HMACSHA1_IOS.h
//  DocPlus_ios
//
//  Created by 廖敏 on 15/4/20.
//  Copyright (c) 2015年 FQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMACSHA1.h"

@interface HMACSHA1_IOS : NSObject <ComFqLibPlatformHMACSHA1_HMACSHA1Potocol>

+(NSString*)SHA1:(NSString*)source;

+(NSString*)Repeat20TimesAndSHA1:(NSString*)source;

-(NSString *)hmacSHA1AndBase64:(NSString *)plainText withKey:(NSString *)key;

@end
