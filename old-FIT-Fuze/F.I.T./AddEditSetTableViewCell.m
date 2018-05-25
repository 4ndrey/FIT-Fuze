//
//  AddEditSetTableViewCell.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 22/05/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import "AddEditSetTableViewCell.h"
#import "FIT-Swift.h"
#import "SettingsViewController.h"

@interface AddEditSetTableViewCell() <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *kgOrLbsTextField;
@property (weak, nonatomic) IBOutlet UITextField *repsTextField;
@property (weak, nonatomic) IBOutlet UILabel *kgOrLbsLabel;
@property (weak, nonatomic) IBOutlet UILabel *exerciseNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *exerciseImageView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation AddEditSetTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setActive {
    if(self.kgOrLbsTextField.text.length != 0 && self.repsTextField.text.length == 0) {
        [self.repsTextField becomeFirstResponder];
    } else {
        [self.kgOrLbsTextField becomeFirstResponder];
    }
}

- (int)weight {
    return [self.kgOrLbsTextField.text intValue];
}

- (int)repetitions {
    return [self.repsTextField.text intValue];
}
- (BOOL)isSomethingMissing {
    return (self.kgOrLbsTextField.text.length == 0 || self.repsTextField.text.length == 0);
}

- (void)setupWithExerciseMetaMappings:(ExerciseMetaMapping *)exerciseMetaMapping withSetIndex:(int)setIndex {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    NSString *kgOrLbls = [[sharedDefaults objectForKey:kilogrammChoosenKey] boolValue] ? NSLocalizedString(@"kg", nil) : NSLocalizedString(@"lbs", nil);
    self.kgOrLbsLabel.text = kgOrLbls;
    
    self.exerciseMetaMapping = exerciseMetaMapping;
    ExerciseMeta *exerciseMeta = self.exerciseMetaMapping.exerciseMeta;
    
    if(setIndex >= 0) {
        WorkoutSet *exerciseSet = [exerciseMeta.sets array][(int)setIndex];
        self.kgOrLbsTextField.text = [NSString stringWithFormat:@"%@", exerciseSet.convertedWeight];
        self.repsTextField.text = [NSString stringWithFormat:@"%@", exerciseSet.repetitions];
    } else {
        self.kgOrLbsTextField.placeholder = @"25";
        self.repsTextField.placeholder = @"8";
    }
    
    NSMutableArray *mutableImageArray = [[NSMutableArray alloc] init];
    NSMutableArray *mutableImageArray2 = [[NSMutableArray alloc] init];
    
    Exercise *exercise = exerciseMetaMapping.exercise;
    
    self.exerciseNameLabel.text = NSLocalizedString(exercise.name, nil);
    
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
    
    self.playButton.hidden = self.exerciseImageView.animationImages.count <= 1;
}

- (IBAction)playButtonPressed:(UIButton *)sender
{
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
}

@end
