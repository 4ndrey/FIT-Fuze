//
//  InitialLoadingViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 03.05.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "InitialLoadingViewController.h"
#import "FIT-Swift.h"
#import "SettingsViewController.h"
@import MagicalRecord;

@interface InitialLoadingViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIButton *goToTutorialButton;

@end

@implementation InitialLoadingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[IAPProvider sharedInstance] fetchTrainingPrograms];
    [self.activityIndicatorView startAnimating];
    self.loadingLabel.hidden = NO;
    [self.goToTutorialButton setTitle:NSLocalizedString(@"GoToTutorialButton_Title", nil) forState:UIControlStateNormal];
    [self.loadingLabel setText:NSLocalizedString(@"LoadingLabel_Label_Text", nil)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //load content if there is none
    if ([Exercise MR_findAll].count == 0)
    {
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
        [sharedDefaults setObject:@(60) forKey:restTimeKey];
        [sharedDefaults setObject:@YES forKey:kilogrammChoosenKey];
        [sharedDefaults synchronize];
        
        ContentLoader *contentLoader = [[ContentLoader alloc] init];
        [contentLoader loadData];
        
    } else {
        ContentLoader *contentLoader = [[ContentLoader alloc] init];
        [contentLoader loadMissingExercises];
        [contentLoader loadMissingPrograms];
    }
    [self.activityIndicatorView stopAnimating];
    [self performSegueWithIdentifier:@"showRootViewController" sender:nil];
}

@end
