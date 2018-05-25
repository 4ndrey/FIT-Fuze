//
//  TopWorkoutCollectionViewCell.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 02/06/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import "TopWorkoutCollectionViewCell.h"

@interface TopWorkoutCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *exerciseImageView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *exerciseNameLabel;
@property (weak, nonatomic) IBOutlet UIView *exerciseColorLineView;
@property (weak, nonatomic) IBOutlet UIButton *detailsButton;
@property (weak, nonatomic) IBOutlet UIButton *showHideButton;
@property (weak, nonatomic) IBOutlet UIView *detailsView;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *effectView;
@property (strong, nonatomic) ExerciseMetaMapping *exerciseMetaMapping;

@property (nonatomic, assign) BOOL isBlurred;
@end

@implementation TopWorkoutCollectionViewCell

-(void)setupWithExerciseMetaMapping:(ExerciseMetaMapping *)mapping color:(UIColor *)color {
    self.exerciseMetaMapping = mapping;
    self.exerciseColorLineView.backgroundColor = color;
    self.exerciseNameLabel.text = NSLocalizedString(mapping.exercise.name, nil);
    CGFloat width = self.bounds.size.width - 10;//your desire width
    self.exerciseNameLabel.preferredMaxLayoutWidth = width;
    [self decreaseFontSizeIfNeeded];
    [self setupImage];
    self.exerciseImageView.layer.borderWidth = 2;
    self.exerciseImageView.layer.borderColor = color.CGColor;
    self.backgroundColor = [UIColor whiteColor];
    self.effectView.alpha = 0;
    
    [self.detailsButton setTitle:NSLocalizedString(@"DetailButton_Title", nil) forState:UIControlStateNormal];
}

- (void)layoutSubviews {
    self.exerciseImageView.layer.cornerRadius = 3;
    self.exerciseImageView.clipsToBounds = YES;
    [super layoutSubviews];
}

- (void)decreaseFontSizeIfNeeded {
    NSArray *words = [self.exerciseNameLabel.text componentsSeparatedByString: @" "];
    NSString *longest = nil;
    for(NSString *str in words) {
        if (longest == nil || [str length] > [longest length]) {
            longest = str;
        } 
    }
    int currentFontSize = [self.exerciseNameLabel font].pointSize;
    CGSize textSize = [longest sizeWithAttributes:@{NSFontAttributeName:[self.exerciseNameLabel font]}];
    CGFloat strikeWidth = textSize.width;
    
    while(strikeWidth > self.bounds.size.width - 20) {
        currentFontSize--;
        [self.exerciseNameLabel setFont: [self.exerciseNameLabel.font fontWithSize: currentFontSize]];
        textSize = [longest sizeWithAttributes:@{NSFontAttributeName:[self.exerciseNameLabel font]}];
        strikeWidth = textSize.width;
    }
}

- (void)setupImage {
    //setup image animation stuff
    NSMutableArray *mutableImageArray = [[NSMutableArray alloc] init];
    NSMutableArray *mutableImageArray2 = [[NSMutableArray alloc] init];
    Exercise *exercise = self.exerciseMetaMapping.exercise;
    
    [mutableImageArray addObjectsFromArray:[exercise.images array]];
    
    if (mutableImageArray.count <= 7) //non-symmetric exercises should not be reverted
    {
        [mutableImageArray addObjectsFromArray:[[[exercise.images array] reverseObjectEnumerator] allObjects]];
    }
    
    for (Images *image in mutableImageArray)
    {
        UIImage *exerciseImage = [UIImage imageWithData:image.image];
        [mutableImageArray2 addObject:exerciseImage];
    }
    
    self.exerciseImageView.animationImages = [NSArray arrayWithArray:[[mutableImageArray2 objectEnumerator] allObjects]];
    self.exerciseImageView.animationRepeatCount = 1;
    self.exerciseImageView.animationDuration = 0.3*self.exerciseImageView.animationImages.count;
    self.exerciseImageView.image = self.exerciseImageView.animationImages[0];
    [self bringSubviewToFront:self.playButton];
}

-(void)dismissBlur {
    if(self.isBlurred) {
        [UIView animateWithDuration:0.3 animations:^{
            self.effectView.alpha = 0.0;
            self.playButton.hidden = NO;
            self.detailsView.hidden = YES;
            self.showHideButton.alpha = 1.0;
        }];
        self.isBlurred = NO;
    }
    
    self.playButton.userInteractionEnabled = YES;
    self.playButton.hidden = NO;
    self.showHideButton.hidden = NO;
}

- (IBAction)playButtonPressed:(UIButton *)sender
{
    self.showHideButton.hidden = YES;
    sender.userInteractionEnabled = NO;
    sender.hidden = YES;
    [self.exerciseImageView startAnimating];
    [self performSelector:@selector(didFinishAnimatingImageView:)
               withObject:sender
               afterDelay:self.exerciseImageView.animationDuration];
}

- (void)didFinishAnimatingImageView:(UIButton *)sender
{
    sender.userInteractionEnabled = YES;
    sender.hidden = NO;
    self.showHideButton.hidden = NO;
}

- (IBAction)changeVisibilityOfBlurView:(id)sender {
    
    if(!self.isBlurred) {
        [UIView animateWithDuration:0.3 animations:^{
            self.effectView.alpha = 1.0;
            self.playButton.hidden = YES;
            self.detailsView.hidden = NO;
            self.showHideButton.alpha = 0.2;
        }];
        self.isBlurred = YES;
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.effectView.alpha = 0.0;
            self.playButton.hidden = NO;
            self.detailsView.hidden = YES;
            self.showHideButton.alpha = 1.0;
        }];
        self.isBlurred = NO;
    }


}

- (IBAction)showDetails:(id)sender {
    [self.detailsDelegate showDetailsForExerciseMetaMapping:self.exerciseMetaMapping];
}
@end
