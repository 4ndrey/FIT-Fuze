//
//  WorkoutSelectorTableViewCellDelegate.h
//  F.I.T.
//
//  Created by Felix Belau on 08.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WorkoutSelectorTableViewCell;

@protocol WorkoutSelectorTableViewCellDelegate <NSObject>

- (void)detailButtonPressedTableViewCell:(UITableViewCell *)cell;

@optional

- (void)repetitionsButtonPressedTableViewCell:(UITableViewCell *)cell;

@end
