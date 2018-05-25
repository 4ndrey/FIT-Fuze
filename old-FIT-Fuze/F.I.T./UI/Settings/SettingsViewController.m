//
//  SettingsViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 17.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIColor+FIT.h"
#import "FIT-Swift.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+RESideMenu.h"

@interface SettingsViewController () <IAPProviderDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *restorePurchasesButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *restTimerLabel;
@property (weak, nonatomic) IBOutlet UILabel *restTimeLabel;
@property (nonatomic) NSInteger restTime;

@end

@implementation SettingsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"SettingsViewControllerNavBar_title", nil);
    [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:20 weight:UIFontWeightLight], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    self.restorePurchasesButton.layer.cornerRadius = 4.0f;
    self.restorePurchasesButton.layer.borderColor = [UIColor mainColor].CGColor;
    self.restorePurchasesButton.layer.borderWidth = 1.0f;
    [self.restorePurchasesButton setTitle:NSLocalizedString(@"RestorePurchases_Button_Title", nil) forState:UIControlStateNormal];
    self.restTimeLabel.text = NSLocalizedString(@"RestTime_Label_Text", nil);
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    self.restTime = [[sharedDefaults objectForKey:restTimeKey] integerValue] ? : 60;
    self.segmentedControl.selectedSegmentIndex = [[sharedDefaults objectForKey:kilogrammChoosenKey] boolValue] ? 0 : 1;
    [self.segmentedControl setTitle:NSLocalizedString(@"kg", nil) forSegmentAtIndex:0];
    [self.segmentedControl setTitle:NSLocalizedString(@"lbs-full", nil) forSegmentAtIndex:1];

    [self updateRestTimerLabel];
    [self setupIndicatorView];
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setFrame:CGRectMake(0.0f, 0.0f, 27.0f, 19.0f)];
    [menuButton setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [menuButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    [menuButton setImage:[UIImage imageNamed:@"list-menu"] forState:UIControlStateNormal];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = button;
}

#pragma mark - Internal

- (void)setupIndicatorView
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.hidden = YES;
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    self.navigationItem.rightBarButtonItem = activityItem;
}

- (void)updateRestTimerLabel
{
    double seconds = fmod(self.restTime, 60.0);
    double minutes = fmod(trunc(self.restTime / 60.0), 60.0);
    self.restTimerLabel.text = [NSString stringWithFormat:@"%01.0f:%02.0f", minutes, seconds];
}

#pragma mark - IBActions

- (IBAction)restorePurchases:(id)sender
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    [IAPProvider sharedInstance].delegate = self;
    [[IAPProvider sharedInstance] restorePurchasedTrainingPrograms];
}

- (IBAction)increaseRestTime:(id)sender
{
    self.restTime += 15;
    [self updateDefaults];
    [self updateRestTimerLabel];
}

- (IBAction)decreaseRestTime:(id)sender
{
    self.restTime -= 15;
    if (self.restTime < 0) {
        self.restTime = 0;
    }
    [self updateDefaults];
    [self updateRestTimerLabel];
}

- (IBAction)weightValueChanged:(UISegmentedControl *)sender
{
    BOOL kilogrammChoosen = sender.selectedSegmentIndex == 0;
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    [sharedDefaults setObject:@(kilogrammChoosen) forKey:kilogrammChoosenKey];
}

- (void)updateDefaults
{
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    [sharedDefaults setObject:@(60) forKey:restTimeKey];
    [sharedDefaults setObject:@(self.restTime) forKey:restTimeKey];
    [sharedDefaults synchronize];
}

#pragma mark - IAPProviderDelegate

- (void)transactionSuccessful{}
- (void)transactionFailed{}
- (void)fetchingFinished{}

- (void)restoreTransactionsFinished
{
    [self.activityIndicator stopAnimating];
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertView_Success_Title", nil) message:NSLocalizedString(@"AlertView_RestoreSuccess_Message",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"AlertView_OK_Title", nil) otherButtonTitles:nil] show];
}

- (void)restoreTransactionsFailed
{
    [self.activityIndicator stopAnimating];
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertView_Failure_Title", nil) message:NSLocalizedString(@"AlertView_RestoreFailure_Message",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"AlertView_OK_Title", nil) otherButtonTitles:nil] show];
}


@end
