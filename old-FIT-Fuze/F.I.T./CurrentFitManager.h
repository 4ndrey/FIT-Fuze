//
//  CurrentFitManager.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 19/04/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FIT-Swift.h"

@interface CurrentFitManager : NSObject

+ (instancetype)sharedManager;
- (void)saveCurrentProgram:(TrainingProgram *)program dublicate:(BOOL)duplicate;
- (BOOL)switchToNextExercise;
- (void)setCurrentWorkoutIndex:(NSInteger)index;
- (void)saveCurrentTraining;
- (NSOrderedSet *)getOrderedSetOfExerciseObjectsForWorkout: (Training *)workout;
- (void)tryToGetTransfers;
- (void)updateStatuses:(NSDictionary *)statusesDictionary;
- (void)updateResults:(NSDictionary *)resultsDictionary;
- (void)getWatchData;

@end
