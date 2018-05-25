//
//  DisclaimerViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 02.05.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "DisclaimerViewController.h"

@interface DisclaimerViewController ()

@end

@implementation DisclaimerViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - IBActions

- (IBAction)closeButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
