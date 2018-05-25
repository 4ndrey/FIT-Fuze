//
//  ExercisesListViewController.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 25/06/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ExercisesListViewControllerDelegate <NSObject>

- (void)supersetChangeFinished:(NSOrderedSet *)exerciseMetaMappings;

@end

@interface ExercisesListViewController : UIViewController

@property (nonatomic, strong) NSOrderedSet *exerciseMetaMappings;
@property (nonatomic, weak) id<ExercisesListViewControllerDelegate> delegate;

@end
