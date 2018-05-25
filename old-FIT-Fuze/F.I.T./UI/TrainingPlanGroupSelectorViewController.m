//
//  TrainingPlanGroupSelectorViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 08.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "TrainingPlanGroupSelectorViewController.h"
#import "TrainingPlanGroupTableViewCell.h"
#import "TrainingPlansSelectorViewController.h"

@interface TrainingPlanGroupSelectorViewController ()

@property (nonatomic, strong) NSArray *tableViewModel;

@end

@implementation TrainingPlanGroupSelectorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"TrainingPlanModeSelection_NavBar_Title", nil);
    self.tableViewModel = @[NSLocalizedString(@"FitTrainingPlans_Label_Text", nil),NSLocalizedString(@"CustomTrainingPlans_Label_Text", nil)];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableViewModel.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"groupSelectionCell";
    
    TrainingPlanGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.titleLabel.text = self.tableViewModel[indexPath.row];
    
    if(indexPath.row == 0)
    {
        BOOL coachTutorialMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowNewPlansBanner-v121"];
        if (!coachTutorialMarksShown)
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ShowNewPlansBanner-v121"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            cell.hotStuffLabel.text = NSLocalizedString(@"New!", nil);
            cell.hotStuffLabel.hidden = NO;
        }
        cell.titleImageView.image = [UIImage imageNamed:@"default_fit"];
    } else {
        cell.titleImageView.image = [UIImage imageNamed:@"default_image"];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0)
    {
        [self performSegueWithIdentifier:@"showFitPlans" sender:nil];
    }
    else if (indexPath.row == 1)
    {
        [self performSegueWithIdentifier:@"showCustomTrainingPlanSelection" sender:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}


@end
