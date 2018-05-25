//
//  EditSetActionSheetPickerDelegate.h
//  F.I.T.
//
//  Created by Felix Belau on 14.04.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionSheetPicker.h"

typedef void(^ActionSheetDoneBlock)(AbstractActionSheetPicker *picker, NSInteger selectedWeight, NSInteger selectedRepetition);
typedef void(^ActionSheetDeleteBlock)(AbstractActionSheetPicker *picker);

@interface EditSetActionSheetPickerDelegate : NSObject <ActionSheetCustomPickerDelegate>
{
    NSArray *weights;
    NSArray *repetitions;
    NSArray *convertedWeights;
}

@property (nonatomic, strong) NSString *selectedWeight;
@property (nonatomic, strong) NSString *selectedRepetitions;

@property (nonatomic, copy) ActionSheetDoneBlock onActionSheetDone;
@property (nonatomic, copy) ActionSheetDeleteBlock onActionSheetDelete;
@property (nonatomic) BOOL cancelButtonActsAsDelete;

@end
