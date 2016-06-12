//
//  HMACSHA1_IOS.m
//  DocPlus_ios
//
//  Created by 廖敏 on 15/4/20.
//  Copyright (c) 2015年 FQ. All rights reserved.
//

#import "HMACSHA1_IOS.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import "GTMBase64.h"


@implementation HMACSHA1_IOS 

- (NSString *)getSessionSignatureWithNSString:(NSString *)accessToken
                                 withNSString:(NSString *)userId
                                 withNSString:(NSString *)httpMethod
                                     withLong:(long long int)timestamp
                                 withNSString:(NSString *)resource;
{
 
    NSString* url = resource;
    if ([httpMethod isEqualToString:@"GET"]) {
        if([url indexOfString:@"?"] > 0){
            resource = [url substringToIndex:[url indexOfString:@"?"]];
        }
    }
    NSString* VERB = httpMethod;
    NSString* CONTENT_MD5 = @"";
    NSString* CONTENT_TYPE = @"application/json";
    NSString* DATE = [NSString stringWithFormat:@"%lld",timestamp];
    NSString* CanonicalizedHeaders = @"";
    NSString* CanonicalizedResource = resource;
    NSString* data = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@",VERB,CONTENT_MD5,CONTENT_TYPE,DATE,CanonicalizedHeaders,CanonicalizedResource];
    NSString* signature = [self hmacSHA1AndBase64:data withKey:accessToken];
    return [NSString stringWithFormat:@"YIYI%@:%@\n",userId,signature]; //要手动加个换行符\n才能通过验证，不知道怎么回事
}

-(NSString *)hmacSHA1AndBase64:(NSString *)text withKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    uint8_t cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData* data = [GTMBase64 encodeBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+(NSString*)SHA1:(NSString *)source
{
    const char *cstr = [source cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:source.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+(NSString*)Repeat20TimesAndSHA1:(NSString*)source{
    NSMutableString* str = [[NSMutableString alloc] init];
    for (int i = 0; i < 20 ; i++) {
        [str appendString:source];
    }
    return [HMACSHA1_IOS SHA1:str];
}

@end
