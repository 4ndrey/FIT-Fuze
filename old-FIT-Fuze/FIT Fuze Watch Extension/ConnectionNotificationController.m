//
//  ConnectionNotificationController.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 02.04.17.
//  Copyright © 2017 FIT-Team. All rights reserved.
//

#import "ConnectionNotificationController.h"

@implementation ConnectionNotificationController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self.goToPhoneLabel setText:NSLocalizedString(@"syncHint_label", nil)];
}

@end
