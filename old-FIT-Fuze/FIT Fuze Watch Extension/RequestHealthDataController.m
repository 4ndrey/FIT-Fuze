//
//  RequestHealthDataController.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 11.06.17.
//  Copyright © 2017 FIT-Team. All rights reserved.
//

#import "RequestHealthDataController.h"

@interface RequestHealthDataController ()

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *requestHealthDataLabel;
- (IBAction)okAction;

@end

@implementation RequestHealthDataController

- (void)awakeWithContext:(id)context {
    [self.requestHealthDataLabel setText:NSLocalizedString(@"requestHealthDataLabel", nil)];
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)okAction {
    [self dismissController];
}
@end



