//
//  NoSetsWarningInterfaceController.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 07/06/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface NoSetsWarningInterfaceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *NoSetsWarningLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *ReloadButton;
- (IBAction)reloadTrainingPlan;

@end
