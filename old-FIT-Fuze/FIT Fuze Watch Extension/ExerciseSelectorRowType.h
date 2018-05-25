//
//  ExerciseSelectorRowType.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 30/04/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface ExerciseSelectorRowType : NSObject

@property (assign, nonatomic) int exerciseIndex;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel* exerciseLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup* exerciseGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceImage* exerciseImage;

@end
