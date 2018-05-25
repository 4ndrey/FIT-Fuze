//
//  EditSetActionSheetPickerDelegate.m
//  F.I.T.
//
//  Created by Felix Belau on 14.04.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "EditSetActionSheetPickerDelegate.h"
#import "SettingsViewController.h"

@implementation EditSetActionSheetPickerDelegate

- (id)init
{
    if (self = [super init])
    {
        
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
        BOOL kilogrammChoosen = [[sharedDefaults objectForKey:kilogrammChoosenKey] boolValue];
        
        int minKG = 0;
        int maxKG = 250;
        
        NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:maxKG];
        NSMutableArray *arr1 = [[NSMutableArray alloc] initWithCapacity:maxKG];

        for (int i=minKG; i<=maxKG; i++)
        {
            [arr addObject:[NSString stringWithFormat:@"%i",i]];
            int weight = kilogrammChoosen ? i : ((int)ceil(i*2.205));
            [arr1 addObject:[NSString stringWithFormat:@"%i",weight]];
        }
        
        NSMutableArray *arr2 = [[NSMutableArray alloc] initWithCapacity:50];
        for (int i=1; i<51; i++)
        {
            [arr2 addObject:[NSString stringWithFormat:@"%i",i]];
        }
        weights = [arr copy];
        repetitions = [arr2 copy];
        convertedWeights = [arr1 copy];
    }
    
    return self;
}

#pragma mark - ActionSheetCustomPickerDelegate Optional's

- (void)configurePickerView:(UIPickerView *)pickerView
{
    // Override default and hide selection indicator
    pickerView.showsSelectionIndicator = NO;
}

- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin
{
    _onActionSheetDone(actionSheetPicker, [self.selectedWeight integerValue], [self.selectedRepetitions integerValue]);
}

- (void)actionSheetPickerDidCancel:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin
{
    if (self.cancelButtonActsAsDelete)
    {
        _onActionSheetDelete(actionSheetPicker);
    }
}

#pragma mark - UIPickerViewDataSource Implementation

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView 
{ 
    return 2; 
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{ 

    switch (component)
    {
        case 0: return [weights count];
        case 1: return [repetitions count];
        default:break;
    }
    
    return 0;
}

#pragma mark UIPickerViewDelegate Implementation

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component)
    {
        case 0: return 60.0f;
        case 1: return 260.0f;
        default:break;
    }
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component)
    {
        case 0: return convertedWeights[(NSUInteger) row];
        case 1: return repetitions[(NSUInteger) row];
        default:break;
    }
    
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
            self.selectedWeight = weights[(NSUInteger) row];
            return;
            
        case 1:
            self.selectedRepetitions = repetitions[(NSUInteger) row];
            return;
            
        default:break;
    }
}

@end
