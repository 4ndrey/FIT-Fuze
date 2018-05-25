//
//  ExerciseDetailCollectionViewCell.m
//  F.I.T.
//
//  Created by Felix Belau on 21.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "ExerciseDetailCollectionViewCell.h"
#import "UIColor+FIT.h"
#import "FIT-Swift.h"
#import <QuartzCore/QuartzCore.h>
#import "SettingsViewController.h"

static NSString *labelFontNameActive = @"HelveticaNeue";
static NSString *labelFontNameUnactive = @"HelveticaNeue-Thin";

@interface ExerciseDetailCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *exerciseSuccessImageView;
@property (weak, nonatomic) IBOutlet UIView *labelContainer;
@property (weak, nonatomic) IBOutlet UIView *activeSetBackground;
@property (weak, nonatomic) IBOutlet UIView *background;

@end

@implementation ExerciseDetailCollectionViewCell

#pragma mark - lifecycle

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.labelContainer.layer.borderColor = [UIColor mainColor].CGColor;
    self.activeSetBackground.hidden = NO;
    self.background.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Helpers

- (void)setFontForLabel:(UILabel *)label forActive:(BOOL)active
{
    UIFont *currentFont = label.font;
    UIFont *newFont = active ? [UIFont fontWithName:labelFontNameActive size:currentFont.pointSize] : [UIFont fontWithName:labelFontNameUnactive size:currentFont.pointSize];
    label.font = newFont;
}

#pragma mark - Setters

- (void)setActive:(BOOL)active
{
    _active = active;
    self.activeSetBackground.hidden = !active;
    self.background.backgroundColor = (active ? [UIColor colorWithRed:239/255.0f green:251/255.0f blue:255/255.0f alpha:1] : [UIColor whiteColor]);
    [self setFontForLabel:self.weightLabel forActive:_active];
    [self setFontForLabel:self.repetitionsLabel forActive:_active];
}

- (void)setSuccessState:(ExerciseSuccessState)successState
{
    _successState = successState;
    switch (successState)
    {
        case ExerciseSuccessStateEmpty:
            self.exerciseSuccessImageView.hidden = YES;
            break;
        case ExerciseStateSuccessSuccessful:
            self.exerciseSuccessImageView.hidden = NO;
            self.exerciseSuccessImageView.image = [UIImage imageNamed:@"set-succeed"];
            break;
        case ExerciseStateSuccessFailed:
            self.exerciseSuccessImageView.hidden = NO;
            self.exerciseSuccessImageView.image = [UIImage imageNamed:@"set-failed"];
        default:
            break;
    }
}

- (void)setupWithExerciseMetaMappings:(NSOrderedSet *)exerciseMetaMappings withIndexPath:(NSIndexPath *)indexPath isActive:(BOOL)isActive {
    for(UIView *subview in self.subviews) {
        if (subview.tag == 1) {
            [subview removeFromSuperview];
        }
    }
    
    NSArray *colorsArray = [UIColor arrayOfWorkoutColors];
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    NSString *kgOrLbls = [[sharedDefaults objectForKey:kilogrammChoosenKey] boolValue] ? NSLocalizedString(@"kg", nil) : NSLocalizedString(@"lbs", nil);
    
    if(exerciseMetaMappings.count == 1) {
        ExerciseMetaMapping *exerciseMetaMapping = exerciseMetaMappings[0];
        ExerciseMeta *exerciseMeta = exerciseMetaMapping.exerciseMeta;
        
        NSInteger index = indexPath.row;
        WorkoutSet *exerciseSet = [exerciseMeta.sets array][index];
        
        self.weightLabel.hidden = NO;
        self.repetitionsLabel.hidden = NO;
        
        self.numberLabel.text = [NSString stringWithFormat:@"%ld/%ld", index+1, (long)([exerciseMeta.sets array].count)];
        self.weightLabel.text = [NSString stringWithFormat:@"%@%@", exerciseSet.convertedWeight,kgOrLbls];
        self.repetitionsLabel.text = [NSString stringWithFormat:@"×%@",exerciseSet.repetitions];
    } else {
        ExerciseMetaMapping *mainExerciseMetaMapping = exerciseMetaMappings[0];
        ExerciseMeta *mainExerciseMeta = mainExerciseMetaMapping.exerciseMeta;
        NSInteger index = indexPath.row;
        self.numberLabel.text = [NSString stringWithFormat:@"%ld/%ld", index+1, (long)([mainExerciseMeta.sets array].count)];
        self.weightLabel.hidden = YES;
        self.repetitionsLabel.hidden = YES;
        
        for(int i = 0; i < exerciseMetaMappings.count; i++) {
            ExerciseMetaMapping *exerciseMetaMapping = exerciseMetaMappings[i];
            ExerciseMeta *exerciseMeta = exerciseMetaMapping.exerciseMeta;
            WorkoutSet *exerciseSet = [exerciseMeta.sets array][index];
            NSString *weightText = [NSString stringWithFormat:@"%@%@", exerciseSet.convertedWeight, kgOrLbls];
            NSString *repsText = [NSString stringWithFormat:@"×%@", exerciseSet.repetitions];
            
            UILabel *weightLabel = [[UILabel alloc] init];
            weightLabel.textAlignment = NSTextAlignmentCenter;
            weightLabel.text = weightText;
            
            UILabel *repsLabelLabel = [[UILabel alloc] init];
            repsLabelLabel.textAlignment = NSTextAlignmentCenter;
            repsLabelLabel.text = repsText;
            
            int fontSize = 24;
            int allowedHeight = (self.frame.size.height - 20)/2;
            int allowedWidth = (self.frame.size.width - 10)/exerciseMetaMappings.count;

            weightLabel.font = [UIFont systemFontOfSize:fontSize weight: isActive ? UIFontWeightRegular : UIFontWeightLight];
            weightLabel.tag = 1;
            weightLabel.numberOfLines = 1;
            weightLabel.adjustsFontSizeToFitWidth = YES;
            weightLabel.minimumScaleFactor = 0.5;
            weightLabel.frame = CGRectMake(5+allowedWidth*i+5, 10, allowedWidth-10, allowedHeight);
            weightLabel.textColor = (i%2==1) ? [UIColor grayColor] : [UIColor blackColor];
            [self addSubview:weightLabel];
            
            repsLabelLabel.font = [UIFont systemFontOfSize:fontSize weight:isActive ? UIFontWeightLight : UIFontWeightThin];
            repsLabelLabel.textColor = [UIColor mainColor];
            repsLabelLabel.tag = 1;
            repsLabelLabel.numberOfLines = 1;
            repsLabelLabel.adjustsFontSizeToFitWidth = YES;
            repsLabelLabel.minimumScaleFactor = 0.5;
            repsLabelLabel.textColor = (i%2==1) ? [UIColor editColor] : [UIColor mainColor];
            repsLabelLabel.frame = CGRectMake(5+allowedWidth*i+5, 10 + allowedHeight, allowedWidth-10, allowedHeight);
            [self addSubview:repsLabelLabel];
            
            UIView *colorMarkView = [[UIView alloc] initWithFrame:CGRectMake(5+i*allowedWidth, self.frame.size.height-2, allowedWidth-2, 2)];
            colorMarkView.backgroundColor = colorsArray[i];
            colorMarkView.tag = 1;
            [self addSubview:colorMarkView];
            
            if(i != exerciseMetaMappings.count-1) {
                UIView *whiteSeparator = [[UIView alloc] initWithFrame:CGRectMake(5+i*allowedWidth+allowedWidth-2, 5, 2, self.frame.size.height-10)];
                whiteSeparator.backgroundColor = [UIColor whiteColor];
                whiteSeparator.tag = 1;
                [self addSubview:whiteSeparator];
            }
        }
    }
    
    [self bringSubviewToFront:self.activeSetBackground];
    self.leftVerticalSeperator.hidden = indexPath.row != 0;
}

@end
