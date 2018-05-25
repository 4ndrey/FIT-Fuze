//
//  ExerciseListInterfaceController.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 30/04/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "ExerciseListInterfaceController.h"
#import "ExerciseSelectorRowType.h"
#import "ProgressWatchdog.h"
#import "ConnectivityManager.h"

@interface ExerciseListInterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceTable *exercisesListTable;
@property (assign, nonatomic) NSInteger previousIndex;
@property (strong, nonatomic) NSArray *exerciseObjects;
@property (strong, nonatomic) ConnectivityManager *connectivityManager;
@property (strong, nonatomic) ProgressWatchdog *progressWatchdog;
@end


@implementation ExerciseListInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.connectivityManager = [ConnectivityManager sharedManager];
    self.connectivityManager.finishedWorkoutIndex = -1;
    self.progressWatchdog = [ProgressWatchdog sharedWatchdog];
    [self fillTableInfo];
    self.connectivityManager.ignoreUpdates = YES;
    if([self.progressWatchdog.activeExerciseObjectIndex integerValue] == 0) {
        [self setStatus:ExerciseExecutionStatusInProgress forExerciseObjectAtIndex:0];
    }
    self.connectivityManager.ignoreUpdates = NO;
}

-(void)observeValueForKeyPath:(NSString*)keyPath
                     ofObject:(id)object
                       change:(NSDictionary*)change
                      context:(void*)context {
    if ([keyPath isEqual:@"trainingPlanDictionary"]) {
        [self stopAnimation];
        [self fillTableInfo];
        [self setTableColors];
        [self startAnimation];
    }
}

- (void)fillTableInfo {
    NSDictionary *workoutDict = self.connectivityManager.currentWorkout;
    [self setTitle:workoutDict[@"workoutName"]];

    self.exerciseObjects = workoutDict[@"workoutObjectsSet"];
    
    [self.exercisesListTable setNumberOfRows:(int)self.exerciseObjects.count withRowType:@"exerciseSelectorRowType"];
    
    int i = 0;
    for (NSDictionary *exerciseObject in self.exerciseObjects) {
        ExerciseSelectorRowType* exerciseRow = [self.exercisesListTable rowControllerAtIndex:i];
        
        NSString *name = @"";
        CGFloat width = [[WKInterfaceDevice currentDevice] screenBounds].size.width;
        BOOL isBigWatch = width == 156.0;
        NSArray *arrayOfNames = exerciseObject[@"exerciseNamesSet"];
        NSString *lastName = NSLocalizedString([arrayOfNames lastObject], nil);
        int numberOfLines = 0;
        BOOL heightChangeNeeded = arrayOfNames.count > 1;
        for(NSString *exName in arrayOfNames) {
            NSString *localizedExerciseNAme = NSLocalizedString(exName, nil);
            name = [name stringByAppendingString:[NSString stringWithFormat:@"%@", localizedExerciseNAme]];
            numberOfLines += ceil(localizedExerciseNAme.length/(isBigWatch ? 14.0 : 12.0));
            if(![localizedExerciseNAme isEqual:lastName]) {
                name = [name stringByAppendingString:isBigWatch ? @"\n––––––––––––––\n" : @"\n––––––––––––\n"];
                numberOfLines++;
            }
        }
        [exerciseRow.exerciseLabel setText: name];
        [exerciseRow.exerciseGroup sizeToFitWidth];

        [exerciseRow.exerciseGroup setBackgroundColor:[UIColor colorWithRed:38.0/255.0 green:76.0/255.0 blue:94.0/255.0 alpha:1.0]];
        exerciseRow.exerciseIndex = i;
        i++;
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    NSInteger currentExerciseIdx = [self.progressWatchdog.activeExerciseObjectIndex integerValue];
    
    if(currentExerciseIdx != rowIndex) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"exerciseExecutionState"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    self.previousIndex = currentExerciseIdx;
    [self setInProgressForIndex:rowIndex];
    self.progressWatchdog.activeExerciseObjectIndex = @(rowIndex);

    if (![self exerciseIsNotEmptyForIndex:rowIndex]) {
        [self pushControllerWithName:@"noSetsFilledID" context:nil];
        return;
    }

    [self pushControllerWithName:@"exerciseSceneID" context:[NSDictionary dictionaryWithObjectsAndKeys:@(rowIndex), @"exerciseObjectIndex", nil]];
}

- (BOOL)exerciseIsNotEmptyForIndex:(NSInteger)currentExerciseObjectIdx
{
    NSDictionary *exerciseObject = self.exerciseObjects[currentExerciseObjectIdx];
    NSDictionary *weightsDict = exerciseObject[@"setWeightsDictionary"];
    NSNumber *count = [weightsDict objectForKey:@"count"];
    return (count && count.intValue > 0);
}

- (void)setTableColors
{
    for (int i = 0; i<self.exercisesListTable.numberOfRows; i++) {
        ExerciseSelectorRowType* exerciseRow = [self.exercisesListTable rowControllerAtIndex:i];
        [exerciseRow.exerciseGroup setBackgroundColor:[UIColor colorWithRed:19.0/255.0 green:38.0/255.0 blue:47.0/255.0 alpha:1.0]];

        [exerciseRow.exerciseImage stopAnimating];
        
        NSDictionary *exerciseObject = [self.exerciseObjects objectAtIndex:i];
        NSString *keyExerciseName = exerciseObject[@"exerciseNamesSet"][0];
        switch ([self.progressWatchdog statusForExercise:keyExerciseName]) {
            case ExerciseExecutionStatusNotDone:
                [exerciseRow.exerciseImage setImageNamed:@"ToDo"];
                break;
                
            case ExerciseExecutionStatusInProgress:
                [exerciseRow.exerciseImage setImageNamed:@"InProgressExercise"];
                [exerciseRow.exerciseGroup setBackgroundColor:[UIColor colorWithRed:37.0/255.0 green:74.0/255.0 blue:92.0/255.0 alpha:1.0]];
                break;
                
            case ExerciseExecutionStatusFinished:
                [exerciseRow.exerciseImage setImageNamed:@"Done"];
                break;
                
            case ExerciseExecutionStatusSkipped:
                [exerciseRow.exerciseImage setImageNamed:@"Skipped"];
                break;
                
            default:
                break;
        }
    }
}

- (void)setInProgressForIndex:(NSInteger)index
{
    for (int i = 0; i<self.exercisesListTable.numberOfRows; i++) {
        NSDictionary *exerciseObject = [self.exerciseObjects objectAtIndex:i];
        NSString *keyExerciseName = exerciseObject[@"exerciseNamesSet"][0];
        if ([self.progressWatchdog statusForExercise:keyExerciseName] == ExerciseExecutionStatusInProgress) {
            [self setStatus:ExerciseExecutionStatusNotDone forExerciseObjectAtIndex:i];
        }
    }
    [self setStatus:ExerciseExecutionStatusInProgress forExerciseObjectAtIndex:index];
}

- (IBAction)goToSettings:(id)sender
{
    [self pushControllerWithName:@"settingsSceneID" context:nil];
}

- (IBAction)finishWorkoutNow:(id)sender
{
    [[ProgressWatchdog sharedWatchdog] finishWorkout];
}

- (void)startAnimation
{
    NSInteger currentExerciseIndex = [self.progressWatchdog.activeExerciseObjectIndex integerValue];
    ExerciseSelectorRowType* exerciseRow = [self.exercisesListTable rowControllerAtIndex:currentExerciseIndex];
    [exerciseRow.exerciseImage startAnimatingWithImagesInRange:NSMakeRange(0, 40) duration:2.0 repeatCount:3];
    [self.exercisesListTable scrollToRowAtIndex:currentExerciseIndex];
}

- (void)stopAnimation
{
    ExerciseSelectorRowType* exerciseRow = [self.exercisesListTable rowControllerAtIndex:self.previousIndex];
    [exerciseRow.exerciseImage stopAnimating];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [self.progressWatchdog reload];
    [self.progressWatchdog startPause];
    [self stopAnimation];
    [self setTableColors];
    [self startAnimation];
    [self.progressWatchdog endWorkoutSession];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey: @"shouldPlaySound"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [super willActivate];
}

- (void)setStatus:(ExerciseExecutionStatusType)status forExerciseObjectAtIndex:(NSInteger)index {
    NSArray *arrayOfNames = self.exerciseObjects[index][@"exerciseNamesSet"];
    for(NSString *exerciseName in arrayOfNames) {
        [self.progressWatchdog setStatus:status forExerciseWithName:exerciseName];
    }
}

@end



