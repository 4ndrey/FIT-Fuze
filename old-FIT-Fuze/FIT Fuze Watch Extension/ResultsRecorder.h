//
//  ResultsRecorder.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 02/05/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResultsRecorder : NSObject
+ (instancetype)sharedRecorder;
- (void)setResultsArray:(NSArray *)resultsArray forExerciseWithName:(NSString *)exerciseName;
- (BOOL)isExerciseDone:(NSString *)exerciseName;
- (void)saveAndReset;
- (void)setCurrentWorkoutFinished;
- (BOOL)areAllExercisesFinished;
- (int)indexOfFirstNotFinishedExercise;
@end
