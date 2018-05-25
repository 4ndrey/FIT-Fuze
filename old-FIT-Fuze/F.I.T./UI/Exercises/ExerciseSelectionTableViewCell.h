//
//  ExerciseSelectionTableViewCell.h
//  F.I.T.
//
//  Created by Felix Belau on 15.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExerciseSelectionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *exerciseImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *visualizationButton;

@property (strong, nonatomic) UIImageView *exerciseImage;

@end
