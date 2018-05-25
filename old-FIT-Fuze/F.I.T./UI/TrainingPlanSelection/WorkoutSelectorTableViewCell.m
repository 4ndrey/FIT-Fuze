
//
//  WorkoutSelectorTableViewCell.m
//  F.I.T.
//
//  Created by Felix Belau on 08.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "WorkoutSelectorTableViewCell.h"

@implementation WorkoutSelectorTableViewCell

- (void)dismissDetails
{
    self.isExpanded = NO;
    CGAffineTransform transform = CGAffineTransformMakeRotation(0);
    self.exerciseDetailButton.imageView.transform = transform;
    self.bgView.layer.cornerRadius = 3;
}

- (void)showDetails
{
    self.isExpanded = YES;
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
    self.exerciseDetailButton.imageView.transform = transform;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIButton *b = self.exerciseDetailButton;
    
    b.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    b.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    b.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);

    self.todayLabel.transform = CGAffineTransformMakeRotation (-0.8);
}

- (IBAction)detailsButtonPressed:(UIButton *)sender
{
    self.isExpanded = !self.isExpanded;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^
     {
         CGFloat angle = [(NSNumber *)[self.exerciseDetailButton.imageView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
         CGAffineTransform transform = CGAffineTransformMakeRotation(angle-M_PI);
         self.exerciseDetailButton.imageView.transform = transform;
     } completion:NULL];
    [self.selectorDelegate detailButtonPressedTableViewCell:self];
}

- (IBAction)changeWorkoutRepetitionsCount {
    if([self.selectorDelegate respondsToSelector:@selector(repetitionsButtonPressedTableViewCell:)]) {
        [self.selectorDelegate repetitionsButtonPressedTableViewCell:self];
    }
}

- (void)prepareForReuse {
    self.exerciseDetailButton.imageView.transform = self.isExpanded ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformMakeRotation(0);

}

@end
