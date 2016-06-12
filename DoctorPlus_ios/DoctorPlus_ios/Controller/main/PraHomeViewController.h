//
//  PraHomeViewController.h
//  DoctorPlus_ios
//
//  Created by reason on 15-7-16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartView.h"

@interface PraHomeViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIButton *btnChartAll;
@property (weak, nonatomic) IBOutlet UIButton *btnChartDay;
@property (weak, nonatomic) IBOutlet UIButton *btnChartIn;

@property (weak, nonatomic) IBOutlet UILabel *lableNoneTip;

@property (weak, nonatomic) IBOutlet ChartView *chartViewContainer;

@property (weak, nonatomic) IBOutlet UILabel *labelPatientCount;

@property (weak, nonatomic) IBOutlet UILabel *labelRecordCount;

@property (weak, nonatomic) IBOutlet UIView *patientListContainer;


@property (weak, nonatomic) IBOutlet UILabel *environmentLabel;


-(void)showToast:(NSString*)msg;



@end
