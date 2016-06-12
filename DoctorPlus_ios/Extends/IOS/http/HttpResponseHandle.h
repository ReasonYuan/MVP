//
//  FQHttpResponseHandle.h
//  FangTai
//
//  Created by liaomin on 14-8-5.
//  Copyright (c) 2014年 FQ. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FQHttpParams.h"
#import "FQHttpResponseHandle.h"
#import "ParamsWrapper.h"
#import "AFNetworking.h"
#import "Java/util/ArrayList.h"
#import "HttpRequestPotocol.h"

@interface HttpResponseHandle : NSObject <ComFqHttpPotocolHttpRequestPotocol>
{
    AFHTTPRequestOperation* req;
    NSArray *arr;
    NSString *eventSuc;
    NSMutableString *eventFail;
    NSDate* dat1;
}

-(id)initUrl:(NSString*)url WithParams:(ComFqHttpAsyncParamsWrapper*)params andHandle:(FQHttpResponseHandle *)handle isPost:(BOOL) post;

-(id)initUrl:(NSString*)url WithParams:(ComFqHttpAsyncParamsWrapper*)params andHandle:(FQHttpResponseHandle *)handle isPost:(BOOL) post timeout:(NSInteger)timeout;

@property(strong,nonatomic) ComFqHttpAsyncParamsWrapper* params;

@property(strong,nonatomic) FQHttpResponseHandle* handle;

@end
