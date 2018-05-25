//
//  ConnectivityManager.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 30/06/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface ConnectivityManager : NSObject
+ (instancetype)sharedManager;
- (BOOL)tryToGetInfoFromPhoneForced:(BOOL)forced;
- (void)setCurrentWorkout:(NSDictionary *)workout;

- (void)saveResultForExerciseWithName:(NSString *)exerciseName withWeight:(NSInteger)weight andReps:(NSInteger)reps;
- (void)updateStatuses:(NSDictionary *)statusesDictionary;
- (void)updateResults:(NSDictionary *)resultsDictionary;
- (void)finishWorkout;

@property (strong, nonatomic) NSDictionary *trainingPlanDictionary;
@property (strong, nonatomic) NSDictionary *currentWorkout;
@property (strong, nonatomic) NSDictionary *workoutStateDictionary;
@property (strong, nonatomic) WCSession *session;
@property (assign, nonatomic) int finishedWorkoutIndex;
@property (assign, nonatomic) BOOL ignoreUpdates;

@end
