//
//  TextViewController.h
//  DoctorPlus_ios
//
//  Created by reason on 15-7-19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoctorPlus_ios-Swift.h"

@interface TextViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MGSwipeTableCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

//@property (weak, nonatomic) IBOutlet UIView *containerView;
@end
