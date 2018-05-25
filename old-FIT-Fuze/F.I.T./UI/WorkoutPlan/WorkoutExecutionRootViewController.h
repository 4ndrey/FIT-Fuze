//
//  WorkoutExecutionRootViewController.h
//  F.I.T.
//
//  Created by Felix Belau on 13.07.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "RESideMenu.h"
#import "FIT-Swift.h"

@interface WorkoutExecutionRootViewController : RESideMenu <RESideMenuDelegate>

@property (nonatomic, strong) Training *workout;

- (void)finishWorkout;
- (void)jumpToExerciseAtIndex:(NSInteger)index;
- (NSInteger)currentExerciseIndex;

@end
