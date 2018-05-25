//
//  MenuRootViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 17.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "MenuRootViewController.h"
#import "MainMenuViewController.h"

@interface MenuRootViewController ()

@end

@implementation MenuRootViewController

- (void)awakeFromNib
{
    self.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
    self.contentViewShadowColor = [UIColor blackColor];
    self.contentViewShadowOffset = CGSizeMake(0, 0);
    self.contentViewShadowOpacity = 0.6;
    self.contentViewShadowRadius = 12;
    self.contentViewShadowEnabled = YES;
    
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"trainingPlanNavController"];
    self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"leftMenuViewController"];
    
    self.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    if ([menuViewController isKindOfClass:[MainMenuViewController class]])
    {
        [(MainMenuViewController *)menuViewController updateUserInterface];
    }
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController
{
    //    NSLog(@"didShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    //    NSLog(@"willHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController
{
    //    NSLog(@"didHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

@end
