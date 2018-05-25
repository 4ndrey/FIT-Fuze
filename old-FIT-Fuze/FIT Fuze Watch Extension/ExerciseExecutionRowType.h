//
//  ExerciseExecutionRowType.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 10/07/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//
#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface ExerciseExecutionRowType : NSObject

@property (assign, nonatomic) int exerciseIndex;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel* exerciseNameLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel* exerciseRepsLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel* exerciseWeightLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup* exerciseDescriptionGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *infoIcon;

@end
