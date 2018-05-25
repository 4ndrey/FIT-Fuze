//
//  WorkoutPageViewControllerDelegate.h
//  F.I.T.
//
//  Created by Felix Belau on 01.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FIT-Swift.h"

@class WorkoutViewController;
static NSString *weightKey = @"weight";
static NSString *repetitionsKey = @"repetitions";
static NSString *exerciseKey = @"exercise";

@protocol WorkoutPageViewControllerDelegate <NSObject>

- (void)goToNextExercise;
- (UINavigationController *)navigationController;
- (void)showTutorialCoachMarks;
- (void)disableScrolling;
- (void)enableScrolling;

@end
