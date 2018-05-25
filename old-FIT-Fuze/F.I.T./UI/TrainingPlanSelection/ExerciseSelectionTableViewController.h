//
//  ExerciseSelectionTableViewController.h
//  F.I.T.
//
//  Created by Felix Belau on 15.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIT-Swift.h"

@protocol ExerciseSelectionDelegate <NSObject>

- (void)exerciseSelected:(NSArray *)exercisesSelected;

@end

@interface ExerciseSelectionTableViewController : UITableViewController

@property (nonatomic, strong) Training *workout;
@property (nonatomic) BOOL exercisesAreSelectable;
@property (nonatomic, strong) NSString *exerciseType;
@property (nonatomic) BOOL isSuperset;
@property (nonatomic, weak) id<ExerciseSelectionDelegate> delegate;

@end
