//
//  MainViewController.m
//  DoctorPlus_ios
//
//  Created by reason on 15-7-14.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "MainViewController.h"
#import "ScannerViewController.h"
#import "DoctorPlus_ios-Swift.h"
#import "TextViewController.h"
#import "PraHomeViewController.h"

static MessageInit *initMessage;
@interface MainViewController ()<UITabBarControllerDelegate>
{
//    BOOL isInScanner;
}
@end





@implementation MainViewController


-(void) setViewController:(UIViewController*)controller WithTabTitle:(NSString*)title imgName:(NSString*)imageName selectImgName:(NSString*)selectImgName
{
//    controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:0] ;
//    controller.tabBarItem.badgeValue = @"10";
    
    UITabBarItem *tabBarItem1 = controller.tabBarItem;//[self.tabBar.items objectAtIndex:0];
    UIImage* tabBarItem1Image = [UIImage imageNamed:imageName];
    UIImage *scaledTabBarItem1Image = [UIImage imageWithCGImage:[tabBarItem1Image CGImage] scale:(tabBarItem1Image.scale * 1.5) orientation:(tabBarItem1Image.imageOrientation)];
    
    UIImage* tabBarItem1SelectedImage = [UIImage imageNamed:selectImgName];
    UIImage *scaledTabBarItem1SelectedImage = [UIImage imageWithCGImage:[tabBarItem1SelectedImage CGImage] scale:(tabBarItem1SelectedImage.scale * 1.5) orientation:(tabBarItem1SelectedImage.imageOrientation)];
    
     if ([[UIDevice currentDevice]systemVersion].floatValue >=7) {
        scaledTabBarItem1Image = [scaledTabBarItem1Image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        scaledTabBarItem1SelectedImage = [scaledTabBarItem1SelectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
     }
    (void)[tabBarItem1 initWithTitle:title image:scaledTabBarItem1Image selectedImage:scaledTabBarItem1SelectedImage];
    tabBarItem1.titlePositionAdjustment = UIOffsetMake(0, -5);
    //每个子项的title位置偏移
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width*0.63, buttonImage.size.height*0.63);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
//    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
//    if (heightDifference < 0)
//        button.center = self.tabBar.center;
//    else
//    {
//        CGPoint center = self.tabBar.center;
//        center.y = center.y - heightDifference/2.0-0.5;//-15
//        button.center = center;
//    }
      button.center = self.tabBar.center;
    [button addTarget:self action:@selector(selectCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:button];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    [MessageTools createTestDB];
    [AttachmentTools createAttachmentDB];
     ChartHomeViewController* home = [[ChartHomeViewController alloc] initWithNibName:@"ChartHomeViewController" bundle:nil];
//    UIViewController* home = [[UIViewController alloc] init];
    
    [self setViewController:home WithTabTitle:@"主页" imgName:@"main_tab_home" selectImgName:@"main_tab_home_selected"];
    
    //TODO ==YY== MoreChatListViewController  TextViewController
    MoreChatListViewController* chat = [[MoreChatListViewController alloc] init];
    [self setViewController:chat WithTabTitle:@"聊天" imgName:@"main_tab_chat" selectImgName:@"main_tab_chat_selected"];
    
    ScannerViewController* controll = [[ScannerViewController alloc] init];
    controll.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:0] ;
    
    ContactsViewController* contacts = [[ContactsViewController alloc] init];
    [self setViewController:contacts WithTabTitle:@"我的医生" imgName:@"main_tab_account" selectImgName:@"main_tab_account_selected"];
    
    UIViewController* me = nil;
    if ([MessageTools isExperienceMode]) {
        me = [[VisitorMeViewController alloc] init];
    }else{
        me = [[MeViewController alloc] init];
    }
    
    [self setViewController:me WithTabTitle:@"我" imgName:@"main_tab_me" selectImgName:@"main_tab_me_selected"];
    
    self.viewControllers = [NSArray arrayWithObjects:home,chat,controll,contacts,me, nil];
    
    
    [self addCenterButtonWithImage:[UIImage imageNamed:@"main_tab_camera"] highlightImage:[UIImage imageNamed:@"main_tab_camera_selected"]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendAddFriendMessage:) name:@"sendAddFriendMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendUnReadMessageCount:) name:@"sendUnReadMessageCount" object:nil];
    
    
    
    /**初始化IMSDK**/
    initMessage = [[MessageInit alloc] init];
    [initMessage testIMSDK];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
//    self.tabBar.tintColor = [UIColor colorWithRed:43.0/255.0 green:42/255.0 blue:117/255.0 alpha:1.0];
    self.tabBar.tintColor = [UIColor whiteColor];
    UIColor *tabbarColor = [UITools colorWithHexString:@"1e1e28" alpha:1.0];
    UIImage *tabBarImage = [UITools imageWithColor:tabbarColor];
    self.tabBar.backgroundImage = tabBarImage;
}

/**通知tabbar改变加好友未处理数**/
-(void)sendAddFriendMessage:(NSNotification*)nofication
{
    int count = 0;
    NSDictionary *dictionaray  = nofication.userInfo;
    NSString *Str = (NSString*)[dictionaray objectForKey:@"sendAddFriendMessage"];
    count = [Str intValue];
    [self setMsgNunber:count ByIndex:3];
}

/**通知tabbar改变消息未处理数**/
-(void)sendUnReadMessageCount:(NSNotification*)nofication
{
    int count = 0;
    NSDictionary *dictionaray  = nofication.userInfo;
    NSString *Str = (NSString*)[dictionaray objectForKey:@"sendUnReadMessageCount"];
    count = [Str intValue];
    [self setMsgNunber:count ByIndex:1];
}



-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.selectedViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.tabBar.frame.size.height);
}


-(void)setMsgNunber:(int)number ByIndex:(int)index{
    UITabBarItem *tabBarItem = [self.tabBar.items objectAtIndex:index];
    if (number > 99){
        tabBarItem.badgeValue = @"99+";
    }else{
        if (number == 0 || number < 0){
            tabBarItem.badgeValue = nil;
        }else{
            tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",number];
        }
        
    }
}


-(void)selectCamera:(id)sender{
//    isInScanner = YES;
    [self.navigationController pushViewController:[[ScannerViewController alloc] init] animated:YES];
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    viewController.view.frame = CGRectMake(0, 0, tabBarController.view.frame.size.width, tabBarController.view.frame.size.height - 44);
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if([viewController isKindOfClass:[ScannerViewController class]]){
//        isInScanner = YES;
        [tabBarController.navigationController pushViewController:[[ScannerViewController alloc] init] animated:YES];
        return NO;
    }else if([viewController isKindOfClass:[MoreChatListViewController class]] || [viewController isKindOfClass:[ContactsViewController class]]){
        if ([MessageTools isExperienceMode : tabBarController.navigationController]) {
            return NO;
        }
    }
    if ([MessageTools isExperienceMode]){
        if([viewController isKindOfClass:[ContactsViewController class]] ||  [viewController isKindOfClass:[MoreChatListViewController class]]) {
            [MessageTools isExperienceMode:self.navigationController];
            return NO;
        }
    }
    return YES;
}

@end
