//
//  NoSetsWarningInterfaceController.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 07/06/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "NoSetsWarningInterfaceController.h"
#import "ResultsRecorder.h"

@interface NoSetsWarningInterfaceController()

@end


@implementation NoSetsWarningInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self.ReloadButton setTitle:NSLocalizedString(@"retryButton_label", nil)];
    [self.NoSetsWarningLabel setText:NSLocalizedString(@"noSetsWarning_label", nil)];
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

- (IBAction)reloadTrainingPlan {
   [WKInterfaceController reloadRootControllersWithNames:@[@"startSceneID"] contexts:nil];
}

@end



