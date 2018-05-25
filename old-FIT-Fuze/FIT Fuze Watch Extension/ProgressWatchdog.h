//
//  ProgressWatchdog.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 30/06/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

typedef enum {
    ExerciseExecutionStatusNotDone = 0,
    ExerciseExecutionStatusInProgress = 1,
    ExerciseExecutionStatusFinished = 2,
    ExerciseExecutionStatusSkipped = 3
} ExerciseExecutionStatusType;

@interface ProgressWatchdog : NSObject
+ (instancetype)sharedWatchdog;
- (void)setStatus:(ExerciseExecutionStatusType)status forExerciseWithName:(NSString *)exerciseName;
- (ExerciseExecutionStatusType)statusForExercise:(NSString *)exercise;
- (void)saveResultForExerciseWithName:(NSString *)exerciseName withWeight:(NSInteger)weight andReps:(NSInteger)reps;
- (NSArray *)getResultForExerciseWithName:(NSString *)exerciseName;
- (int)nextSetForExercise:(NSString *)exerciseName;
- (BOOL)refreshNextToDos;
- (NSDictionary *)getExerciseObjectWithIndex:(NSNumber *)indexNumber;

- (void)saveStatusesFromAppContext:(NSDictionary *)appContext;
- (void)saveResultsFromAppContext:(NSDictionary *)appContext;
- (void)reload;
- (void)reset;
- (BOOL)isInProgress;
- (void)finishWorkout;
- (void)startWorkoutSession;
- (void)startPause;
- (void)finishPause;
- (void)endWorkoutSession;
- (void)setLastSyncDate:(NSDate *)date;

@property (strong, nonatomic) NSDictionary *nextToDoExerciseObject;
@property (strong, nonatomic) NSString *nextToDoExerciseName;
@property (strong, nonatomic) NSNumber *nextToDoExerciseSet;
@property (strong, nonatomic) NSNumber *activeExerciseObjectIndex;
@property (strong, nonatomic) HKHealthStore* healthStore;

@property (strong, nonatomic) NSMutableDictionary *exerciseStatuses;
@property (strong, nonatomic) NSMutableDictionary *exerciseResults;

@end
