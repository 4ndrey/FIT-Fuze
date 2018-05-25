//
//  ExerciseBottomView.m
//  F.I.T.
//
//  Created by Felix Belau on 24.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "ExerciseBottomView.h"

@interface ExerciseBottomView ()

@property (nonatomic, weak) IBOutlet UIView *startView;

@property (nonatomic, weak) IBOutlet UIView *ongoingExererciseView;
@property (nonatomic, weak) IBOutlet UILabel *exerciseTimeLabel;

@property (nonatomic, weak) IBOutlet UIView *timerView;

@property (nonatomic, weak) IBOutlet UIView *exerciseFinishedView;

@property (nonatomic, weak) IBOutlet UIView *exerciseNextSet;

@property (nonatomic, weak) IBOutlet UIView *exercisePreviousSet;

@end

@implementation ExerciseBottomView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        
    }
    return self;
}

#pragma mark - Setters

- (void)setTimeInExercise:(NSInteger)timeInExercise
{
    _timeInExercise = timeInExercise;
    double seconds = fmod(_timeInExercise, 60.0);
    double minutes = fmod(trunc(_timeInExercise / 60.0), 60.0);
    self.exerciseTimeLabel.text = [NSString stringWithFormat:@"%01.0f:%02.0f", minutes, seconds];
}

- (void)setExerciseSetState:(ExerciseSetState)exerciseSetState
{
    _exerciseSetState = exerciseSetState;
    [UIView animateWithDuration:0.3 animations:^{
        _timerView.hidden = YES;
        _ongoingExererciseView.hidden = YES;
        _startView.hidden = YES;
        _exerciseFinishedView.hidden = YES;
        _exerciseNextSet.hidden = YES;
        _exercisePreviousSet.hidden = YES;
        
        _timerView.alpha = 0;
        _ongoingExererciseView.alpha = 0;
        _startView.alpha = 0;
        _exerciseFinishedView.alpha = 0;
        _exerciseNextSet.alpha = 0;
        _exercisePreviousSet.alpha = 0;
        
        switch (exerciseSetState)
        {
            case ExerciseSetStateEmtpy:
                break;
            case ExerciseSetStateStarting:
                _startView.hidden = NO;
                _startView.alpha = 1;
                break;
            case ExerciseSetStateDoingExercise:
                _ongoingExererciseView.hidden = NO;
                _ongoingExererciseView.alpha = 1;
                break;
            case ExerciseSetStateExerciseFinished:
                _exerciseFinishedView.hidden = NO;
                _exerciseFinishedView.alpha = 1;
                break;
            case ExerciseSetStateTimer:
                _timerView.hidden = NO;
                _timerView.alpha = 1;
                break;
            case ExerciseSetStateNextSet:
                _exerciseNextSet.hidden = NO;
                _exerciseNextSet.alpha = 1;
                break;
            case ExerciseSetStatePreviousSet:
                _exercisePreviousSet.hidden = NO;
                _exercisePreviousSet.alpha = 1;
                break;
            default:
                break;
        }
    }];
}


@end
