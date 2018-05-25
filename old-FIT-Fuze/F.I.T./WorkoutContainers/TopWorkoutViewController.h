//
//  TopWorkoutViewController.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 21/05/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopWorkoutViewControllerDelegate.h"

@interface TopWorkoutViewController : UIViewController

@property (strong, nonatomic) ExerciseMetaMapping *exerciseMapping;
@property (weak, nonatomic) id<TopWorkoutViewControllerDelegate> delegate;

@end
