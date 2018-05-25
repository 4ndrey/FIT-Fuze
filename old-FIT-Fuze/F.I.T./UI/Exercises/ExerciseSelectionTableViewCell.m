//
//  ExerciseSelectionTableViewCell.m
//  F.I.T.
//
//  Created by Felix Belau on 15.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "ExerciseSelectionTableViewCell.h"

@implementation ExerciseSelectionTableViewCell

-(void)layoutSubviews
{
    [super layoutSubviews];
    if(self.exerciseImageView.animationImages.count <= 1) {
        self.visualizationButton.hidden = YES;
    } else {
        self.visualizationButton.hidden = NO;
    }
    
}

- (IBAction)visualize:(id)sender {
    [self.visualizationButton setHidden:YES];
    [self.exerciseImageView startAnimating];
    [self performSelector:@selector(didFinishAnimatingImageView:)
               withObject:sender
               afterDelay:self.exerciseImageView.animationDuration];
}

- (void)didFinishAnimatingImageView:(UIButton *)sender
{
    sender.hidden = NO;
}

@end
