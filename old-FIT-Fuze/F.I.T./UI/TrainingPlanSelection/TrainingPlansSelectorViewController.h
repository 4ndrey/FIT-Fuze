//
//  TrainingPlansSelectorViewController.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 21/02/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrainingPlansSelectorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *trainingPrograms;

@end
