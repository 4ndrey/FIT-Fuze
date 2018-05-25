//
//  WorkoutSelectorExerciseTableViewCell.m
//  F.I.T.
//
//  Created by Felix Belau on 08.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "WorkoutSelectorExerciseTableViewCell.h"

@implementation WorkoutSelectorExerciseTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    if(self.showWithNextSign) {
        self.withNextSign.hidden = NO;
        self.bottomSeparator.hidden = NO;
        self.bottomRightSeparator.hidden = NO;
        self.superLabel.hidden = NO;
        self.setLabel.hidden = NO;
    } else {
        self.withNextSign.hidden = YES;
        self.bottomSeparator.hidden = YES;
        self.bottomRightSeparator.hidden = YES;
        self.superLabel.hidden = YES;
        self.setLabel.hidden = YES;
    }
    
    self.superLabel.text = NSLocalizedString(@"super_small_label_text", nil);
    self.setLabel.text = NSLocalizedString(@"set_small_label_text", nil);
    
    [super layoutSubviews];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:2.0 animations:^{
            self.superLabel.alpha = 0.0;
            self.setLabel.alpha = 0.0;
        }];
    });
}


@end
