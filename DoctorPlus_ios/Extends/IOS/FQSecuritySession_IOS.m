//
//  FQSecuritySession_IOS.m
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/5/4.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "FQSecuritySession_IOS.h"
#import "Constants.h"
#import "User.h"
#import "HMACSHA1.h"
#import "Java/Lang/System.h"
#import "UriConstants.h"

@implementation FQSecuritySession_IOS

static NSString* TOKEN = nil;

static IOSByteArray* mSecuriy3DesKey = nil;

+(void)setAccessToken:(NSString*)token
{
    TOKEN = token;
    if(TOKEN){
        mSecuriy3DesKey = [IOSByteArray arrayWithLength:24];
        IOSByteArray* data = [token getBytes];
        [JavaLangSystem arraycopyWithId:data withInt:0 withId:mSecuriy3DesKey withInt:0 withInt:24];
    }
}


+(IOSByteArray*)getRecord3DesKey{
    return mSecuriy3DesKey;
}

+(NSString*)getAccessToken{
    return TOKEN;
}

+(NSDictionary*)getSessionHeadersWithUrl:(NSString*) resource andMethod:(NSString*) method
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    ComFqHalcyonEntityUser* user = [ComFqLibToolsConstants getUser];
//    if(!TOKEN)[self setAccessToken:@"GY380qSEn1jzE80Uai3346HX"];
    if(TOKEN && user){
        NSString* userId = [NSString stringWithFormat:@"%d",[user getUserId]];
        long long int recordTime = [JavaLangSystem currentTimeMillis];
        NSString* signature = [ComFqLibPlatformHMACSHA1 getSessionSignatureWithNSString:TOKEN withNSString:userId withNSString:method withLong:recordTime withNSString:resource];
        [dic setObject:[NSString stringWithFormat:@"%lld",recordTime]  forKey:@"Expires"];
        [dic setObject:[FQSecuritySession_IOS urlencode:signature]  forKey:@"Authorization"];
        [dic setObject:[NSString stringWithFormat:@"%d",[user getUserId]]  forKey:@"userid"];
    }
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [dic setObject:idfv forKey:@"uuid"];
    return dic;
}

+(NSDictionary*)getSessionHeadersWithFullUrl:(NSString*) resource andMethod:(NSString*) method
{
    return [self getSessionHeadersWithUrl:[resource substringFromIndex:[ComFqLibToolsUriConstants_Conn_get_URL_PUB_() length]] andMethod:method];
}

+(NSString *)urlencode:(NSString*)input {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[input UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end
