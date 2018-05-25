//
//  CustomTrainingPlansSelectorViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 15.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "TrainingPlansSelectorViewController.h"
#import "CustomTwoLinesTableViewCell.h"
#import "WorkoutModificationViewController.h"
#import "TrainingPlanSelectionTableViewCell.h"
#import "FIT-Swift.h"
#import "WorkoutSelectorViewController.h"
#import "UIColor+FIT.h"

@import MagicalRecord;

@interface TrainingPlansSelectorViewController () <UITableViewDataSource, UITableViewDelegate, IAPProviderDelegate> {
    NSArray *traininPlansCollectionSummer15;
    NSArray *traininPlansCollectionAutumn15;
    NSArray *trainingProgramCollectionsNames15;
    NSDictionary *collections;
}

@property (nonatomic) TrainingProgram *trainingProgram;
@property (nonatomic, strong) NSArray *freeTrainingPrograms;
@property (nonatomic, strong) NSArray *purchasedTrainingPrograms;
@property (nonatomic, strong) NSArray *paidTrainingPrograms;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITableView *trainingProgramsTableView;
@property (nonatomic, strong) ContentProvider *contentProvider;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;

@end

@implementation TrainingPlansSelectorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.trainingProgramsTableView setContentInset:UIEdgeInsetsMake(0,0,65,0)];

    traininPlansCollectionSummer15 = @[@"trainingProgramm_2_name", @"trainingProgramm_3_name", @"trainingProgramm_5_name", @"trainingProgramm_6_name", @"trainingProgramm_7_name"];
    traininPlansCollectionAutumn15 = @[@"trainingProgramm_10_name", @"trainingProgramm_11_name", @"trainingProgramm_12_name", @"trainingProgramm_13_name"];
    trainingProgramCollectionsNames15 = @[NSLocalizedString(@"summer15", nil), NSLocalizedString(@"autumn15", nil)];
    collections = @{trainingProgramCollectionsNames15[0] : traininPlansCollectionSummer15, trainingProgramCollectionsNames15[1] : traininPlansCollectionAutumn15};
    
    self.contentProvider = [[ContentProvider alloc] init];
    [IAPProvider sharedInstance].delegate = self;
    
    self.title = NSLocalizedString(@"TrainingPlanSelection_Navbar_Title", nil);
    if ([IAPProvider sharedInstance].inAppPurchasesAllowed) {
        [self.retryButton setTitle: NSLocalizedString(@"RetryConnection_Button_Title", nil) forState:UIControlStateNormal];
        self.retryButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        self.retryButton.titleLabel.numberOfLines = 2;
        self.retryButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.retryButton.titleLabel.minimumScaleFactor = 0.5;
    } else {
        self.retryButton.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shouldGoToRoot"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldGoToRoot"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    [self setupPlans];
}

- (void)setupPlans
{
    self.freeTrainingPrograms = [self.contentProvider getFreeTrainingPrograms];
    self.purchasedTrainingPrograms = [self.contentProvider getPurchasedTrainingPrograms];
    
    NSMutableArray *tempPaidProgs = [NSMutableArray arrayWithArray: [self.contentProvider getPaidTrainingPrograms]];
    [tempPaidProgs removeObjectsInArray:self.purchasedTrainingPrograms];
    self.paidTrainingPrograms = [tempPaidProgs copy];
    
    self.bottomView.hidden = [IAPProvider sharedInstance].programsFetched;
    
    if(self.bottomView.hidden)
    {
        [self.trainingProgramsTableView setContentInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    [self.trainingProgramsTableView reloadData];
}

- (void)setupIndicatorView
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.hidden = YES;
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    self.navigationItem.rightBarButtonItem = activityItem;
}

#pragma mark - IAPProviderDelegate

- (void)fetchingFinished
{
    [self setupPlans];
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewWokrout)];
    self.navigationItem.rightBarButtonItem = activityItem;
    
    self.bottomView.hidden = [IAPProvider sharedInstance].programsFetched;
    
    if(self.bottomView.hidden)
    {
        [self.trainingProgramsTableView setContentInset:UIEdgeInsetsMake(0,0,0,0)];
    }
}

- (void)createNewWokrout
{
    [self performSegueWithIdentifier:@"createNewWorkoutSID" sender:self];
}

- (void)transactionFailed {}

- (void)transactionSuccessful {
    self.purchasedTrainingPrograms = [self.contentProvider getPurchasedTrainingPrograms];
    NSMutableArray *tempPaidProgs = [NSMutableArray arrayWithArray: [self.contentProvider getPaidTrainingPrograms]];
    [tempPaidProgs removeObjectsInArray:self.purchasedTrainingPrograms];
    self.paidTrainingPrograms = [tempPaidProgs copy];
    [self.trainingProgramsTableView reloadData];
}

- (void)restoreTransactionsFinished {
    self.purchasedTrainingPrograms = [self.contentProvider getPurchasedTrainingPrograms];
    NSMutableArray *tempPaidProgs = [NSMutableArray arrayWithArray: [self.contentProvider getPaidTrainingPrograms]];
    [tempPaidProgs removeObjectsInArray:self.purchasedTrainingPrograms];
    self.paidTrainingPrograms = [tempPaidProgs copy];
    [self.trainingProgramsTableView reloadData];
}

- (void)restoreTransactionsFailed {}

#pragma mark - IBActions

- (IBAction)createYourOwnProgramButtonPressed:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"createModeON"];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor editColor]} forState:UIControlStateNormal];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName : [UIColor editColor],
                                                           NSFontAttributeName: [UIFont systemFontOfSize:20 weight:UIFontWeightLight],
                                                           }];
    [UINavigationBar appearance].tintColor = [UIColor editColor];
    ContentProvider *contentProvider = [[ContentProvider alloc] init];
    self.trainingProgram = [contentProvider createNewUserProgram];
    [self performSegueWithIdentifier:@"showCustomWorkouts" sender:nil];
    
}

- (IBAction)retryConnectionButtonPressed:(id)sender
{
    [self setupIndicatorView];
    [IAPProvider sharedInstance].delegate = self;
    [[IAPProvider sharedInstance] fetchTrainingPrograms];
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return (self.purchasedTrainingPrograms.count > 0 ? 1 + 1 + trainingProgramCollectionsNames15.count : 1 + trainingProgramCollectionsNames15.count);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.purchasedTrainingPrograms.count > 0) {
        if (section == 0) {
            return self.freeTrainingPrograms.count;
        }
        else if (section == 1) {
            return self.purchasedTrainingPrograms.count;
        }
        else {
            NSString *key = collections.allKeys[section-2];
            NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"name IN %@", collections[key]];
            NSArray *collectionPlans = [self.paidTrainingPrograms filteredArrayUsingPredicate:sPredicate];
            return collectionPlans.count;
        }
    } else {
        if (section == 0) {
            return self.freeTrainingPrograms.count;
        }
        else {
            NSString *key = collections.allKeys[section-1];
            NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"name IN %@", collections[key]];
            NSArray *collectionPlans = [self.paidTrainingPrograms filteredArrayUsingPredicate:sPredicate];
            return collectionPlans.count;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"FreeTrainingPlans_Label_Text", nil);
    } else if (self.purchasedTrainingPrograms.count > 0) {
        if (section == 1) {
            return NSLocalizedString(@"PurchasesTrainingPlan_TableView_Header", nil);
        }
        else {
            return collections.allKeys[section-2];
        }
    } else {
        return collections.allKeys[section-1];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"trainingPlanSelectionCell";
    TrainingPlanSelectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.timeLabel.text = @"";
    
    TrainingProgram *trainingProgramm;
    
    if (indexPath.section == 1 && self.purchasedTrainingPrograms.count > 0)
    {
        trainingProgramm = self.purchasedTrainingPrograms[indexPath.row];
        cell.priceLabel.text = NSLocalizedString(@"Purchased_TableViewCell_Text", nil);
    }
    else //not purchased - either free or paid
    {
        int extra = self.purchasedTrainingPrograms.count > 0 ? 1 : 0;
        if (indexPath.section >= 1 + extra) {
            
            NSString *key = collections.allKeys[indexPath.section-1-extra];
            NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"name IN %@", collections[key]];
            NSArray *collectionPlans = [self.paidTrainingPrograms filteredArrayUsingPredicate:sPredicate];
            
            trainingProgramm = collectionPlans[indexPath.row];
            if ([IAPProvider sharedInstance].programsFetched)
            {
                cell.priceLabel.text = [[IAPProvider sharedInstance] getPrice:trainingProgramm.programId];
            }
            else if ([IAPProvider sharedInstance].inAppPurchasesAllowed)
            {
                cell.priceLabel.text = NSLocalizedString(@"NoInternet_TableViewCell_Text", nil);
            }
            else
            {
                cell.priceLabel.text = NSLocalizedString(@"In-app purchases are not allowed", nil);
                cell.priceLabel.numberOfLines = 2;
            }
        }
        else //section = 0
        {
            trainingProgramm = self.freeTrainingPrograms[indexPath.row];
            cell.priceLabel.text = @"";
        }
        
        int daysCount = trainingProgramm.trainings.count;
        NSString *timeLabelText;
        if (daysCount < 5) {
            timeLabelText = [NSString stringWithFormat:NSLocalizedString(@"Purchased_Duration_Text", nil), trainingProgramm.trainings.count];
        } else {
            timeLabelText = [NSString stringWithFormat:NSLocalizedString(@"Purchased_Duration_Text_many_days", nil), trainingProgramm.trainings.count];
        }
        cell.timeLabel.text = timeLabelText;
    }
    
    
    cell.titleLabel.text = NSLocalizedString(trainingProgramm.name,nil);
    cell.typeLabel.text = NSLocalizedString(trainingProgramm.type,nil);
    cell.trainingImageView.image = [UIImage imageWithData: ((Images *)((Exercise *)((ExerciseMetaMapping *)((Training *)trainingProgramm.trainings[0]).exerciseMetaMappings[0]).exercise).images[6]).image];
    cell.levelImageView.image = [UIImage imageNamed:trainingProgramm.level];
    cell.levelLabel.text = NSLocalizedString(trainingProgramm.level,nil);
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"createModeON"];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor mainColor]} forState:UIControlStateNormal];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName : [UIColor mainColor],
                                                           NSFontAttributeName: [UIFont systemFontOfSize:20 weight:UIFontWeightLight],
                                                           }];

    if (indexPath.section == 0) {
        self.trainingProgram = self.freeTrainingPrograms[indexPath.row];
    } else if (self.purchasedTrainingPrograms.count > 0) {
        if (indexPath.section == 1) {
            self.trainingProgram = self.purchasedTrainingPrograms[indexPath.row];
        }
        else {
            NSString *key = collections.allKeys[indexPath.section-2];
            NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"name IN %@", collections[key]];
            NSArray *collectionPlans = [self.paidTrainingPrograms filteredArrayUsingPredicate:sPredicate];
            self.trainingProgram = collectionPlans[indexPath.row];
        }
    } else {
        NSString *key = collections.allKeys[indexPath.section-1];
        NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"name IN %@", collections[key]];
        NSArray *collectionPlans = [self.paidTrainingPrograms filteredArrayUsingPredicate:sPredicate];
        self.trainingProgram = collectionPlans[indexPath.row];
    }
    
    [self performSegueWithIdentifier:@"showWorkouts" sender:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showWorkouts"])
    {
        WorkoutSelectorViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.trainingProgram = self.trainingProgram;
    }
}


@end
