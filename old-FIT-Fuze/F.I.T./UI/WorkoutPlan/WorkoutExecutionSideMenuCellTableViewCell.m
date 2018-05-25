//
//  WorkoutExecutionSideMenuCellTableViewCell.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 17/07/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "WorkoutExecutionSideMenuCellTableViewCell.h"

@implementation WorkoutExecutionSideMenuCellTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    if(self.withNext) {
        self.withNextSign.hidden = NO;
        self.leftLineSeparator.hidden = NO;
        self.rightLineSeparator.hidden = NO;
    } else {
        self.withNextSign.hidden = YES;
        self.leftLineSeparator.hidden = YES;
        self.rightLineSeparator.hidden = YES;
    }
    [super layoutSubviews];
}

@end
