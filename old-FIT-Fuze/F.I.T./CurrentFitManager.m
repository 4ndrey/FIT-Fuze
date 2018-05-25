//
//  CurrentFitManager.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 19/04/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "CurrentFitManager.h"
#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "NSManagedObjectContext+FetchedObjectFromURI.h"
#import "WorkoutExecutionWatchdog.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "WorkoutExecutionWatchdog.h"

@import MagicalRecord;

@interface CurrentFitManager () <WCSessionDelegate>
@property (assign, nonatomic) NSInteger indexOfWorkoutToSave;
@property (strong, nonatomic) WCSession *watchSession;
@property (strong, nonatomic) NSDate *latestFinishedWorkoutTimestamp;
@end

@implementation CurrentFitManager

CGFloat maxWatchImageSideSize = 100;

+ (instancetype)sharedManager
{
    static CurrentFitManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
        if(_sharedManager)
        {
            _sharedManager.indexOfWorkoutToSave = 0;
            if ([WCSession isSupported]) {
                WCSession *watchSession = [WCSession defaultSession];
                watchSession.delegate = _sharedManager;
                [watchSession activateSession];
                _sharedManager.watchSession = watchSession;
            }
        }
    });
    
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    
    return self;
}

- (void)tryToGetTransfers {
    if([self.watchSession outstandingFileTransfers]) {
        // do something
    }
}

- (void)saveCurrentProgram:(TrainingProgram *)program dublicate:(BOOL)duplicate
{
    ContentProvider *contentProvider = [[ContentProvider alloc] init];
    
    TrainingProgram *currentTrainingProgram = program;
    if (duplicate)
    {
        currentTrainingProgram = [contentProvider copyTrainingProgram:program];
    }
    [[NSUserDefaults standardUserDefaults] setURL:currentTrainingProgram.objectID.URIRepresentation forKey:@"currentTrainingplan"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setCurrentWorkoutIndex:0];
    [self saveCurrentTraining];
}

- (void)saveCurrentTraining
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , ^{
        NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];
        if ([[NSUserDefaults standardUserDefaults] URLForKey:@"currentTrainingplan"] != nil) {
            TrainingProgram *currentTrainingProgram = (TrainingProgram *)[moc objectWithURI:[[NSUserDefaults standardUserDefaults] URLForKey:@"currentTrainingplan"]];
            if (currentTrainingProgram) {

                NSDictionary *trainingPlanStateDictionary = [self getDictionaryForTrainingProgram: currentTrainingProgram];
                NSError *error = nil;
                [[WCSession defaultSession] updateApplicationContext:trainingPlanStateDictionary error:&error];
            }
        }
    });
}

- (NSDictionary *)getExecutionDictionaryForTrainingProgram:(TrainingProgram *)plan {
    NSMutableDictionary *tpDictionary = [NSMutableDictionary new];
    [tpDictionary setValue:plan.name forKey:@"planName"];
    [tpDictionary setValue:plan.workoutRepetition forKey:@"numberOfWorkoutReps"];
    
    NSMutableArray *traningsDicts = [NSMutableArray new];
    for(Training *workout in plan.trainings) {
        NSMutableDictionary *workoutDictionary = [NSMutableDictionary new];
        [workoutDictionary setObject:workout.name forKey:@"workoutName"];
        [workoutDictionary setObject:workout.repetitionCounter forKey:@"numberOfRepsDone"];
        [traningsDicts addObject:[workoutDictionary copy]];
    }
    [tpDictionary setValue:traningsDicts forKey:@"workouts"];
    [tpDictionary setValue:@(self.indexOfWorkoutToSave) forKey:@"currentWorkoutIndex"];
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    [tpDictionary setValue:[sharedDefaults objectForKey:kilogrammChoosenKey] forKey:kilogrammChoosenKey];
    [tpDictionary setValue:[sharedDefaults objectForKey:restTimeKey] forKey:restTimeKey];
    
    return [tpDictionary copy];
}

- (NSDictionary *)getDictionaryForTrainingProgram:(TrainingProgram *)plan {
    NSMutableDictionary *tpDictionary = [NSMutableDictionary new];
    [tpDictionary setValue:plan.name forKey:@"planName"];
    [tpDictionary setValue:plan.workoutRepetition forKey:@"numberOfWorkoutReps"];
    
    NSMutableArray *traningsDicts = [NSMutableArray new];
    for(Training *workout in plan.trainings) {
        NSMutableDictionary *workoutDictionary = [NSMutableDictionary new];
        [workoutDictionary setObject:workout.name forKey:@"workoutName"];
        [workoutDictionary setObject:workout.repetitionCounter forKey:@"numberOfRepsDone"];
        NSArray *workoutObjectsSet = [self getExerciseDictionariesFromWorkout:workout];
        [workoutDictionary setObject:workoutObjectsSet forKey:@"workoutObjectsSet"];
        
        [traningsDicts addObject:[workoutDictionary copy]];
    }
    [tpDictionary setValue:traningsDicts forKey:@"workouts"];
    [tpDictionary setValue:@(self.indexOfWorkoutToSave) forKey:@"currentWorkoutIndex"];
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    [tpDictionary setValue:[sharedDefaults objectForKey:kilogrammChoosenKey] forKey:kilogrammChoosenKey];
    [tpDictionary setValue:[sharedDefaults objectForKey:restTimeKey] forKey:restTimeKey];

    return [tpDictionary copy];
}

- (NSArray *)getExerciseDictionariesFromWorkout:(Training *)workout {
    NSOrderedSet *exerciseObjects = [self getOrderedSetOfExerciseObjectsForWorkout:workout];
    NSMutableArray *exerciseObjectsDictionaries = [NSMutableArray new];
    for(NSOrderedSet *exerciseMetaMappingsSet in exerciseObjects) { //exercise object = either one exerciseMetaMApping (usual set) or orderedSet of exerciseMetaMappings (superset)
        NSMutableArray *exerciseNames = [NSMutableArray new]; //names of exercises the (super)set consists of
        NSMutableDictionary *setWeightsDictionary = [NSMutableDictionary new]; //for each of the exercises the (super)set consists of we add an array of reps and weights, used in this (super)set
        NSMutableDictionary *setRepetitionsDictionary = [NSMutableDictionary new];

        for(ExerciseMetaMapping *metaMapping in exerciseMetaMappingsSet) {
            [exerciseNames addObject:metaMapping.exercise.name];
            NSMutableArray *exerciseWeights = [NSMutableArray new];
            NSMutableArray *exerciseRepetitions = [NSMutableArray new];
            for(WorkoutSet *set in metaMapping.exerciseMeta.sets) {
                [exerciseWeights addObject:set.weights];
                [exerciseRepetitions addObject:set.repetitions];
            }
            [setWeightsDictionary setObject:@(exerciseWeights.count) forKey:@"count"];
            [setWeightsDictionary setObject:exerciseWeights forKey:metaMapping.exercise.name];
            [setRepetitionsDictionary setObject:@(exerciseRepetitions.count) forKey:@"count"];
            [setRepetitionsDictionary setObject:exerciseRepetitions  forKey:metaMapping.exercise.name];
        }
        
        NSDictionary *exerciseMetaDictionary = @{@"exerciseNamesSet" : [exerciseNames copy], // z.B. ["Bench Press", "Biceps Curls"]
                                                 @"setWeightsDictionary" : [setWeightsDictionary copy],  // z.B. ["Bench Press":[75, 75, 80], "Biceps Curls":[16, 16, 16]]
                                                 @"setRepetitionsDictionary" : [setRepetitionsDictionary copy]  // z.B. ["Bench Press":[8, 8, 8], "Biceps Curls":[10, 10, 10]]
                                                 };
        [exerciseObjectsDictionaries addObject:exerciseMetaDictionary];
    }
    return [exerciseObjectsDictionaries copy];
}

- (NSOrderedSet *)getOrderedSetOfExerciseObjectsForWorkout: (Training *)workout {
    
    NSMutableOrderedSet *exerciseObjects = [NSMutableOrderedSet new];
    NSOrderedSet *exerciseMappings = workout.exerciseMetaMappings;
    
    int idx = 0;
    while(idx < exerciseMappings.count) {
        ExerciseMetaMapping *mapping = [exerciseMappings objectAtIndex:idx];
        BOOL withNext = mapping.withNext;
        if(withNext == NO) {
            [exerciseObjects addObject:[[NSOrderedSet alloc] initWithObjects:mapping, nil]];
        } else {
            NSMutableOrderedSet *superset = [[NSMutableOrderedSet alloc] init];
            while(mapping.withNext == YES && idx < exerciseMappings.count) {
                [superset addObject:mapping];
                idx++;
                mapping = [exerciseMappings objectAtIndex:idx];
            }
            [superset addObject:mapping];
            [exerciseObjects addObject:superset];
        }
        idx++;
    }
    
    return exerciseObjects;
}

- (void)setCurrentWorkoutIndex:(NSInteger)index
{
    if(self.indexOfWorkoutToSave != index) {
        self.indexOfWorkoutToSave = index;
        [self saveCurrentTraining]; //to save the duration values
    }
}

- (BOOL)switchToNextExercise
{
    return YES;
}

#pragma mark - WCSessionDelegate Delegate

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(nonnull void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler {
    
    if([message objectForKey:@"currentWorkoutIndex"]) {
        [self setCurrentWorkoutIndex:[[message objectForKey:@"currentWorkoutIndex"] integerValue]];
        replyHandler(@{@"status" : @"success"});
    } else {
        replyHandler(@{});
    }
    
}

/** Called when the reachable state of the counterpart app changes. The receiver should check the reachable property on receiving this delegate callback. */
- (void)sessionReachabilityDidChange:(WCSession *)session {
    
}

- (void)sessionDidDeactivate:(WCSession *)session {
    [WCSession.defaultSession activateSession];
}

- (void)sessionDidBecomeInactive:(WCSession *)session {
    
}

- (void)removeOldUUIDsFromContext:(NSMutableDictionary *)mutableAppContext {
    NSArray *allKeys = [mutableAppContext allKeys];
    NSPredicate *REMOVEPredicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] 'REMOVE-'"];
    NSArray *beginWithREMOVEKeys = [allKeys filteredArrayUsingPredicate:REMOVEPredicate];
    for(NSString *key in beginWithREMOVEKeys) {
        [mutableAppContext removeObjectForKey:key];
    }
}

- (void)addUUIDToContext:(NSMutableDictionary *)mutableAppContext {
    [mutableAppContext setObject:[[NSUUID UUID] UUIDString] forKey: [NSString stringWithFormat:@"REMOVE-%@", [[NSUUID UUID] UUIDString]]];
}

- (void)getWatchData {
    NSError *error;
    NSMutableDictionary *appContext = [self.watchSession.applicationContext mutableCopy];
    if(!appContext) {
        appContext = [@{@"resultsDictionary" : @{}, @"isInProgress" : @YES, @"statesDictionary" : @{}} mutableCopy];
    }
    [appContext setObject:@YES forKey:@"phoneDataUpdateRequested"];
    [self removeOldUUIDsFromContext:appContext];
    [self addUUIDToContext:appContext];
    
    [appContext setValue:@NO forKey:@"fromWatch"];
    [appContext setValue:@YES forKey:@"fromPhone"];
    
    [self.watchSession updateApplicationContext:appContext error:&error];
}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo {    
    if(userInfo[@"finishedWorkoutData"] != nil) {
        [[WorkoutExecutionWatchdog sharedWatchdog] saveStatusesFromAppContext:userInfo[@"finishedWorkoutData"]];
        [[WorkoutExecutionWatchdog sharedWatchdog] saveResultsFromAppContext:userInfo[@"finishedWorkoutData"]];
        [[WorkoutExecutionWatchdog sharedWatchdog] reset];
    }
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *, id> *)applicationContext {
    if(![[applicationContext valueForKey:@"fromWatch"] isEqual: @YES]) {
        return;
    }

    [[WorkoutExecutionWatchdog sharedWatchdog] saveStatusesFromAppContext:applicationContext];
    [[WorkoutExecutionWatchdog sharedWatchdog] saveResultsFromAppContext:applicationContext];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FITConnectionUpdateNotification" object:nil];
    
    BOOL shouldSaveFinishedWorkoutData = NO;
    NSDate *timestamp = applicationContext[@"lastChangeTimestamp"];
    if(!self.latestFinishedWorkoutTimestamp || [timestamp timeIntervalSinceDate:self.latestFinishedWorkoutTimestamp] > 0) {
        self.latestFinishedWorkoutTimestamp = timestamp;
        shouldSaveFinishedWorkoutData = YES;
    }
    
    if([applicationContext valueForKey:@"finishedWorkoutIndex"]) {
        NSNumber *index = [applicationContext valueForKey:@"finishedWorkoutIndex"];
        if(index && index.intValue >= 0) {
            
            if(shouldSaveFinishedWorkoutData) {
                NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];
                TrainingProgram *currentTrainingProgram = (TrainingProgram *)[moc objectWithURI:[[NSUserDefaults standardUserDefaults] URLForKey:@"currentTrainingplan"]];
                NSArray *workouts = [[currentTrainingProgram.trainings array] mutableCopy];
                Training *workout = [workouts objectAtIndex:index.integerValue];
                workout.repetitionCounter = @([workout.repetitionCounter integerValue] + 1);
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserChangedPlan" object:nil];
            }
            
            [[WorkoutExecutionWatchdog sharedWatchdog] reset];
        }
    }
    
    [self setLastSyncDate];
    
    NSObject *trainingPlanRequested = [applicationContext valueForKey:@"trainingPlanRequested"];
    if(trainingPlanRequested != nil && [trainingPlanRequested isEqual: @YES]) {
        
        NSMutableDictionary *appContext = [NSMutableDictionary new];
        [appContext setObject:@NO forKey:@"trainingPlanRequested"];
        [self removeOldUUIDsFromContext:appContext];
        [self addUUIDToContext:appContext];
        
        NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];
        if ([[NSUserDefaults standardUserDefaults] URLForKey:@"currentTrainingplan"] != nil) {
            TrainingProgram *currentTrainingProgram = (TrainingProgram *)[moc objectWithURI:[[NSUserDefaults standardUserDefaults] URLForKey:@"currentTrainingplan"]];
            if (currentTrainingProgram) {
                NSDictionary *trainingPlanStateDictionary = [self getDictionaryForTrainingProgram: currentTrainingProgram];
                
                [appContext setObject:trainingPlanStateDictionary forKey:@"trainingPlanInfo"];
                [appContext setObject:[WorkoutExecutionWatchdog sharedWatchdog].exerciseResults forKey:@"resultsDictionary"];
                [appContext setObject:@YES forKey:@"isInProgress"];
                [appContext setObject:[WorkoutExecutionWatchdog sharedWatchdog].exerciseStatuses forKey:@"statesDictionary"];
            }
        }
        
        [appContext setValue:@NO forKey:@"fromWatch"];
        [appContext setValue:@YES forKey:@"fromPhone"];
        
        NSError *error;
        [self.watchSession updateApplicationContext:appContext error:&error];
    } else {
        NSMutableDictionary *appContext = [NSMutableDictionary new];
        [appContext setValue:@NO forKey:@"fromWatch"];
        [appContext setValue:@NO forKey:@"fromPhone"];
        [self removeOldUUIDsFromContext:appContext];
        [self addUUIDToContext:appContext];
        
        NSError *error;
        [self.watchSession updateApplicationContext:appContext error:&error];
    }
}

- (void)setLastSyncDate {
    NSError *error;
    NSMutableDictionary *appContext = [NSMutableDictionary new];
    [appContext setObject:[NSDate date] forKey:@"lastSyncDate"];
    
    [self removeOldUUIDsFromContext:appContext];
    [self addUUIDToContext:appContext];
    
    [appContext setValue:@NO forKey:@"fromWatch"];
    [appContext setValue:@YES forKey:@"fromPhone"];
    
    [self.watchSession updateApplicationContext:appContext error:&error];
}

- (void)updateStatuses:(NSDictionary *)statusesDictionary {
    NSError *error;
    NSMutableDictionary *appContext = [NSMutableDictionary new];

    [appContext setObject:statusesDictionary forKey:@"statesDictionary"];
    [self removeOldUUIDsFromContext:appContext];
    [self addUUIDToContext:appContext];
    
    [appContext setValue:@NO forKey:@"fromWatch"];
    [appContext setValue:@YES forKey:@"fromPhone"];

    [self.watchSession updateApplicationContext:appContext error:&error];
}

- (void)updateResults:(NSDictionary *)resultsDictionary {
    NSError *error;
    NSMutableDictionary *appContext = [NSMutableDictionary new];

    [appContext setObject:resultsDictionary forKey:@"resultsDictionary"];
    [self removeOldUUIDsFromContext:appContext];
    [self addUUIDToContext:appContext];
    
    [appContext setValue:@NO forKey:@"fromWatch"];
    [appContext setValue:@YES forKey:@"fromPhone"];

    [self.watchSession updateApplicationContext:appContext error:&error];
}


@end
