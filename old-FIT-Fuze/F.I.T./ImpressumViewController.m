//
//  ImpressumViewController.m
//  F.I.T.
//
//  Created by HeKu GmbH on 04/09/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "ImpressumViewController.h"

@interface ImpressumViewController()

@property (weak, nonatomic) IBOutlet UIButton *healthDisclaimerButton;

@end

@implementation ImpressumViewController

- (void)viewDidLoad
{
    [self.healthDisclaimerButton setTitle:NSLocalizedString(@"Health_Disclaimer_Title", nil) forState:UIControlStateNormal];
}

@end
