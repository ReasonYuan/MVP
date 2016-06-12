//
//  ContactTagsListViewController.h
//  DoctorPlus_ios
//
//  Created by niko on 15/6/1.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "HeadView.h"
#import "Constants.h"
#import "Contacts.h"
#include "java/util/HashMap.h"
#include "java/util/ArrayList.h"
#include "Photo.h"
//#import "CustomIOS7AlertView.h"
#import "DoctorPlus_ios-Swift.h"
#import "Tag.h"
#import "TagLogic.h"

@interface ContactTagsListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,HeadViewDelegate, ComFqHalcyonLogic2TagLogic_RequestTagInfCallBack>{
    UITableView* _tableView;
    NSInteger _currentSection;
    NSInteger _currentRow;
}
@property(nonatomic, retain) NSMutableArray* headViewArray;
@property(nonatomic, retain) UITableView* tableView;
@property(nonatomic,retain) JavaUtilArrayList* tagsNameArray;
@property(nonatomic,retain) CustomIOS7AlertView* dialog;
@property(nonatomic,retain) ComFqHalcyonEntityTag* tags;
@property(nonatomic,retain) UILabel* label;
@property(nonatomic,retain) CustomIOS7AlertView* loadingDialog;
@end
