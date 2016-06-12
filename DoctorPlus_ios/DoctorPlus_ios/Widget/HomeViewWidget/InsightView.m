//
//  InsightView.m
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/7/22.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "InsightView.h"
#import "Tools.h"
#import "Java/util/Iterator.h"

@interface InsightWebViewDelegateHandle : NSObject <UIWebViewDelegate>

@end

@interface InsightView ()
{
    InsightWebViewDelegateHandle* delegateHandle;
}
@end

@implementation InsightView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        delegateHandle = [[InsightWebViewDelegateHandle alloc] init];
        NSString* resourcePath = [NSBundle mainBundle].resourcePath;
        NSString* htmlFilePath = [resourcePath stringByAppendingPathComponent:@"insight.html"];
        NSString* htmlString = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
        [self loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@",[NSBundle mainBundle].bundlePath]]];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setScalesPageToFit:YES];
        self.scrollView.scrollEnabled = NO;
        self.delegate = delegateHandle;
        self.hidden = YES;
        self.opaque = NO;
    }
    return self;
}

-(void)setData:(NSString *)json
{
    [Tools Post:^{
        [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setData(%@)",json]];
    } Delay:.5f];
    
}

-(void)setDelegate:(id<UIWebViewDelegate>)delegate
{
    if([delegate isKindOfClass:[InsightWebViewDelegateHandle class]]){
        [super setDelegate:delegate];
    }
}

@end


@implementation InsightWebViewDelegateHandle


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if([webView isKindOfClass:[InsightView class]]){
        InsightView* insightView = (InsightView*)webView;
        NSString *requestString = [[request URL] absoluteString];
        if([requestString indexOfString:@"onlegendselected"]>0){
            NSString* params = [requestString substring:[requestString indexOfString:@"onlegendselected"]+[@"onlegendselected" length] endIndex:[requestString length]];
            NSString* decode = [params stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            FQJSONObject* json = [[FQJSONObject alloc] initWithNSString:decode];
            if(insightView.insightViewDelegate)[insightView.insightViewDelegate onLegendChanged:json];
            return NO;
        }
        if([requestString indexOfString:@"diagnosis"]>0){
            NSString* params = [requestString substring:[requestString indexOfString:@"diagnosis"]+[@"diagnosis" length] endIndex:[requestString length]];
            NSString* decode = [params stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            FQJSONArray* json = [[FQJSONArray alloc] initWithNSString:decode];
            if(insightView.insightViewDelegate)[insightView.insightViewDelegate onDataRealy:json];
            return NO;
        }
//        NSArray *components = [requestString componentsSeparatedByString:@"//"];
//        if (components != nil && [components count] > 0) {
//            NSString *pocotol = [components objectAtIndex:0];
//            if ([pocotol isEqualToString:@"onlegendselected"]) {
//                NSString *arg = [[components objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                FQJSONArray* jsonArray = [[FQJSONArray alloc] initWithNSString:arg];
//                NSMutableArray* array = [[NSMutableArray alloc] init];
//                for (int i = 0 ; i < [jsonArray length]; i++) {
//                    BOOL value = [jsonArray optBooleanWithInt:i];
//                    [array addObject:[NSNumber numberWithBool:value]];
//                }
//                if(insightView.insightViewDelegate)[insightView.insightViewDelegate onLegendChanged:array];
//                return NO;
//            }
//        }
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    webView.hidden = NO;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@",error);
    webView.hidden = NO;
    
}

@end