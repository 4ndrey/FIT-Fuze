//
//  TrainingPlanMuscleGroupViewController.h
//  F.I.T.
//
//  Created by Felix Belau on 15.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIT-Swift.h"
#import "ExerciseSelectionTableViewController.h"

@interface MuscleGroupSelectionViewController : UIViewController

@property (nonatomic, strong) Training *workout;
@property (nonatomic) BOOL exercisesAreSelectable;
@property (nonatomic) BOOL isSuperset;
@property (nonatomic, weak) id<ExerciseSelectionDelegate> delegate;

@end
