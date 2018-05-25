//
//  ExerciseModificationTableViewCell.h
//  F.I.T.
//
//  Created by Felix Belau on 04.04.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExerciseModificationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UICollectionView *exerciseSetCollectionView;

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index;

@end
