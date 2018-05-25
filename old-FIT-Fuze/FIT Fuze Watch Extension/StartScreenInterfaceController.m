//
//  InterfaceController.m
//  FIT Fuze WatchKit Extension
//
//  Created by IVAN CHERNOV on 06/04/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//


#import "StartScreenInterfaceController.h"
#import "WorkoutSelectorRowType.h"
#import "StartButtonRowType.h"
#import "ResultsRecorder.h"
#import "ConnectivityManager.h"
#import "ProgressWatchdog.h"

@interface StartScreenInterfaceController()

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *goToPhone;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *loadingLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *loadingGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *goToIconLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceTable *moreWorkoutsTable;
@property (strong, nonatomic) NSMutableArray *nonTodayWorkouts;
@property (strong, nonatomic) ConnectivityManager *connectivityManager;
@property (strong, nonatomic) ProgressWatchdog *watchDog;
@property (assign, nonatomic) BOOL refreshNeeded;
@property (assign, nonatomic) BOOL isRegisteredAsObserver;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *retryButton;
@property (strong, nonatomic) NSArray *alreadyShownWorkouts;

@end

@interface WorkoutSelectionRowType : NSObject

@property (weak, nonatomic) IBOutlet WKInterfaceLabel* workoutName;
@property (weak, nonatomic) IBOutlet WKInterfaceButton* workoutSelectionButton;

@end

@implementation StartScreenInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    BOOL isHealthAllowed = [[NSUserDefaults standardUserDefaults] boolForKey:@"heartRateAllowed"];
    if (isHealthAllowed == NO) {
        [self pushControllerWithName:@"requestHealthDataSceneID" context:nil];
    }
    
    [self performInitialSetup];

    if(self.connectivityManager.trainingPlanDictionary != nil) {
        [self processTrainingPlan];
    } else {
        self.refreshNeeded = YES;
        [self showLoadingMessage];
        
        BOOL isPossibleToGetData = [self.connectivityManager tryToGetInfoFromPhoneForced: NO];
        if(!isPossibleToGetData) {
            [self hideLoadingMessage];
            [self showModalGoToPhoneMessage];
        }
    }
    
    self.connectivityManager.ignoreUpdates = YES;
    [self.watchDog reset];
    self.connectivityManager.ignoreUpdates = NO;
}

- (void)performInitialSetup {
    self.connectivityManager = [ConnectivityManager sharedManager];
    self.watchDog = [ProgressWatchdog sharedWatchdog];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@0 forKey:@"currentExerciseIndex"];
    [defaults synchronize];
    
    [self.goToIconLabel setText:NSLocalizedString(@"startingHint_label", nil)];
    [self.loadingLabel setText:NSLocalizedString(@"loading_label", nil)];
    [self.retryButton setTitle:NSLocalizedString(@"retryButton_label", nil)];
}

-(void)showModalGoToPhoneMessage {
    [self presentControllerWithName:@"ConnectionNotificationHint" context:nil];
}

-(void)showGoToPhoneMessage {
    [self.goToPhone setHidden:NO];
}

-(void)hideGoToPhoneMessage {
    [self.goToPhone setHidden:YES];
}

-(void)showLoadingMessage {
    [self.loadingGroup setHidden:NO];
}

-(void)hideLoadingMessage {
    [self.loadingGroup setHidden:YES];
}

-(void)observeValueForKeyPath:(NSString*)keyPath
                     ofObject:(id)object
                       change:(NSDictionary*)change
                      context:(void*)context {
    if ([keyPath isEqual:@"trainingPlanDictionary"]) {
        if(self.refreshNeeded) {
            self.refreshNeeded = NO;
        }
        if(self.connectivityManager.trainingPlanDictionary != nil) {
            [self hideGoToPhoneMessage];
            [self processTrainingPlan];
        } else {
            [self hideLoadingMessage];
            [self showGoToPhoneMessage];
        }
    }
}

- (IBAction)reloadData {
    self.refreshNeeded = YES;
    [self.connectivityManager tryToGetInfoFromPhoneForced: YES];
    
    [self.retryButton setEnabled:NO];
    [self.retryButton setTitle:NSLocalizedString(@"retryButtonInProgress_label", nil)];
}

- (void)processTrainingPlan {
    NSDictionary *trainingPlanInfo = self.connectivityManager.trainingPlanDictionary;
    NSNumber *currentWorkoutIndex = [trainingPlanInfo objectForKey:@"currentWorkoutIndex"];
    NSArray *workoutsArray = [trainingPlanInfo objectForKey:@"workouts"];
    
    [self.retryButton setEnabled:YES];
    [self.retryButton setTitle:NSLocalizedString(@"retryButton_label", nil)];
    
    if(self.alreadyShownWorkouts != nil && workoutsArray == self.alreadyShownWorkouts) {
        return;
    } else {
        self.alreadyShownWorkouts = workoutsArray;
    }
    
    NSDictionary *workoutDict = [workoutsArray objectAtIndex: [currentWorkoutIndex integerValue]];
    NSString *workoutName = workoutDict[@"workoutName"];
    
    if (workoutsArray.count > 0) {
        [self setTitle:NSLocalizedString(@"workouts_label", nil)];
        
        //separate today and non-today workouts
        self.nonTodayWorkouts = [NSMutableArray arrayWithArray:workoutsArray];
        [self.nonTodayWorkouts removeObjectAtIndex:[currentWorkoutIndex integerValue]];
        [self.goToPhone setHidden:YES];
        
        //fill table with rows of proper types
        NSMutableArray *arrayOfRowTypes = [[NSMutableArray alloc] init];
        [arrayOfRowTypes addObject:@"startWorkoutSelectorRowType"];
        for (int j = 0; j<self.nonTodayWorkouts.count; j++) {
            [arrayOfRowTypes addObject:@"workoutSelectorRowType"];
        }
        [self.moreWorkoutsTable setRowTypes:arrayOfRowTypes];
        
        //set labels for the rows
        StartButtonRowType* todayWorkoutRow = [self.moreWorkoutsTable rowControllerAtIndex:0];
        
        NSArray *workouts = [trainingPlanInfo objectForKey:@"workouts"];
        NSDictionary *currentWorkout = [workouts objectAtIndex:[currentWorkoutIndex integerValue]];
        NSNumber *doneNumber = [currentWorkout objectForKey:@"numberOfRepsDone"];
        NSNumber *ofNumber = [trainingPlanInfo objectForKey:@"numberOfWorkoutReps"];
        [todayWorkoutRow.startLabel setText:[NSString stringWithFormat:NSLocalizedString(@"start_workout_label", nil), workoutName]];
        [todayWorkoutRow.doneOfLabel setText:[NSString stringWithFormat:NSLocalizedString(@"doneOfLabel", nil), doneNumber, ofNumber]];
        
        NSString *nextWorkoutName;
        int i = 1;
        for (NSDictionary *nextWorkoutDictionary in self.nonTodayWorkouts) {
            WorkoutSelectorRowType* workoutRow = [self.moreWorkoutsTable rowControllerAtIndex:i];
            nextWorkoutName = nextWorkoutDictionary[@"workoutName"];
            doneNumber = nextWorkoutDictionary[@"numberOfRepsDone"];
            [workoutRow.workoutLabel setText:nextWorkoutName];
            [workoutRow.doneOfLabel setText:[NSString stringWithFormat:NSLocalizedString(@"doneOfLabel", nil), doneNumber, ofNumber]];
            i++;
        }
    }
    else
    {
        [self showGoToPhoneMessage];
    }
    
    [self.loadingGroup setHidden:YES];
    self.refreshNeeded = NO;
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    if (rowIndex == 0) {
        BOOL isInProgress = [[ProgressWatchdog sharedWatchdog] isInProgress];
        if(isInProgress) {
            [self presentControllerWithName:@"workoutIsInProgressID" context:nil];
            return;
        }
        
        [self pushControllerWithName:@"exerciseListSceneID" context:nil];
        return;
    }
    else
    {
        NSDictionary *workout = [self.nonTodayWorkouts objectAtIndex:rowIndex-1];
        [self.connectivityManager setCurrentWorkout:workout];
        [[ProgressWatchdog sharedWatchdog] reset];
        [self pushControllerWithName:@"exerciseListSceneID" context:nil];
        self.refreshNeeded = YES;
    }
}

- (IBAction)goToSettings:(id)sender
{
    [self pushControllerWithName:@"settingsSceneID" context:nil];
}

- (IBAction)finishWorkoutNow:(id)sender
{
    [[ProgressWatchdog sharedWatchdog] finishWorkout];
}

- (void)resetSavedLastFinishedExerciseDate {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastFinishedExerciseDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)forwardToExecutionIsNeeded {
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"ContinueWorkout"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ContinueWorkout"];
        return YES;
    }
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"ResetWorkout"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ResetWorkout"];
        [[ProgressWatchdog sharedWatchdog] reset];
        return YES;
    }
    
    return NO;
}

- (void)resetWorkoutExecutionState {
    [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"exerciseExecutionState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)willActivate {
    [super willActivate];
    [[ProgressWatchdog sharedWatchdog] endWorkoutSession];

    self.isRegisteredAsObserver = YES;
    [self.connectivityManager addObserver:self forKeyPath:@"trainingPlanDictionary" options:0 context:NULL];
    
    [self resetSavedLastFinishedExerciseDate];
    if([self forwardToExecutionIsNeeded] == YES) {
        [self pushControllerWithName:@"exerciseListSceneID" context:nil];
        return;
    }
    
    [self resetWorkoutExecutionState];

    [self.moreWorkoutsTable scrollToRowAtIndex:0];
    if (self.refreshNeeded) {
        [self.connectivityManager tryToGetInfoFromPhoneForced: NO];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    if(self.isRegisteredAsObserver) {
        [self.connectivityManager removeObserver:self forKeyPath:@"trainingPlanDictionary"];
    }
    [super didDeactivate];
}

@end
