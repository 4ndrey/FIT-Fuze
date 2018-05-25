//
//  SettingsInterfaceController.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 07/04/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "SettingsInterfaceController.h"
#import "ConnectivityManager.h"

@interface SettingsInterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restTimeNameLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restTimeLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceSlider *restTimeSlider;
@property (strong, nonatomic) IBOutlet WKInterfacePicker *restTimePicker;
@property (strong, nonatomic) NSNumber *restTimeNumber;
@end


@implementation SettingsInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    ConnectivityManager *connectivityManager = [ConnectivityManager sharedManager];
    NSDictionary *trainingPlanInfo = connectivityManager.trainingPlanDictionary;
    NSNumber *restTime = [trainingPlanInfo objectForKey:@"restTimeKey"];
    
    [self.restTimeSlider setValue:restTime.floatValue];
    [self.restTimeLabel setText:[NSString stringWithFormat:@"%@s", restTime]];
    [self.restTimeNameLabel setText:NSLocalizedString(@"restTimerLabel", nil)];
    // Configure interface objects here.
    
    NSMutableArray *items = [NSMutableArray new];

    for( int i = 0; i <= 120; i = i+5) {
        WKPickerItem *pickerItem = [[WKPickerItem alloc] init];
        pickerItem.title = [NSString stringWithFormat:@"%d", i];
        [items addObject:pickerItem];
    }
    
    [self.restTimePicker setItems:items];
    [self.restTimePicker setSelectedItemIndex:restTime.intValue/5];
}

- (IBAction)volumeSliderAction:(float)value {
    ConnectivityManager *connectivityManager = [ConnectivityManager sharedManager];
    NSMutableDictionary *trainingPlanInfo = [connectivityManager.trainingPlanDictionary mutableCopy];
    [trainingPlanInfo setObject:[NSNumber numberWithFloat:value] forKey:@"restTimeKey"];
    connectivityManager.trainingPlanDictionary = [trainingPlanInfo copy];
    
    [self.restTimeLabel setText:[NSString stringWithFormat:@"%@s", @(value)]];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self.restTimePicker focus];
}

- (IBAction)pickerValueChanged:(NSInteger)value {
    [self.restTimeSlider setValue:value*5];
    [self volumeSliderAction:value*5];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



