//
//  FirstViewController.h
//  Test04
//
//  Created by HuHongbing on 9/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeadView.h"
#import "Constants.h"
#import "Contacts.h"
#include "java/util/HashMap.h"
#include "java/util/ArrayList.h"
#include "Photo.h"


@interface FirstViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,HeadViewDelegate>{
    UITableView* _tableView;
    NSInteger _currentSection;
    NSInteger _currentRow;
    
}
@property(nonatomic, retain) NSMutableArray* headViewArray;
@property(nonatomic, retain) NSMutableArray* titleNameArray;
@property(nonatomic,retain) NSMutableDictionary* departmentDic;
@property(nonatomic, retain) UITableView* tableView;
@property(nonatomic,retain) NSArray* departmentNameArray;
@end
