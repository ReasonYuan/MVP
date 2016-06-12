//
//  DES3Utils_IOS.h
//  DocPlus_ios
//
//  Created by 廖敏 on 15/4/20.
//  Copyright (c) 2015年 FQ. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DES3Utils.h"

@interface DES3Utils_IOS : NSObject <ComFqLibPlatformDES3Utils_DES3Potocol>

-(NSString*)encode:(NSString*)src Key:(NSString*)key;


-(NSString*)decode:(NSString*)src Key:(NSString*)key;

@end
