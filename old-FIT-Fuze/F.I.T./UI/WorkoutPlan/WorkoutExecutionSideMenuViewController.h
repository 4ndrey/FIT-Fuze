//
//  WorkoutExecutionSideMenuViewController.h
//  F.I.T.
//
//  Created by Felix Belau on 13.07.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIT-Swift.h"
#import "WorkoutExecutionRootViewController.h"

@interface WorkoutExecutionSideMenuViewController : UIViewController

@property (nonatomic, strong) Training *workout;
@property (nonatomic, weak) WorkoutExecutionRootViewController *sideMenuRootViewController;

- (void)forceRefresh;

@end
