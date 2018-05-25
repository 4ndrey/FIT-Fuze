//
//  TopWorkoutCollectionViewCell.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 02/06/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIT-Swift.h"
#import "TopWorkoutViewControllerDelegate.h"

@interface TopWorkoutCollectionViewCell : UICollectionViewCell

-(void)setupWithExerciseMetaMapping:(ExerciseMetaMapping *)mapping color:(UIColor *)color;
-(void)dismissBlur;

@property (weak, nonatomic) id<TopWorkoutViewControllerDelegate> detailsDelegate;

@end
