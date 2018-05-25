//
//  WorkoutViewController.h
//  F.I.T.
//
//  Created by Felix Belau on 24.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkoutPageViewControllerDelegate.h"
#import "FIT-Swift.h"

@interface WorkoutViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSOrderedSet *exerciseMetaMappings;
@property (nonatomic) NSUInteger pageIndex;
@property (weak, nonatomic) id <WorkoutPageViewControllerDelegate> delegate;

@end
