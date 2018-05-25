//
//  TopWorkoutViewControllerDelegate.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 05/06/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#ifndef TopWorkoutViewControllerDelegate_h
#define TopWorkoutViewControllerDelegate_h


#endif /* TopWorkoutViewControllerDelegate_h */


@class ExerciseMetaMapping;

@protocol TopWorkoutViewControllerDelegate <NSObject>

- (void)showDetailsForExerciseMetaMapping:(ExerciseMetaMapping *)exerciseMetaMapping;

@end