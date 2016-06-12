//
//  DES3Utils_IOS.m
//  DocPlus_ios
//
//  Created by 廖敏 on 15/4/20.
//  Copyright (c) 2015年 FQ. All rights reserved.
//

#import "DES3Utils_IOS.h"
#import "GTMBase64.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <Security/Security.h>


@implementation DES3Utils_IOS 

- (NSString *)encryptModeWithByteArray:(IOSByteArray *)src
                         withByteArray:(IOSByteArray *)keybyte
{
    return [self encode:[NSString stringWithBytes:src offset:0 length:[src count] encoding:NSUTF8StringEncoding] Key:[NSString stringWithBytes:keybyte offset:0 length:[keybyte count] encoding:NSUTF8StringEncoding]];
}

- (NSString *)decryptModeWithByteArray:(IOSByteArray *)src
                         withByteArray:(IOSByteArray *)keybyte
{

    return [self decode:[NSString stringWithBytes:src offset:0 length:[src count] encoding:NSUTF8StringEncoding] Key:[NSString stringWithBytes:keybyte offset:0 length:[keybyte count] encoding:NSUTF8StringEncoding]];
}

-(NSString*)encode:(NSString*)src Key:(NSString*)key
{
    
    NSData* srcData = [src dataUsingEncoding:NSUTF8StringEncoding];
    
    const void *vplainText;
    size_t plainTextBufferSize;
    
    plainTextBufferSize = [srcData length];
    vplainText = (const void *)[srcData bytes];
    
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *)[key UTF8String];
    
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding | kCCOptionECBMode,
                       vkey,
                       kCCKeySize3DES,
                       nil,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    NSString *result;
    
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    result = [GTMBase64 stringByEncodingData:myData];
    return result;

}


-(NSString*)decode:(NSString*)src Key:(NSString*)key
{
    NSData* srcData = [GTMBase64 decodeData:[src dataUsingEncoding:NSUTF8StringEncoding]];//NSUnicodeStringEncoding
    const void *vplainText;
    size_t plainTextBufferSize;
    
    plainTextBufferSize = [srcData length];
    vplainText = (const void *)[srcData bytes];
    
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    
    const void *vkey = (const void *)[key UTF8String];
    ccStatus = CCCrypt(kCCDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding | kCCOptionECBMode,
                       vkey,
                       kCCKeySize3DES,
                       nil,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    NSString *result;
    result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding];
    if(result)return result;
    return @"";
}

@end
