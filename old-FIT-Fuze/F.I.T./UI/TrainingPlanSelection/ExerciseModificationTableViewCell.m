//
//  ExerciseModificationTableViewCell.m
//  F.I.T.
//
//  Created by Felix Belau on 04.04.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "ExerciseModificationTableViewCell.h"

@implementation ExerciseModificationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index
{
    self.exerciseSetCollectionView.dataSource = dataSourceDelegate;
    self.exerciseSetCollectionView.delegate = dataSourceDelegate;
    self.exerciseSetCollectionView.tag = index;
    
    [self.exerciseSetCollectionView reloadData];
}


@end
