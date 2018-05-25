//
//  TrainingPlanSelectionTableViewCell.m
//  F.I.T.
//
//  Created by Felix Belau on 08.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "TrainingPlanSelectionTableViewCell.h"

@implementation TrainingPlanSelectionTableViewCell

- (void)awakeFromNib
{
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.66];
;
    self.selectedBackgroundView = v;
}

@end
