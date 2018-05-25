//
//  TrainingPlanGroupTableViewCell.m
//  F.I.T.
//
//  Created by Felix Belau on 08.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "TrainingPlanGroupTableViewCell.h"

@implementation TrainingPlanGroupTableViewCell

- (void)awakeFromNib
{
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor whiteColor];
    self.selectedBackgroundView = v;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
