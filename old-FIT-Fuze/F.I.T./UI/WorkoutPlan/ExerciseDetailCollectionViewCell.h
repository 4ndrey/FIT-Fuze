//
//  ExerciseDetailCollectionViewCell.h
//  F.I.T.
//
//  Created by Felix Belau on 21.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ExerciseSuccessState)
{
    ExerciseSuccessStateEmpty,
    ExerciseStateSuccessSuccessful,
    ExerciseStateSuccessFailed,
};

@interface ExerciseDetailCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *repetitionsLabel;

@property (weak, nonatomic) IBOutlet UIView *rightVerticalSeperator;
@property (weak, nonatomic) IBOutlet UIView *leftVerticalSeperator;

@property (nonatomic) ExerciseSuccessState successState;
@property (nonatomic) BOOL active;


- (void)setupWithExerciseMetaMappings:(NSOrderedSet *)exerciseMetaMappings withIndexPath:(NSIndexPath *)indexPath isActive:(BOOL)isActive;

@end
