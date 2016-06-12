//
//  InsightView.h
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/7/22.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONObject.h"
#import "JSONArray.h"

@protocol InsightViewDelegate <NSObject>

/**
 *顶上得LEGEND被选中时的回调 
 */
//-(void)onLegendChanged:(NSArray*)statues;
-(void)onLegendChanged:(FQJSONObject*)json;
-(void)onDataRealy:(FQJSONArray*)json;
@end

@interface InsightView : UIWebView

-(void)setData:(NSString*)json;

@property (nonatomic,weak) id<InsightViewDelegate> insightViewDelegate;

@end
