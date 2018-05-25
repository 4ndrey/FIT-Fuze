//
//  WorkoutExecutionWatchdog.m
//  F.I.T.
//
//  Created by Ivan Chernov on 26/05/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import "WorkoutExecutionWatchdog.h"
#import "CurrentFitManager.h"
#import "FIT-Swift.h"
@import MagicalRecord;

@interface WorkoutExecutionWatchdog ()

@property (nonatomic, strong) Training *currentTraining;
@property (nonatomic, strong) CurrentFitManager *connectivityManager;
@property (strong, nonatomic) StatisticsProvider *statisticProvider;

@end


@implementation WorkoutExecutionWatchdog

+ (WorkoutExecutionWatchdog *)sharedWatchdog
{
    static WorkoutExecutionWatchdog *sharedInstance = nil;
    if (sharedInstance == nil)
    {
        sharedInstance = [[WorkoutExecutionWatchdog alloc] init];
        sharedInstance.connectivityManager = [CurrentFitManager sharedManager];
        sharedInstance.statisticProvider = [[StatisticsProvider alloc] init];
    }
    return sharedInstance;
}

- (void)reset {
    self.exerciseStatuses = [NSMutableDictionary new];
    self.exerciseResults = [NSMutableDictionary new];
}

- (BOOL)workoutIsFinished
{
    BOOL isFinished = YES;
    for(NSString *key in [self.exerciseStatuses allKeys]) {
        ExerciseExecutionStatusType status = (ExerciseExecutionStatusType)[[self.exerciseStatuses objectForKey:key] integerValue];
        if((status == ExerciseExecutionStatusNotDone) || (status == ExerciseExecutionStatusInProgress)) {
            isFinished = NO;
        }
    }
    return isFinished;
}

- (WorkoutExecutionWatchdog *)init
{
    if ((self = [super init]))
    {
        self.exerciseResults = [NSMutableDictionary new];
        self.exerciseStatuses = [NSMutableDictionary new];
    }
    return self;
}

- (void)initStatusesForTraining:(Training *)training {
    self.currentTraining = training;
    self.exerciseStatuses = self.exerciseStatuses ?: [[NSMutableDictionary alloc] init];
    for(ExerciseMetaMapping *mapping in self.currentTraining.exerciseMetaMappings) {
        [self.exerciseStatuses setValue:@(ExerciseExecutionStatusNotDone) forKey:mapping.exercise.name];
    }
}

- (void)setStatus:(ExerciseExecutionStatusType)status forExercise:(Exercise *)exercise
{
    [self.exerciseStatuses setValue:@(status) forKey:exercise.name];
    if(status != ExerciseExecutionStatusNotDone) {
        [self.connectivityManager updateStatuses:self.exerciseStatuses];
    }
}

- (ExerciseExecutionStatusType)statusForExercise:(Exercise *)exercise {
    if([[self.exerciseStatuses allKeys] containsObject:exercise.name]) {
        return (ExerciseExecutionStatusType)[[self.exerciseStatuses objectForKey:exercise.name] integerValue];
    } else {
        return ExerciseExecutionStatusNotDone;
    }
}

- (NSArray *)resultsForExercise:(Exercise *)exercise {
    return self.exerciseResults[exercise.name] ?: [NSArray new];
}

- (void)saveResultForExerciseWithName:(NSString *)exerciseName withWeight:(NSInteger)weight andReps:(NSInteger)reps {
    NSDictionary *resultToSave = @{@"date" : [NSDate date], @"weight" : @(weight), @"reps" : @(reps)};
    NSArray *resultsForThisExercise = [self.exerciseResults objectForKey:exerciseName];
    if(!resultsForThisExercise) {
        resultsForThisExercise = [NSArray arrayWithObject:resultToSave];
    } else {
        resultsForThisExercise = [resultsForThisExercise arrayByAddingObject:resultToSave];
    }
    [self.exerciseResults setObject:resultsForThisExercise forKey:exerciseName];
    
    Exercise *currentExercise = [[Exercise MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", exerciseName]] firstObject];
    [self.statisticProvider createHistoryEntry:currentExercise reps:reps weight:weight date:[NSDate date]];
    
    [self.connectivityManager updateResults:self.exerciseResults];
}

- (void)saveStatusesFromAppContext:(NSDictionary *)appContext
{
    NSDictionary *remoteStates = appContext[@"statesDictionary"];
    if(remoteStates) {
        
        NSArray *exerciseNames = [remoteStates allKeys];
        for(NSString *exerciseName in exerciseNames) {
            ExerciseExecutionStatusType currentStatus = (ExerciseExecutionStatusType)[[self.exerciseStatuses objectForKey:exerciseName] integerValue];
            if(currentStatus != ExerciseExecutionStatusFinished && currentStatus <= [remoteStates[exerciseName] integerValue]) {
                [self.exerciseStatuses setObject:remoteStates[exerciseName] forKey:exerciseName];
            }
        }
    }
}

- (void)saveResultsFromAppContext:(NSDictionary *)appContext
{
    NSDictionary *allRemoteResults = appContext[@"allResultsArray"];
    if(allRemoteResults) {
        for(NSDictionary *resultsDict in allRemoteResults) {
            NSMutableArray *allKeys = [[resultsDict allKeys] mutableCopy];
            [allKeys removeObject:@"date"];
            if(allKeys.count > 0) {
                NSString *exerciseName = allKeys[0];
                [self processExerciseWithName: exerciseName withResultDictionary: resultsDict[exerciseName]];
            }
        }
    }

    NSDictionary *remoteResults = appContext[@"resultsDictionary"];
    if(remoteResults) {
        NSArray *exerciseNames = [remoteResults allKeys];
        for(NSString *exerciseName in exerciseNames) {
            [self processExerciseWithName: exerciseName withResultDictionary: remoteResults[exerciseName]];
        }
    }
}

- (void)processExerciseWithName:(NSString *)exerciseName withResultDictionary:(NSDictionary *)remoteExerciseResults {
    NSArray *localExerciseResults = self.exerciseResults[exerciseName];

    if(!localExerciseResults || localExerciseResults.count == 0) {
        [self.exerciseResults setObject:remoteExerciseResults forKey:exerciseName];
    } else {
        for(NSDictionary *remoteExerciseResult in remoteExerciseResults) {
            NSDate *remoteExerciseResultDate = remoteExerciseResult[@"date"];
            BOOL isPresented = NO;
            for(NSDictionary *localExerciseResult in localExerciseResults) {
                NSDate *localExerciseResultDate = localExerciseResult[@"date"];
                if(fabs([localExerciseResultDate timeIntervalSinceDate:remoteExerciseResultDate]) < 1) {
                    isPresented = YES;
                }
            }
            
            if(!isPresented) {
                localExerciseResults = [localExerciseResults arrayByAddingObject:remoteExerciseResult];
            }
        }
        
        [self.exerciseResults setObject:localExerciseResults forKey:exerciseName];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *historyEntries = [self.statisticProvider getHistoryWithExercise:exerciseName];
        for(NSDictionary *result in self.exerciseResults[exerciseName]) {
            BOOL isPresented = NO;
            NSDate *exerciseResultDate = result[@"date"];
            
            for(History *obj in historyEntries) {
                if(fabs([obj.date timeIntervalSinceDate:exerciseResultDate]) < 1) {
                    isPresented = YES;
                }
            }
            
            if(!isPresented) {
                Exercise *currentExercise = [[Exercise MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", exerciseName]] firstObject];
                [self.statisticProvider createHistoryEntry:currentExercise reps:[result[@"reps"] integerValue] weight:[result[@"weight"] integerValue] date:exerciseResultDate];
            }
        }
    });

}


@end
