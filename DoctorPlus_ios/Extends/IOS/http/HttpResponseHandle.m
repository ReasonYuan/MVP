//
//  FQHttpResponseHandle.m
//  FangTai
//
//  Created by liaomin on 14-8-5.
//  Copyright (c) 2014年 FQ. All rights reserved.
//

#import "HttpResponseHandle.h"
#import "FQBinaryResponseHandle.h"
#import "FQJsonResponseHandle.h"
#import "JSONObject.h"
#import "JSONArray.h"
#import "Java/lang/Throwable.h"
//#import "Java/lang/Iterator.h"
#import "Java/Util/Concurrent/ConcurrentHashMap.h"
#import "HttpClient_IOS.h"
#import "UriConstants.h"
#import "DES3Utils.h"
#import "FQHeader.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "FQSecuritySession_IOS.h"
#import "UriConstants.h"
#import "Java/io/File.h"
#import "FQBinaryResponseHandle.h"
#import "HttpClientPotocol.h"
#import "TalkingData.h"
#import "UpLoadObject.h"
#define DEFAULT_TIME_OUT  10

#define CONNECT_ERRO_CODE  -1
#define EXCEPT_ERRO_CODE   -2

@implementation HttpResponseHandle


- (void)cancel
{
    if(req){
        [req cancel];
    }
}

-(id)initUrl:(NSString *)url WithParams:(ComFqHttpAsyncParamsWrapper *)params andHandle:(FQHttpResponseHandle *)handle isPost:(BOOL)post
{
    return [self initUrl:url WithParams:params andHandle:handle isPost:post timeout:DEFAULT_TIME_OUT];
}

+(NSMutableDictionary*)getDic:(ComFqHttpAsyncParamsWrapper *)params
{
    NSMutableDictionary* par = [[NSMutableDictionary alloc] init];
    if(params){
        if([params isJsonParams]){
            FQJSONObject* json = [[FQJSONObject alloc] initWithNSString:[params getStringParams]];
            par = [HttpResponseHandle DecodeJsonObject:json];
        }else{
            par =[[NSMutableDictionary alloc] init];
            JavaUtilConcurrentConcurrentHashMap* map = params->urlParamsWithObjects_;
            id<JavaUtilIterator> itor = [[map keySet] iterator];
            while ([itor hasNext]) {
                NSString* key =[itor next];
                NSString *value = [map getWithId:key];
                [par setObject:value forKey:key];
            }

        }
    }
    return par;
}

+(NSMutableDictionary*)DecodeJsonObject:(FQJSONObject*)json
{
     NSMutableDictionary* par = [[NSMutableDictionary alloc] init];
    if(json){
        id<JavaUtilIterator> itor = [json keys];
        while ([itor hasNext]) {
            NSString* key = [itor next];
            id value  = [json optWithNSString:key];
            if([value isKindOfClass:[FQJSONObject class]]){
                value = [HttpResponseHandle DecodeJsonObject:value];
            }else if([value isKindOfClass:[FQJSONArray class]]){
                value = [HttpResponseHandle DecodeJsonArray:value];
            }
            [par setObject:value forKey:key];
        }
    }
    return par;
}


+(NSMutableArray*)DecodeJsonArray:(FQJSONArray*)jsonArray
{
    NSMutableArray* par = [[NSMutableArray alloc] init];
    if(jsonArray){
        for (int i = 0; i < [jsonArray length]; i++) {
            id value = [jsonArray getWithInt:i];
            if([value isKindOfClass:[FQJSONObject class]]){
                value = [HttpResponseHandle DecodeJsonObject:value];
            }else if([value isKindOfClass:[FQJSONArray class]]){
                value = [HttpResponseHandle DecodeJsonArray:value];
            }
            [par addObject:value];
        }
    }
    return par;
}

-(id)initUrl:(NSString *)url WithParams:(ComFqHttpAsyncParamsWrapper *)params andHandle:(FQHttpResponseHandle *)handle isPost:(BOOL)post timeout:(NSInteger)timeout
{
    NSString *setUrl = [url stringByReplacingOccurrencesOfString:@"_" withString:@""];
    arr = [setUrl componentsSeparatedByString:@"/"];
    eventFail = [[NSMutableString alloc]initWithString:arr.lastObject];
    NSString *str = [arr objectAtIndex:arr.count-2];
    [eventFail insertString:str atIndex:0];
    if (eventFail.length >33) {
        eventSuc = [eventFail substringToIndex:30];
    }else{
        eventSuc = [eventFail substringToIndex:eventFail.length-3];
    }
    eventSuc = [eventSuc stringByReplacingOccurrencesOfString:@"get" withString:@""];
    
    [eventFail setString:eventSuc];
    [eventFail appendString:@"F"];
    dat1 = [NSDate date];
    self = [super init];
    if(self)
    {
        self.params = params;
        self.handle = handle;
        if([handle isKindOfClass:[FQBinaryResponseHandle class]]){
            [((FQBinaryResponseHandle*)self.handle) setParamsWithComFqHttpAsyncParamsWrapper:params];
        }
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        if(!ComFqLibToolsUriConstants_Conn_DO_NOT_VERIFY_CERTIFICATE){
            AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
            securityPolicy.validatesCertificateChain = NO; //不用验证toolChain，只验证一个
             manager.securityPolicy = securityPolicy;
        }else{
             manager.securityPolicy.allowInvalidCertificates = YES;
        }
        manager.requestSerializer = [AFJSONRequestSerializer serializer];   //json请求
        manager.responseSerializer = [AFHTTPResponseSerializer serializer]; //json返回
//        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        NSDictionary* sessionHeaders = [FQSecuritySession_IOS getSessionHeadersWithUrl:[url substringFromIndex:[ComFqLibToolsUriConstants_Conn_get_URL_PUB_() length]] andMethod:post?@"POST":@"GET"];
        for (NSString* key in sessionHeaders){
            NSString* value = [sessionHeaders objectForKey:key];
            [manager.requestSerializer setValue:value forHTTPHeaderField:key];
        }
        
        NSMutableDictionary* parameters = [HttpResponseHandle getDic:params];
        if(self.params){
            [manager.requestSerializer setTimeoutInterval:[self.params getTimeoutTime]/1000];
        }else{
            [manager.requestSerializer setTimeoutInterval:10];
        }
        if(post){
            IOSObjectArray* headers = [handle getRequestHeaders];
            if(headers){
                for (int i = 0; i < [headers count]; i++) {
                    ComFqHttpAsyncFQHeader* fqHeader = (ComFqHttpAsyncFQHeader*)[headers objectAtIndex:i];
                    [manager.requestSerializer setValue:fqHeader->value_ forHTTPHeaderField:fqHeader->key_];
                }
            }
            if(self.params && params->fileParams_ && [params->fileParams_ size] > 0){ //上传文件
                req = [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                    if(self.params){
                        JavaUtilConcurrentConcurrentHashMap* map = params->fileParams_;
                        id<JavaUtilIterator> itor = [[map keySet] iterator];
                        while ([itor hasNext]) {
                            NSString* key = [itor next];
                            ComLoopjAndroidHttpRequestParams_FileWrapper* warpper = [map getWithId:key];
                            JavaIoFile* jFile = warpper->file_;
                            NSString* filePath = [jFile getAbsoluteName];
                            [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:key error:nil];
                        }
                        NSArray* keys =  [parameters allKeys];
                        for (NSString* key in keys) {
                            NSObject* value = [parameters objectForKey:key];
//                            [formData appendPartWithFormData:[value.description dataUsingEncoding:NSUTF8StringEncoding] name:key];
                        }
                        
                    }
                } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [self requestDidFinish:operation withData:[operation responseData]];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [self requestDidFail:operation withError:error];
                }];
                
            }else{
                req = [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [self requestDidFinish:operation withData:[operation responseData]];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [self requestDidFail:operation withError:error];
                }];
            }
        
        }else{
            req = [manager GET:url parameters:[self.params getStringParams] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 [self requestDidFinish:operation withData:[operation responseData]];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [self requestDidFail:operation withError:error];
            }]; 
        }
        
        [req setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            if(params->downLoadProgress_) {
                float downLoadProgress = totalBytesRead / (double)totalBytesExpectedToRead;
//                NSLog(@"----下载进度:%f",downLoadProgress);
                id progressView = params.getTag;
                [params->downLoadProgress_ downLoadProgressWithFloat:downLoadProgress withInt:(int)[parameters objectForKey:@"image_id"] withId:progressView];
            }
            
        }];
        
//        if(params->upLoadProcess_){
            [req setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                float process = totalBytesWritten / (double)totalBytesExpectedToWrite;
                if (params->upLoadProcess_) {
                    [params->upLoadProcess_ setProcessWithFloat:process];
                }
                
                if(params->upLoadProgress_){
                    if(params->tag_){
                        ComFqHalcyonEntityPracticeUpLoadObject *object = (ComFqHalcyonEntityPracticeUpLoadObject*)[params getTag];
                        [params->upLoadProgress_ upLoadProgressWithFloat:process withNSString:[object getImageName] withId:object];
                    }
                }
//                 NSLog(@"-->uploadFile  process:%f",process);
            }];
//        }
        [req setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
            NSString *url = [request.URL absoluteString];
            if([url indexOfString:ComFqLibToolsUriConstants_Conn_get_URL_PUB_()] < 0){
                NSMutableURLRequest* newRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
                NSDictionary* oldHeader = request.allHTTPHeaderFields;
                for (NSString *key in oldHeader) {
                    NSString* value = [oldHeader objectForKey:key];
                    [newRequest setValue:value forHTTPHeaderField:key];
                }
                [newRequest setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                return newRequest;
            }
            return request;
        }];
    }
  
    return self;

}


-(void)setProgress:(float)progress
{
    if(self.params && self.params->upLoadProcess_)
    {
        [self.params->upLoadProcess_ setProcessWithFloat:progress];
        if(progress == 1) self.params->upLoadProcess_ = nil;
    }
}


- (void)requestDidFail:(AFHTTPRequestOperation *)operation withError:(NSError *)error
{
    NSDate* dat2 = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *d = [cal components:unitFlags fromDate:dat1 toDate:dat2 options:0];
    long sec = [d hour]*3600+[d minute]*60+[d second];
    NSString *time = [NSString stringWithFormat:@"%ld秒",sec];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         time,@"处理时间:",nil];
    
    @try {
        NSLog(@"Error: %@",[error localizedDescription]);
        NSData *data = [operation responseData];
        [dic setObject:[error localizedDescription] forKey:@"error description"];
        if(data){
            if(operation.response.statusCode == 500){
                @try {
                    NSString* returnData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"Response data: %@",returnData);
                    [dic setObject:returnData forKey:@"returnData"];
                    FQJSONObject* json = [[FQJSONObject alloc] initWithNSString:returnData];
                    id<ComFqLibCallbackICallback> callback = [[ComFqHttpPotocolHttpClientPotocol getInstance] getOnSessionExpiredCallback];
                    if(callback){
                        [callback doCallbackWithId:json];
                    }
                    return;
                }
                @catch (NSException *exception) {
                    
                }
                @finally {
                    
                }

            }
        }
        if([self.handle  respondsToSelector:@selector(handleErrorWithInt:withJavaLangThrowable:)])
        {
            [self.handle handleErrorWithInt:CONNECT_ERRO_CODE withJavaLangThrowable:[[JavaLangThrowable alloc] initWithNSString:[error description]]];
        }
        [ComFqHttpAsyncHttpClient_IOS removHandle:self];
    }
    @catch (NSException *exception) {
         NSLog(@"%@",[exception reason]);
    }
    @finally {
        
    }
    [TalkingData trackEvent:@"接口响应时间" label:eventSuc parameters:dic];
   
}

- (void)requestDidFinish:(AFHTTPRequestOperation *)operation withData:(NSData*) data
{
    NSDate* dat2 = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *d = [cal components:unitFlags fromDate:dat1 toDate:dat2 options:0];
    long sec = [d hour]*3600+[d minute]*60+[d second];
    NSString *time = [NSString stringWithFormat:@"%ld秒",sec];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         time,@"处理时间:",nil];
    [TalkingData trackEvent:@"接口响应时间" label:eventSuc parameters:dic];
    NSData* _data = data;
    NSDictionary* allHeader =  operation.response.allHeaderFields;
    NSString* token = [allHeader objectForKey:@"accessToken"];
    if(token){
        [FQSecuritySession_IOS setAccessToken:token];
    }
    NSString* returnData = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
#ifdef DEBUG
     NSLog(@"JSON: %@",returnData);
#endif
    @try {
        FQJSONObject* json = [[FQJSONObject alloc] initWithNSString:returnData];
        int responseCode = [json optIntWithNSString:@"response_code"];
        if(responseCode == 20001 || responseCode == 20002){
            id<ComFqLibCallbackICallback> callback = [[ComFqHttpPotocolHttpClientPotocol getInstance] getOnSessionExpiredCallback];
            if(callback){
                [callback doCallbackWithId:json];
            }
            return;
        }
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }

    
    @try {
        if (self.handle && [self.handle respondsToSelector:@selector(handleResponseWithByteArray:)]) {
            [(FQBinaryResponseHandle*)self.handle handleResponseWithByteArray:[IOSByteArray arrayWithBytes:[_data bytes] count:[_data length]]];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception reason]);
        if([self.handle  respondsToSelector:@selector(onErrorWithInt:withJavaLangThrowable:)])
        {
//            [self.handle onErrorWithInt:CONNECT_ERRO_CODE withJavaLangThrowable:[[JavaLangThrowable alloc] initWithNSString:[exception description]]];
        }
        
    }
    @finally {
        [ComFqHttpAsyncHttpClient_IOS removHandle:self];
    }
    
}


@end
