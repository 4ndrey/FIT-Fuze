//
//  ResultsRecorder.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 02/05/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "ResultsRecorder.h"
#import <WatchKit/WatchKit.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface ResultsRecorder()
@property (strong, nonatomic) NSMutableDictionary *currentWorkoutDict;
@property (strong, nonatomic) NSMutableArray *currentWorkoutExerciseNames;
@end

@implementation ResultsRecorder

+ (instancetype)sharedRecorder
{
    static ResultsRecorder *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _currentWorkoutDict = [[NSMutableDictionary alloc] init];
        _currentWorkoutExerciseNames = [[NSMutableArray alloc] init];
        NSDictionary *trainingPlanInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"trainingPlanInfo"];
        
        NSNumber *currentWorkoutIndex = [trainingPlanInfo objectForKey:@"currentWorkoutIndex"];
        NSArray *workoutsArray = [trainingPlanInfo objectForKey:@"workouts"];
        NSDictionary *workoutDict = [workoutsArray objectAtIndex: [currentWorkoutIndex integerValue]];
        
        NSArray *exercises = workoutDict[@"workoutObjectsSet"];

        for (NSDictionary *exerciseTuple in exercises) {
            NSDictionary *exerciseMeta = exerciseTuple[@"exercise"];
            [_currentWorkoutDict setValue:@(NO) forKey:exerciseMeta[@"exerciseName"]];
            [_currentWorkoutExerciseNames addObject:exerciseMeta[@"exerciseName"]];
        }
    }
    
    return self;
}

- (void)setResultsArray:(NSArray *)resultsArray forExerciseWithName:(NSString *)exerciseName
{
#warning connection to parent failed
  /*  BOOL isSavedSuccessfully = [WKInterfaceController openParentApplication:@{@"exerciseIsToSave":@{exerciseName:resultsArray}} reply:nil];
    if (!isSavedSuccessfully) {
        [self saveToSharedContainerFinishedExerciseData:@{exerciseName:resultsArray}];
    }*/
    [self.currentWorkoutDict setValue:resultsArray forKey:exerciseName];
}

- (void)saveToSharedContainerFinishedExerciseData:(NSDictionary *)exerciseDictionary
{
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    [sharedDefaults setObject:@(YES) forKey:@"exercisesFinished"];
    NSArray *finishedExercises = [sharedDefaults objectForKey:@"finishedExercises"];

    NSMutableArray *finishedMutableExercises;
    finishedMutableExercises = [finishedExercises mutableCopy];
    if (!finishedMutableExercises) {
        finishedMutableExercises = [[NSMutableArray alloc] init];
    }
    [finishedMutableExercises addObject:exerciseDictionary];
    [sharedDefaults setObject:[finishedMutableExercises copy] forKey:@"finishedExercises"];
    [sharedDefaults synchronize];
}

- (BOOL)isExerciseDone:(NSString *)exerciseName
{
    return ![[self.currentWorkoutDict valueForKey:exerciseName] isKindOfClass:[NSNumber class]];
}

- (void)saveAndReset
{
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    [self.currentWorkoutDict removeAllObjects];
    
    [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"currentExerciseIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSNumber *currentWorkoutIndex = [sharedDefaults objectForKey:@"currentWorkoutIndex"];
    NSArray *workoutsArray = [sharedDefaults objectForKey:@"workouts"];
    NSDictionary *workoutDict = [workoutsArray objectAtIndex: [currentWorkoutIndex integerValue]];
    
    NSArray *exercises = workoutDict[@"workoutObjectsSet"];
    
    [self.currentWorkoutDict removeAllObjects];
    [self.currentWorkoutExerciseNames removeAllObjects];
    for (NSDictionary *exerciseTuple in exercises) {
        NSDictionary *exerciseMeta = exerciseTuple[@"exercise"];
        [self.currentWorkoutDict setValue:@(NO) forKey:exerciseMeta[@"exerciseName"]];
        [self.currentWorkoutExerciseNames addObject:exerciseMeta[@"exerciseName"]];
    }
}

- (void)setCurrentWorkoutFinished
{
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    NSDictionary *trainingPlan = [sharedDefaults objectForKey:@"trainingPlanInfo"];
    NSNumber *currentWorkoutIndex = [trainingPlan objectForKey:@"currentWorkoutIndex"];
    NSArray *workoutsArray = [trainingPlan objectForKey:@"workouts"];
#warning connection to parent failed
    /*
    BOOL isSavedSuccessfully = [WKInterfaceController openParentApplication:@{@"workoutIndexToSave":currentWorkoutIndex} reply:nil];
    if (!isSavedSuccessfully) {
        [self saveToSharedContainerFinishedWorkoutIndex:currentWorkoutIndex];
    } */
    
   /* [[WCSession defaultSession] sendMessage:request
                               replyHandler:^(NSDictionary *reply) {
                               }
                               errorHandler:^(NSError *error) {
                               }
     ]; */
    
    int nextWorkoutIndex = [currentWorkoutIndex intValue];
    nextWorkoutIndex++;
    if(nextWorkoutIndex >= workoutsArray.count)
    {
        nextWorkoutIndex = 0;
    }
    NSString *currentWorkoutName = workoutsArray[[currentWorkoutIndex integerValue]][@"workoutName"];
    NSMutableDictionary *durations = [NSMutableDictionary dictionaryWithDictionary: [sharedDefaults objectForKey:@"durations"]];
    NSNumber *doneNumberOfCurrentWorkout = durations[currentWorkoutName];
    doneNumberOfCurrentWorkout = doneNumberOfCurrentWorkout ? doneNumberOfCurrentWorkout : @0;
    [durations setValue:[NSNumber numberWithInt:([doneNumberOfCurrentWorkout intValue] + 1)] forKey:currentWorkoutName];
    [sharedDefaults setValue:[durations copy] forKey:@"durations"];
    
    [sharedDefaults setValue:[NSNumber numberWithInt:nextWorkoutIndex] forKey:@"currentWorkoutIndex"];
    [sharedDefaults synchronize];
    
    [self saveAndReset];
}

- (void)saveToSharedContainerFinishedWorkoutIndex:(NSNumber *)currentWorkoutIndex
{
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    [sharedDefaults setObject:@(YES) forKey:@"workoutsFinished"];
    NSArray *finishedWorkoutsIndecies = [sharedDefaults objectForKey:@"finishedWorkouts"];
    NSMutableArray *finishedWorkouts;
    finishedWorkouts = [finishedWorkoutsIndecies mutableCopy];
    if (!finishedWorkouts) {
        finishedWorkouts = [[NSMutableArray alloc] init];
    }
    [finishedWorkouts addObject:currentWorkoutIndex];
    [sharedDefaults setObject:[finishedWorkouts copy] forKey:@"finishedWorkouts"];
    [sharedDefaults synchronize];
}

- (BOOL)areAllExercisesFinished
{
    BOOL returnValue = YES;
    for (NSString *key in [self.currentWorkoutDict allKeys]) {
        if ([self.currentWorkoutDict[key] isEqual:@(NO)]) {
            returnValue = NO;
        }
    }
    return returnValue;
}

- (int)indexOfFirstNotFinishedExercise
{
    int returnValue = 0;
    for (NSString *key in self.currentWorkoutExerciseNames) {
        if ([self.currentWorkoutDict[key] isEqual:@(NO)]) {
            returnValue = (int)[self.currentWorkoutExerciseNames indexOfObject:key];
            break;
        }
    }
    return returnValue;
}

@end
