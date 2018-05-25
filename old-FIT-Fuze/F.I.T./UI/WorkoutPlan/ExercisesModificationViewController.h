//
//  WorkoutModificationViewController.h
//  F.I.T.
//
//  Created by Felix Belau on 04.04.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIT-Swift.h"

@interface ExercisesModificationViewController : UIViewController

@property (nonatomic, strong) Training *workout;
@property (nonatomic) BOOL editModeIsUnavailable;
@property (nonatomic) BOOL isInEditingMode;

@end
