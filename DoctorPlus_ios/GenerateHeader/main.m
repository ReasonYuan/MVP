//
//  main.m
//  GenerateHeader
//
//  Created by 廖敏 on 15/4/24.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeaderFinder : NSObject 
 +(void)appendHeaderDir:(NSString*)path toData:(NSMutableData*)data headerDir:(NSString*)hDir;
@end

@implementation HeaderFinder

+(void)appendHeaderDir:(NSString*)path toData:(NSMutableData*)data headerDir:(NSString*)hDir
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* subFiles = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for (NSString* fileName in subFiles) {
        if([fileName hasSuffix:@".h"]){
            NSString* herder = nil;
            if(hDir){
                herder = [NSString stringWithFormat:@"#import \"%@\/%@\" \n",hDir,fileName];
            }else{
                herder = [NSString stringWithFormat:@"#import \"%@\" \n",fileName];
            }
            [data appendData:[herder dataUsingEncoding:NSUTF8StringEncoding]];
        }else{
            NSString* nexthDir = NULL;
            if(hDir){
                nexthDir = [NSString stringWithFormat:@"%@/%@",hDir,fileName];
            }else{
                nexthDir = fileName;
            }
            [self appendHeaderDir:[NSString stringWithFormat:@"%@/%@",path,fileName] toData:data headerDir:nexthDir];
            
        }
        
    }

}

@end



int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString* bridgeHFileName = @"GenerateHeader.h";
        NSFileManager* fileManager = [NSFileManager defaultManager];
        
        NSFileHandle* handle = [NSFileHandle fileHandleForWritingAtPath:[NSString stringWithFormat:@"%@/DoctorPlus_ios/%@",PROJECT_DIR,bridgeHFileName]];
        NSMutableData* data = [[NSMutableData alloc] init];
        
        NSString* herder = [NSString stringWithFormat:@"#import \"%@\" \n",@"J2ObjC_common.h"];
        [data appendData:[herder dataUsingEncoding:NSUTF8StringEncoding]];
        
//        [HeaderFinder appendHeaderDir:[NSString stringWithFormat:@"%@/IOS",PROJECT_DIR] toData:data headerDir:nil];
        [HeaderFinder appendHeaderDir:[NSString stringWithFormat:@"%@/j2objc-0.9.3/include/java/lang",PROJECT_DIR] toData:data headerDir:@"java/lang"];
        [HeaderFinder appendHeaderDir:[NSString stringWithFormat:@"%@/j2objc-0.9.3/include/java/util",PROJECT_DIR] toData:data headerDir:@"java/util"];
        [HeaderFinder appendHeaderDir:[NSString stringWithFormat:@"%@/j2objc-0.9.3/include/java/io",PROJECT_DIR] toData:data headerDir:@"java/io"];
        [HeaderFinder appendHeaderDir:[NSString stringWithFormat:@"%@/Jout",PROJECT_DIR] toData:data headerDir:nil];
        
        
//
        [handle writeData:data];

    }
    return 0;
}
