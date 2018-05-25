//
//  AddEditSetTableViewCell.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 22/05/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExerciseMetaMapping;

@interface AddEditSetTableViewCell : UITableViewCell

@property (nonatomic, assign) int weight;
@property (nonatomic, assign) int repetitions;
@property (nonatomic, retain) ExerciseMetaMapping *exerciseMetaMapping;

- (void)setupWithExerciseMetaMappings:(ExerciseMetaMapping *)exerciseMetaMapping withSetIndex:(int)setIndex;
- (void)setActive;
- (BOOL)isSomethingMissing;

@end
