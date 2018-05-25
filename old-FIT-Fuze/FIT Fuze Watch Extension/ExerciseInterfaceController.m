//
//  ExerciseInterfaceController.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 07/04/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "ExerciseInterfaceController.h"
#import "ResultsRecorder.h"
#import <HealthKit/HealthKit.h>
#import "ProgressWatchdog.h"
#import "ConnectivityManager.h"
#import "ExerciseExecutionRowType.h"
#import "StatusRowType.h"

@import UIKit;

@interface ExerciseInterfaceController()
{
    NSTimer *_timer;
    NSDate *startTime;
    NSDate *lastHeartRateCheck;
    NSTimer *workoutTimer;
}

@property (strong, nonatomic) ConnectivityManager *connectivityManager;
@property (strong, nonatomic) ProgressWatchdog *progressWatchdog;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *alreadyDoneLabel;
//
@property (strong, nonatomic) NSArray *exerciseNames;
@property (strong, nonatomic) NSDictionary *exerciseWeightsDictionary; //name - array of weights
@property (strong, nonatomic) NSDictionary *exerciseRepsDictionary; //name - array of reps

@property (strong, nonatomic) IBOutlet WKInterfaceGroup *notDoneSetGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *alreadyDoneSetGroup;

@property (strong, nonatomic) IBOutlet WKInterfaceTable *exerciseDescriptionsTable;

@property (strong, nonatomic) NSString *kgOrLbs;
@property (nonatomic, assign) long lastHR;

@property (nonatomic, assign) int currentExerciseObjectIndex; //index of current superset
@property (assign, nonatomic) int currentExerciseIndex; //index of current exercise within the superset
@property (nonatomic, assign) int currentSetIndex; //index of current set

@property (strong, nonatomic) NSString *currentFailureExerciseName;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *currentSetExecutionGroup;

@property (strong, nonatomic) IBOutlet WKInterfaceButton *editSetButton;

@property (nonatomic, assign) BOOL dataFilled;
@property (nonatomic, assign) BOOL newSetStartNeeded;

@property (assign, nonatomic) BOOL hrStarted;
@property (assign, nonatomic) BOOL hrFound;
//
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *setInProgressButtonsGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *startSetButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *finishButton;
//
@property (strong, nonatomic) IBOutlet WKInterfacePicker *repsDonePicker;
@property (strong, nonatomic) IBOutlet WKInterfacePicker *weightDonePicker;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *saveFailedDataButton;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *exerciseNameFailLabel;

@property (strong, nonatomic) IBOutlet WKInterfaceButton *skipButton;//new
@property (strong, nonatomic) NSTimer *restTimeTimer;
@property (strong, nonatomic) NSNumber *providedExerciseObjectNumber;

@property (assign, nonatomic) int currentSetRepetitionsDone;
@property (assign, nonatomic) int currentSetWeightUsed;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *rowStatsTimerGroup;

@end


@implementation ExerciseInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.providedExerciseObjectNumber = [context objectForKey:@"exerciseObjectIndex"];
    self.connectivityManager = [ConnectivityManager sharedManager];
    self.progressWatchdog = [ProgressWatchdog sharedWatchdog];
    
    self.dataFilled = NO;
    self.newSetStartNeeded = NO;
    
    [self setupHeartRateCell];
    [self setLocalLabels];
    [self getInfoForced:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:@"FITResultsReceivedNotification" object:nil];
}

- (void)reload {
    [self.progressWatchdog refreshNextToDos];
    
    [self.finishButton setEnabled: NO];
    [self.currentSetExecutionGroup setHidden:YES];
    
    StatusRowType *rowWithStats = [self.exerciseDescriptionsTable rowControllerAtIndex:0];
    [rowWithStats.setTimer stop];
    [rowWithStats.setTimer setHidden:YES];

    [self.startSetButton setHidden:NO];
    
    [self getInfoForced:NO];
}

- (NSInteger)currentExerciseObjectIndex {
    return [self.progressWatchdog.activeExerciseObjectIndex integerValue];
}

- (void)setupHeartRateCell {
    [self.exerciseDescriptionsTable setRowTypes:@[@"statisticsRowType"]];
    StatusRowType *rowWithStats = [self.exerciseDescriptionsTable rowControllerAtIndex:0];
    [rowWithStats.setXofYLabel setText: @""];
}

- (void)setLocalLabels
{
    [self.startSetButton setTitle:NSLocalizedString(@"start_set_label", nil)];
    [self.skipButton setTitle:NSLocalizedString(@"skipButton_title", nil)];
    [self.finishButton setTitle:NSLocalizedString(@"finishSetResultsButton_title", nil)];
    [self.editSetButton setTitle:NSLocalizedString(@"editSetResultsButton_title", nil)];
    [self.saveFailedDataButton setTitle:NSLocalizedString(@"saveFailedDataButton", nil)];
    [self.alreadyDoneLabel setText:NSLocalizedString(@"alreadyDoneLabel", nil)];
    
    NSDictionary *trainingPlanInfo = self.connectivityManager.trainingPlanDictionary;
    self.kgOrLbs = [[trainingPlanInfo objectForKey:@"kilogrammChoosenKey"] boolValue] ? NSLocalizedString(@"kg", nil) : NSLocalizedString(@"lbs", nil);
}

- (void)getInfoForced:(BOOL)forceReload
{
    if([self.progressWatchdog.activeExerciseObjectIndex integerValue] == -1) {
        [self presentControllerWithName:@"workoutFinishedSceneID" context:nil];
        return;
    }
    
    BOOL needToBeUpdated = [self.progressWatchdog refreshNextToDos];
    if (!needToBeUpdated && !forceReload) {
        return;
    }
    
    NSDictionary *exerciseObject;
    if(self.providedExerciseObjectNumber) {
        exerciseObject = [self.progressWatchdog getExerciseObjectWithIndex:self.providedExerciseObjectNumber];
        self.providedExerciseObjectNumber = nil;
    } else {
        exerciseObject = self.progressWatchdog.nextToDoExerciseObject;
    }

    self.exerciseNames = exerciseObject[@"exerciseNamesSet"];
    self.exerciseWeightsDictionary = exerciseObject[@"setWeightsDictionary"];// z.B. ["Bench Press":[75, 75, 80], "Biceps Curls":[16, 16, 16]]
    self.exerciseRepsDictionary = exerciseObject[@"setRepetitionsDictionary"];// z.B. ["Bench Press":[8, 8, 8], "Biceps Curls":[12, 10, 8]]

    self.currentSetIndex = [self.progressWatchdog.nextToDoExerciseSet intValue];
    self.dataFilled = YES;
    [self setUIForCurrentSet];
}

- (IBAction)skipButtonPressed {
    for(NSString *exerciseName in self.exerciseNames) {
        [self.progressWatchdog setStatus:ExerciseExecutionStatusSkipped forExerciseWithName:exerciseName];
    }
    [self.progressWatchdog refreshNextToDos];
    [self getInfoForced:YES];
}

- (void)setUIForCurrentSet
{
    NSString *referenceCurrentExercise = self.exerciseNames[0];
    NSArray *weights = self.exerciseWeightsDictionary[referenceCurrentExercise];

    if (weights.count == 0) {
        [self presentControllerWithName:@"noSetsFilledID" context:nil];
        return;
    }
    
    int nextSet = [self.progressWatchdog nextSetForExercise:referenceCurrentExercise];
    self.currentSetIndex = nextSet;

    if(nextSet == -1) {
        self.alreadyDoneSetGroup.hidden = NO;
        self.notDoneSetGroup.hidden = YES;
        self.currentSetIndex = 0;
        
        [self.restTimeTimer invalidate];
        self.restTimeTimer = nil;
        
    } else {
        self.alreadyDoneSetGroup.hidden = YES;
        self.notDoneSetGroup.hidden = NO;
    }
    
    if (!self.dataFilled) {
        [self.startSetButton setTitle:NSLocalizedString(@"start_set_label", nil)];
        [self getInfoForced:YES];
    } else {        
        NSMutableArray *rows = [NSMutableArray new];
        [rows addObject:@"statisticsRowType"];
        for(int i = 0; i<self.exerciseNames.count; i++) {
            [rows addObject:self.exerciseNames.count > 1 ? @"exerciseExecutionRowType" : @"exerciseExecutionExtendedRowType"];
        }
        
        [self.exerciseDescriptionsTable setRowTypes:rows];
        
        StatusRowType *rowWithStats = [self.exerciseDescriptionsTable rowControllerAtIndex:0];
        //[rowWithStats.statisticGroup setBackgroundColor:[UIColor clearColor]];
        NSArray *setWeights = self.exerciseWeightsDictionary[self.exerciseNames[0]];
        NSString * currentSetLabelTitle = [NSString stringWithFormat:@"%d/%d" , self.currentSetIndex+1, setWeights.count];
        [rowWithStats.setXofYLabel setText:currentSetLabelTitle];
        
        NSNumber *state = [[NSUserDefaults standardUserDefaults] objectForKey:@"exerciseExecutionState"];
        
        if(state) {
            switch (state.integerValue) {
                case 0:
                {
                    [self.skipButton setHidden:NO];
                    [self.startSetButton setHidden:NO];
                    [rowWithStats.setTimer setHidden:YES];
                    [self.currentSetExecutionGroup setHidden:YES];
                }
                    break;
                    
                case 1:
                {
                    [self.skipButton setHidden:YES];
                    [self.startSetButton setHidden:YES];
                    [rowWithStats.setTimer setHidden:NO];
                    [self.currentSetExecutionGroup setHidden:NO];
                    [self startSetAction];
                }
                    break;
                    
                case 2:
                {
                    [self.skipButton setHidden:YES];
                    NSDictionary *trainingPlanInfo = self.connectivityManager.trainingPlanDictionary;
                    NSNumber *restTime = [trainingPlanInfo objectForKey:@"restTimeKey"];
                    
                    NSDate *sinceDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastFinishedExerciseDate"];
                    if([sinceDate timeIntervalSinceNow] > (-restTime.integerValue)) {
                        [rowWithStats.setTimer setDate:[NSDate dateWithTimeInterval:[restTime integerValue] sinceDate:sinceDate]];
                        [rowWithStats.setTimer start];
                        [rowWithStats.timerGroup setBackgroundColor:[UIColor colorWithRed:110.0/255.0 green:173.0/255.0 blue:1.0 alpha:1.0]];
                    } else {
                        [self startSetAction];
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
        
        if(self.hrFound) {
            [rowWithStats.heart_rate_icon stopAnimating];
            NSMutableArray *images = [[NSMutableArray alloc] init];
            /*for(int i = 1; i <= 14; i++) {
                UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"heart_%d", i]];
                [images addObject:img];
            }
            */
            /*[rowWithStats.heart_rate_icon setImage:[UIImage animatedImageWithImages:images duration:1.9]];
            [rowWithStats.heart_rate_icon startAnimating];*/
            
            [rowWithStats.heart_rate_icon setImageNamed:@"heart"];
            [rowWithStats.heart_rate_icon startAnimatingWithImagesInRange:NSMakeRange(0, 13) duration:2 repeatCount:0];
            
            if(self.lastHR > 0) {
                [rowWithStats.heartRateLabel setText:[NSString stringWithFormat:@"%ld",(long)self.lastHR]];
            }
            
        } else {
            [rowWithStats.heart_rate_icon stopAnimating];
            NSMutableArray *images = [[NSMutableArray alloc] init];
            /*for(int i = 1; i <= 9; i++) {
                UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"heart_red %d", i]];
                [images addObject:img];
            }*/
            
            /*[rowWithStats.heart_rate_icon setImage:[UIImage animatedImageWithImages:images duration:1.9]];
            [rowWithStats.heart_rate_icon startAnimating];*/
            
            [rowWithStats.heart_rate_icon setImageNamed:@"heart_red"];
            [rowWithStats.heart_rate_icon startAnimatingWithImagesInRange:NSMakeRange(0,8) duration:2 repeatCount:0];
            
            if(self.lastHR > 0) {
                [rowWithStats.heartRateLabel setText:[NSString stringWithFormat:@"%ld",(long)self.lastHR]];
            }
        }
        
        
        int i = 1;
        for (NSString *exerciseName in self.exerciseNames) {
            NSArray *setWeights = self.exerciseWeightsDictionary[exerciseName];
            NSArray *setReps = self.exerciseRepsDictionary[exerciseName];
            
            ExerciseExecutionRowType* exerciseRow = [self.exerciseDescriptionsTable rowControllerAtIndex:i];
            
            CGFloat width = [[WKInterfaceDevice currentDevice] screenBounds].size.width;
            BOOL isBigWatch = width == 156.0;
            
            NSString *localizedName = NSLocalizedString(exerciseName, nil);
            if(self.exerciseNames.count > 1 && (localizedName.length > (isBigWatch ? 19 : 13))) {
                NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:localizedName];
                [text addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15-(localizedName.length/(isBigWatch ? 10 : 7)) weight:UIFontWeightSemibold] range:NSMakeRange(0, localizedName.length)];
                [exerciseRow.exerciseNameLabel setAttributedText:text];
            } else {
                /*if(localizedName.length > (isBigWatch ? 19 : 13)) {
                    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:localizedName];
                    [text addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15-(localizedName.length/(isBigWatch ? 10 : 7)) weight:UIFontWeightSemibold] range:NSMakeRange(0, localizedName.length)];
                    [exerciseRow.exerciseNameLabel setAttributedText:text];
                } else {*/
                    [exerciseRow.exerciseNameLabel setText:localizedName];
                //}
            }

            exerciseRow.exerciseIndex = i;
            
            int repsNumber = [setReps[self.currentSetIndex] intValue];
            NSString *repsLabelText = [NSString stringWithFormat:@"%d×", repsNumber];
            [exerciseRow.exerciseRepsLabel setText:repsLabelText];
            
            int weightNumber = [setWeights[self.currentSetIndex] intValue];
            NSString *weightLabelText = [NSString stringWithFormat:@"%d%@", weightNumber, self.kgOrLbs];
            [exerciseRow.exerciseWeightLabel setText:weightLabelText];
            
            i++;
        }
        
        NSString *startButtonTitle = [NSString stringWithFormat:NSLocalizedString(@"start_set_label", nil) , self.currentSetIndex+1, setWeights.count];
        
        if(self.currentSetIndex == 0 && state == 0) {
            [self.skipButton setHidden:NO];
        }
        
        [self.startSetButton setTitle:startButtonTitle];
        
        BOOL shouldHideTimer = (self.currentSetIndex == 0 && state.integerValue == 0);
        [rowWithStats.setTimer setHidden:shouldHideTimer];
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    [self presentControllerWithName:@"howToSceneID" context:[NSDictionary dictionaryWithObjectsAndKeys:[self.exerciseNames objectAtIndex:rowIndex-1], @"exerciseName", nil]];
}

- (void)fillRepsDonePickerWithBasicValue:(int)repsDefaultNumber {
    NSMutableArray *pickerItems = [NSMutableArray new];
    for (int i = 0; i < repsDefaultNumber + 20; i++) {
        WKPickerItem *pickerItem = [[WKPickerItem alloc] init];
        pickerItem.title = [NSString stringWithFormat:@"%d", i];
        pickerItem.caption = NSLocalizedString(@"repsDoneLabel", nil);
        [pickerItems addObject:pickerItem];
    }
    
    [self.repsDonePicker setItems: pickerItems];
    [self.repsDonePicker setSelectedItemIndex:repsDefaultNumber];
}

- (void)fillWeightUsedPickerWithBasicValue:(int)weightDefaultNumber {
    NSMutableArray *pickerItems = [NSMutableArray new];
    for (int i = 0; i < weightDefaultNumber + 30; i++) {
        WKPickerItem *pickerItem = [[WKPickerItem alloc] init];
        pickerItem.title = [NSString stringWithFormat:@"%d", i];
        pickerItem.caption = NSLocalizedString(@"weightsDoneLabel", nil);
        [pickerItems addObject:pickerItem];
    }
    [self.weightDonePicker setItems: pickerItems];
    [self.weightDonePicker setSelectedItemIndex:weightDefaultNumber];
}

- (void)scrollToTop {
    [self.exerciseDescriptionsTable scrollToRowAtIndex:0];
}

- (IBAction)startSetAction {
    [self.restTimeTimer invalidate];
    self.restTimeTimer = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastFinishedExerciseDate"];
    [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"exerciseExecutionState"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self performSelector:@selector(scrollToTop) withObject:nil afterDelay:0.5];
    
    NSArray *setWeights = self.exerciseWeightsDictionary[self.exerciseNames[0]];
    NSString *currentSetLabelTitle = [NSString stringWithFormat:@"%d/%d" , self.currentSetIndex+1, setWeights.count];
    
    StatusRowType *rowWithStats = [self.exerciseDescriptionsTable rowControllerAtIndex:0];
    [rowWithStats.setXofYLabel setText:currentSetLabelTitle];
    
    
    [self.skipButton setHidden:YES];
    [self.startSetButton setHidden:YES];
    [rowWithStats.timerGroup setBackgroundColor:[UIColor greenColor]];
    [rowWithStats.setTimer setDate:[NSDate dateWithTimeIntervalSinceNow:-1]];
    [rowWithStats.setTimer start];
    [self hideRestGroupWithoutStartOfNextSet];
    [rowWithStats.setTimer setHidden:NO];
    [self.finishButton setEnabled: YES];
    [self.currentSetExecutionGroup setHidden:NO];
    //[rowWithStats.statisticGroup setBackgroundColor:[UIColor greenColor]];
}

- (IBAction)finishSetAction {
    [self.finishButton setEnabled: NO];
    [self.currentSetExecutionGroup setHidden:YES];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey: @"shouldPlaySound"]) {
        WKInterfaceDevice *device = [WKInterfaceDevice currentDevice];
        [device playHaptic:WKHapticTypeStop];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastFinishedExerciseDate"];
    [[NSUserDefaults standardUserDefaults] setObject:@2 forKey:@"exerciseExecutionState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    StatusRowType *rowWithStats = [self.exerciseDescriptionsTable rowControllerAtIndex:0];
    
    [rowWithStats.setTimer stop];
    NSDictionary *trainingPlanInfo = self.connectivityManager.trainingPlanDictionary;
    NSNumber *restTime = [trainingPlanInfo objectForKey:@"restTimeKey"];
    self.restTimeTimer = [NSTimer scheduledTimerWithTimeInterval:[restTime integerValue] target:self selector:@selector(hideRestGroupWithStartOfNextSet) userInfo:nil repeats:NO];
    
    
    for(NSString *exerciseName in self.exerciseNames) {
        int reps = [self.exerciseRepsDictionary[exerciseName][self.currentSetIndex] integerValue];
        int weight = [self.exerciseWeightsDictionary[exerciseName][self.currentSetIndex] integerValue];
        [self.progressWatchdog saveResultForExerciseWithName:exerciseName withWeight:weight andReps:reps];
        if([self isLastSet]) {
            [self.progressWatchdog setStatus:ExerciseExecutionStatusFinished forExerciseWithName:exerciseName];
            [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"exerciseExecutionState"];
        }
    }
    
    [self prepareNextSet];
}

- (IBAction)editSet {
    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.exerciseNames, @"exerciseNames",
                             self.exerciseNames, @"exerciseNames",
                             self.exerciseNames, @"exerciseNames",
                             nil];
    [self presentControllerWithName:@"editSetSceneID" context:context];
}

- (void)setupFailureGroup {
    [self.exerciseNameFailLabel setText:NSLocalizedString(self.currentFailureExerciseName, nil)];
    
    NSArray *setWeights = self.exerciseWeightsDictionary[self.currentFailureExerciseName];
    NSArray *setReps = self.exerciseRepsDictionary[self.currentFailureExerciseName];
    int nextSet = [self.progressWatchdog nextSetForExercise:self.currentFailureExerciseName];

    int repsNumber = [setReps[nextSet] intValue];
    int weightNumber = [setWeights[nextSet] intValue];
    
    self.currentSetRepetitionsDone = repsNumber;
    [self fillRepsDonePickerWithBasicValue:repsNumber];
    self.currentSetWeightUsed = weightNumber;
    [self fillWeightUsedPickerWithBasicValue:weightNumber];
    
    [self.repsDonePicker focus];
}

- (IBAction)repsPickerChanged:(NSInteger)value {
    self.currentSetRepetitionsDone = value;
}

- (IBAction)weightPickerDone:(NSInteger)value {
    self.currentSetWeightUsed = value;
}

- (IBAction)failureRecorded {
    [self.repsDonePicker resignFocus];
    [self.weightDonePicker resignFocus];
    
    [self.progressWatchdog saveResultForExerciseWithName:self.currentFailureExerciseName withWeight:self.currentSetWeightUsed andReps:self.currentSetRepetitionsDone];
    if([self isLastSet]) {
        [self.progressWatchdog setStatus:ExerciseExecutionStatusFinished forExerciseWithName:self.currentFailureExerciseName];
    }
    
    if([self.currentFailureExerciseName isEqualToString:self.exerciseNames.lastObject]) {
        [self prepareNextSet];
        self.currentFailureExerciseName = nil;
    } else {
        int idx = [self.exerciseNames indexOfObject:self.currentFailureExerciseName];
        self.currentFailureExerciseName = self.exerciseNames[idx + 1];
        [self setupFailureGroup];
    }
}

- (BOOL)isLastSet {
    int numberOfSets = [self.exerciseWeightsDictionary[self.exerciseNames[0]] count];
    if(numberOfSets == self.currentSetIndex+1) {
        return YES;
    }
    return NO;
}

- (IBAction)goToSettings:(id)sender
{
    [self pushControllerWithName:@"settingsSceneID" context:nil];
}

- (IBAction)finishWorkoutNow:(id)sender
{
    [[ProgressWatchdog sharedWatchdog] finishWorkout];
}

- (void)hideRestGroupWithoutStartOfNextSet
{
    [self hideRestGroup];
}

- (void)hideRestGroupWithStartOfNextSet
{
    [self hideRestGroup];
    [self startSetAction];
}

- (void)hideRestGroup
{
    [self.restTimeTimer invalidate];
    self.restTimeTimer = nil;
    
    if([[NSUserDefaults standardUserDefaults] boolForKey: @"shouldPlaySound"]) {
        WKInterfaceDevice *device = [WKInterfaceDevice currentDevice];
        [device playHaptic:WKHapticTypeNotification];
    }
}

- (void)prepareNextSet
{
    if([self isLastSet]) {
        [self getInfoForced:YES];
    } else {
        [self setUIForCurrentSet];
    }
    [self.startSetButton setHidden:NO];
}

- (IBAction)gotoNextExerciseOnject {
    for(NSString *exerciseName in self.exerciseNames) {
        [self.progressWatchdog setStatus:ExerciseExecutionStatusFinished forExerciseWithName:exerciseName];
    }
    [self getInfoForced:YES];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [self.progressWatchdog finishPause];
    [self.progressWatchdog reload];
    [self.progressWatchdog startWorkoutSession];
    
    // [self addMenuItemWithImageNamed:@"Settings" title:NSLocalizedString(@"stopWorkoutLabel", nil) action:@selector(finishWorkoutNow:)];

    [self getInfoForced:NO];
    [self awakeHR];
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    
    if ([[sharedDefaults objectForKey:@"isWorkoutFinishDetected"] boolValue]) {
        [sharedDefaults setValue:@NO forKey:@"isWorkoutFinishDetected"];
        [sharedDefaults synchronize];
        [WKInterfaceController reloadRootControllersWithNames:@[@"startSceneID"] contexts:nil];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey: @"shouldPlaySound"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    startTime = nil;
    
    self.hrStarted = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super didDeactivate];
}

-(void)awakeHR {
    if(self.hrFound) {
        [self startTimer];
        return;
    }
    
    StatusRowType *rowWithStats = [self.exerciseDescriptionsTable rowControllerAtIndex:0];
    if(!rowWithStats) {
        [self performSelector:@selector(awakeHR) withObject:nil afterDelay:1];
    }


    if([[NSUserDefaults standardUserDefaults] boolForKey:@"heartRateAllowed"] == YES) {
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        /*for(int i = 1; i <= 9; i++) {
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"heart_red %d", i]];
            [images addObject:img];
        }*/
        
        /*[rowWithStats.heart_rate_icon setImage:[UIImage animatedImageWithImages:images duration:1.9]];
        [rowWithStats.heart_rate_icon startAnimating];*/
        
        [rowWithStats.heart_rate_icon setImageNamed:@"heart_red"];
        [rowWithStats.heart_rate_icon startAnimatingWithImagesInRange:NSMakeRange(0,8) duration:2 repeatCount:0];
        
        [self startTimer];
    } else {
        [rowWithStats.heart_rate_icon setHidden:YES];
    }
    
    if ([HKHealthStore isHealthDataAvailable]) {
        [rowWithStats.heartRateLabel setHidden:NO];
    } else {
        [rowWithStats.heartRateLabel setHidden:YES];
    }

}

//Be sure to add the return delegate method for the HR

#pragma mark HRTimerFunctions


//HR Timing Functions

- (void)startTimer{
    startTime = [NSDate dateWithTimeIntervalSinceNow:-10];
    self.hrStarted = YES;
    [self startHeartRateCheck];
}

#pragma mark HRMonitor

//HR Get user Heartrate

- (void)startHeartRateCheck {
    if(!startTime) {
        return;
    }
    
    HKSampleType *heartType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    NSDate *startDate, *endDate;
    if (lastHeartRateCheck == nil) {
        startDate = startTime;
    }
    else {
        startDate = lastHeartRateCheck;
    }
    lastHeartRateCheck = [NSDate date];
    endDate = [NSDate date];
    NSPredicate *predicateHeartRate = [HKQuery predicateForSamplesWithStartDate: startDate endDate: endDate options:HKQueryOptionNone];
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:heartType predicate:predicateHeartRate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler: ^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if(!results) {
        }
        else {
            if ([results count] == 0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSelector:@selector(startHeartRateCheck) withObject:nil afterDelay:5.0];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the user interface based on the current user's health information.
                    [self updateHeartrateLabel:[results objectAtIndex:0]];
                });
            }
        }
        
    }];
    [self.progressWatchdog.healthStore executeQuery:query];
}

- (void) updateHeartrateLabel: (HKQuantitySample*) sample {
    //heartrate = sample.quantity;
    HKQuantity *q = sample.quantity;
    double heartRateTest = [q doubleValueForUnit:[HKUnit unitFromString:@"count/min"]];
    NSInteger heartRate = [NSNumber numberWithDouble:heartRateTest].integerValue;
    StatusRowType *rowWithStats = [self.exerciseDescriptionsTable rowControllerAtIndex:0];

    if(!self.hrFound) {
        self.hrFound = YES;
        [rowWithStats.heart_rate_icon stopAnimating];
        NSMutableArray *images = [[NSMutableArray alloc] init];
        
        [rowWithStats.heart_rate_icon setImageNamed:@"heart"];
        [rowWithStats.heart_rate_icon startAnimatingWithImagesInRange:NSMakeRange(0,13) duration:2 repeatCount:0];
    }
    
    self.lastHR = heartRate;
    [rowWithStats.heartRateLabel setText:[NSString stringWithFormat:@"%ld",(long)heartRate]];

    if(self.hrStarted) {
        [self performSelector:@selector(startHeartRateCheck) withObject:nil afterDelay:5.0];
    }
}

@end



