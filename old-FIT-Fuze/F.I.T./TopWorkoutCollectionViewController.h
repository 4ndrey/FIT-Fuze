//
//  TopWorkoutCollectionViewController.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 02/06/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkoutPageViewControllerDelegate.h"
#import "TopWorkoutViewControllerDelegate.h"

@interface TopWorkoutCollectionViewController : UICollectionViewController

@property (strong, nonatomic) NSOrderedSet *exerciseMetaMappings;
@property (weak, nonatomic) id <WorkoutPageViewControllerDelegate> delegate;
@property (weak, nonatomic) id<TopWorkoutViewControllerDelegate> detailsDelegate;

@end
