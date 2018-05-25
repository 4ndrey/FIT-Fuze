//
//  WorkoutExecutionSideMenuCellTableViewCell.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 17/07/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkoutExecutionSideMenuCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *exerciseProgressImage;
@property (weak, nonatomic) IBOutlet UIView *leftLineSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *withNextSign;
@property (weak, nonatomic) IBOutlet UIView *rightLineSeparator;
@property (weak, nonatomic) IBOutlet UILabel *exerciseName;
@property (assign, nonatomic) BOOL withNext;
@end
