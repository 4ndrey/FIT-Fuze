//
//  WorkoutSelectorRowType.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 27/04/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface WorkoutSelectorRowType : NSObject

@property (assign, nonatomic) int workoutIndex;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel* workoutLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel* doneOfLabel;

@end
