//
//  ExerciseBottomView.h
//  F.I.T.
//
//  Created by Felix Belau on 24.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ExerciseSetState)
{
    ExerciseSetStateEmtpy,
    ExerciseSetStateStarting,
    ExerciseSetStateDoingExercise,
    ExerciseSetStateExerciseFinished,
    ExerciseSetStateTimer,
    ExerciseSetStateNextSet,
    ExerciseSetStatePreviousSet,
};

@interface ExerciseBottomView : UIView

@property (nonatomic) ExerciseSetState exerciseSetState;
@property (nonatomic) NSInteger timeInExercise;

@end
