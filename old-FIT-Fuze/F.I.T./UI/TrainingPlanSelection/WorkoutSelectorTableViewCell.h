//
//  WorkoutSelectorTableViewCell.h
//  F.I.T.
//
//  Created by Felix Belau on 08.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkoutSelectorTableViewCellDelegate.h"
#import "MGSwipeTableCell.h"
#import "FIT-Swift.h"

@interface WorkoutSelectorTableViewCell : MGSwipeTableCell

@property (nonatomic) BOOL isExpanded;

@property (weak, nonatomic) IBOutlet UIImageView *workoutImageView;
@property (weak, nonatomic) IBOutlet UILabel *workoutTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *workoutDurationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *todayBanner;
@property (weak, nonatomic) IBOutlet UILabel *todayLabel;
@property (weak, nonatomic) IBOutlet UIButton *exerciseDetailButton;
@property (weak, nonatomic) IBOutlet UILabel *exerciseDetailLabel;
@property (weak, nonatomic) IBOutlet UIButton *repetitionsDoneButton;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) id <WorkoutSelectorTableViewCellDelegate> selectorDelegate;

- (void)dismissDetails;
- (void)showDetails;

@end
