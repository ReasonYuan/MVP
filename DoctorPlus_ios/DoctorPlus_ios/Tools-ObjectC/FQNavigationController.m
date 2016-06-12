//
//  FQNavigationController.m
//  FangTai
//
//  Created by liaomin on 14-8-17.
//  Copyright (c) 2014年 FQ. All rights reserved.
//

#import "FQNavigationController.h"
#import "DoctorPlus_ios-Swift.h"

@interface FQNavigationController ()
{
    DataVisualizationViewController* vodeoNav;
}
@end

@implementation FQNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    if([viewController isKindOfClass:[DataVisualizationViewController class]])
//    {
//        vodeoNav= nil;
//        vodeoNav = [[DataVisualizationViewController alloc] init];
//        vodeoNav.navigationBarHidden = YES;
//        [vodeoNav pushViewController:viewController animated:YES];
//        [self.topViewController presentViewController:vodeoNav animated:NO completion:nil];
//    }
//    else
//    {
        [super pushViewController:viewController animated:animated];
//    }
}


- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    vodeoNav= nil;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
