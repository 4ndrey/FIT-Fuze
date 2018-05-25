//
//  WorkoutExecutionWatchdog.h
//  F.I.T.
//
//  Created by Ivan Chernov on 26/05/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Training;
@class Exercise;

typedef enum {
    ExerciseExecutionStatusNotDone = 0,
    ExerciseExecutionStatusInProgress = 1,
    ExerciseExecutionStatusFinished = 2,
    ExerciseExecutionStatusSkipped = 3
} ExerciseExecutionStatusType;

@interface WorkoutExecutionWatchdog : NSObject

+ (WorkoutExecutionWatchdog *)sharedWatchdog;
- (void)initStatusesForTraining:(Training *)training;
- (void)setStatus:(ExerciseExecutionStatusType)status forExercise:(Exercise *)exercise;
- (ExerciseExecutionStatusType)statusForExercise:(Exercise *)exercise;
- (BOOL)workoutIsFinished;

- (void)saveResultForExerciseWithName:(NSString *)exerciseName withWeight:(NSInteger)weight andReps:(NSInteger)reps;
- (void)saveStatusesFromAppContext:(NSDictionary *)appContext;
- (void)saveResultsFromAppContext:(NSDictionary *)appContext;
- (NSArray *)resultsForExercise:(Exercise *)exercise;
- (void)reset;

@property (nonatomic, strong) NSMutableDictionary *exerciseResults;
@property (strong, nonatomic) NSMutableDictionary *exerciseStatuses;

@end
