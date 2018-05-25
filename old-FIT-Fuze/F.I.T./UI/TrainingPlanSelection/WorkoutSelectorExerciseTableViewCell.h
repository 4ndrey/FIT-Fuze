//
//  WorkoutSelectorExerciseTableViewCell.h
//  F.I.T.
//
//  Created by Felix Belau on 08.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkoutSelectorExerciseTableViewCell : UITableViewCell

@property (assign, nonatomic) BOOL showWithNextSign;
@property (weak, nonatomic) IBOutlet UIImageView *workoutExerciseImageView;
@property (weak, nonatomic) IBOutlet UILabel *exerciseTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *exerciseMetaInformationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *withNextSign;
@property (weak, nonatomic) IBOutlet UIView *bottomSeparator;
@property (weak, nonatomic) IBOutlet UIView *bottomRightSeparator;
@property (weak, nonatomic) IBOutlet UILabel *superLabel;
@property (weak, nonatomic) IBOutlet UILabel *setLabel;

@end
