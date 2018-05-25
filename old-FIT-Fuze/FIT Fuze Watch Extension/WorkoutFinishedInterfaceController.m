//
//  WorkoutFinishedInterfaceController.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 01/05/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "WorkoutFinishedInterfaceController.h"
#import "ConnectivityManager.h"
#import "ProgressWatchdog.h"

@interface WorkoutFinishedInterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *workoutFinishedLabel;

@end


@implementation WorkoutFinishedInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    [sharedDefaults setValue:@YES forKey:@"isWorkoutFinishDetected"];
    [sharedDefaults synchronize];
    [self.workoutFinishedLabel setText: NSLocalizedString(@"workoutFinishedLabel", nil)];
    // Configure interface objects here.
}

- (IBAction)finishWorkout {
    [[ConnectivityManager sharedManager] finishWorkout];
    [ConnectivityManager sharedManager].ignoreUpdates = YES;
    [[ProgressWatchdog sharedWatchdog] finishWorkout];
    [[ProgressWatchdog sharedWatchdog] reset];
    [ConnectivityManager sharedManager].ignoreUpdates = NO;
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    [sharedDefaults setValue:@NO forKey:@"isWorkoutFinishDetected"];
    [WKInterfaceController reloadRootControllersWithNames:@[@"startSceneID"] contexts:nil];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



