//
//  WorkoutPageContainerViewController.h
//  F.I.T.
//
//  Created by Felix Belau on 24.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIT-Swift.h"
#import "WorkoutExecutionRootViewController.h"

@interface WorkoutPageContainerViewController : UIViewController <UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) Training *workout;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic, weak) WorkoutExecutionRootViewController *sideMenuRootViewController;

- (void)jumpToExerciseAtIndex:(NSInteger)index;
- (NSInteger)currentExerciseIndex;

@end
