//
//  AlreadyStartedNotificationInterfaceController.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 25/08/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import "AlreadyStartedNotificationInterfaceController.h"

@interface AlreadyStartedNotificationInterfaceController ()
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *explanationLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceButton *continueButton;
@property (strong, nonatomic) IBOutlet WKInterfaceButton *restartButton;

@end

@implementation AlreadyStartedNotificationInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (IBAction)continueButtonTapped {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ContinueWorkout"];
    [self dismissController];
}
- (IBAction)restartButtonTapped {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ResetWorkout"];
    [self dismissController];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



