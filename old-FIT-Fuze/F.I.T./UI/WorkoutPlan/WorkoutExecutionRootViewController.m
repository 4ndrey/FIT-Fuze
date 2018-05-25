//
//  WorkoutExecutionRootViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 13.07.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "WorkoutExecutionRootViewController.h"
#import "WorkoutPageContainerViewController.h"
#import "WorkoutExecutionSideMenuViewController.h"
#import "WorkoutExecutionWatchdog.h"

@interface WorkoutExecutionRootViewController ()

@property (assign) BOOL menuPresented;

@end

@implementation WorkoutExecutionRootViewController

- (void)awakeFromNib
{
    self.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
    self.contentViewShadowColor = [UIColor blackColor];
    self.contentViewShadowOffset = CGSizeMake(0, 0);
    self.contentViewShadowOpacity = 0.6;
    self.contentViewShadowRadius = 12;
    self.contentViewShadowEnabled = YES;
    self.menuPresented = NO;
}

- (void)viewDidLoad
{
    self.title = self.workout.name;
    
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WorkoutPageContainerViewController"];
    self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WorkoutExecutionSideMenuViewController"];

    self.delegate = self;
    ((WorkoutExecutionSideMenuViewController *) self.leftMenuViewController).workout = self.workout;
    ((WorkoutExecutionSideMenuViewController *) self.leftMenuViewController).sideMenuRootViewController = self;
    ((WorkoutPageContainerViewController *) self.contentViewController).workout = self.workout;
    ((WorkoutPageContainerViewController *) self.contentViewController).sideMenuRootViewController = self;
    
    [super viewDidLoad];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)leftBarButtonPressed:(id)sender
{
    if (self.menuPresented) {
        [self hideMenuViewController];
    } else {
        [self presentLeftMenuViewController];
    }
}

- (void)finishWorkout
{
    [[WorkoutExecutionWatchdog sharedWatchdog] reset];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WorkoutTimersInvalidate" object:nil];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)jumpToExerciseAtIndex:(NSInteger)index
{
    [self hideMenuViewController];
    [((WorkoutPageContainerViewController *) self.contentViewController) jumpToExerciseAtIndex:index];
}

- (NSInteger)currentExerciseIndex {
    return [((WorkoutPageContainerViewController *) self.contentViewController) currentExerciseIndex];
}

#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    self.menuPresented = YES;
    [(WorkoutExecutionSideMenuViewController *)menuViewController forceRefresh];
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController
{
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    self.menuPresented = NO;
}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController
{
}

@end
