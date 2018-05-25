//
//  CustomTrainingPlansSelectorViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 15.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "CustomTrainingPlansSelectorViewController.h"
#import "CustomTwoLinesTableViewCell.h"
#import "WorkoutModificationViewController.h"
#import "FIT-Swift.h"
#import "UIColor+FIT.h"

@import MagicalRecord;

@interface CustomTrainingPlansSelectorViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) TrainingProgram *trainingProgram;
@property (nonatomic, strong) NSArray *trainingPrograms;
@property (weak, nonatomic) IBOutlet UITableView *trainingProgramsTableView;
@property (weak, nonatomic) IBOutlet UIButton *addNewPlanButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBarButton;
@property (nonatomic) BOOL isInEditingMode;

@end

@implementation CustomTrainingPlansSelectorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"TrainingPlanSelection_Navbar_Title", nil);
    [self.editBarButton setTitle:NSLocalizedString(@"Edit_Button_Title", nil)];
    [self.trainingProgramsTableView setContentInset:UIEdgeInsetsMake(0,0,65,0)];
    [self.addNewPlanButton setTitle:NSLocalizedString(@"AddNewPlan_Button_Title", nil) forState:UIControlStateNormal];
    self.addNewPlanButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.addNewPlanButton.titleLabel.numberOfLines = 2;
    self.addNewPlanButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.addNewPlanButton.titleLabel.minimumScaleFactor = 0.5;
    self.addNewPlanButton.tintColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    ContentProvider *contentProvider = [[ContentProvider alloc] init];
    self.trainingPrograms = [contentProvider getUserTrainingPrograms];
    [self.trainingProgramsTableView reloadData];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shouldGoToRoot"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - IBActions

- (IBAction)editButtonPressed:(id)sender
{
    self.isInEditingMode = !self.isInEditingMode;
    [sender setTitle:(self.isInEditingMode ? NSLocalizedString(@"Done_Button_Title", nil) : NSLocalizedString(@"Edit_Button_Title", nil))];
    [self.trainingProgramsTableView setEditing:self.isInEditingMode animated:YES];
    
}

- (IBAction)createYourOwnProgramButtonPressed:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"createModeON"];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor editColor]} forState:UIControlStateNormal];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName : [UIColor editColor],
                                                           NSFontAttributeName: [UIFont systemFontOfSize:20 weight:UIFontWeightLight],
                                                           }];
    ContentProvider *contentProvider = [[ContentProvider alloc] init];
    self.trainingProgram = [contentProvider createNewUserProgram];
    [self performSegueWithIdentifier:@"showCustomWorkouts" sender:nil];
    
}


#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.trainingPrograms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"CustomTrainingPlanCell";
    CustomTwoLinesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    TrainingProgram *trainingProgramm = self.trainingPrograms[indexPath.row];
    cell.customTitleLabel.text = trainingProgramm.name;
    cell.customSubtitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"WorkoutCount_Label_Text", nil),trainingProgramm.trainings.count];
    
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
    
    self.trainingProgram = self.trainingPrograms[indexPath.row];
    [self performSegueWithIdentifier:@"showCustomWorkouts" sender:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSURL *currentPlanUrl = [[NSUserDefaults standardUserDefaults] URLForKey:@"currentTrainingplan"];
        TrainingProgram *trainingProgramm = self.trainingPrograms[indexPath.row];
        if([currentPlanUrl isEqual:trainingProgramm.objectID.URIRepresentation])
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"currentTrainingplan"];
        }
        
        [[NSManagedObjectContext MR_defaultContext] deleteObject:trainingProgramm];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        ContentProvider *contentProvider = [[ContentProvider alloc] init];
        self.trainingPrograms = [contentProvider getUserTrainingPrograms];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showCustomWorkouts"])
    {
        UINavigationController *destinationNavController = [segue destinationViewController];
        WorkoutModificationViewController *destinationViewController = destinationNavController.viewControllers[0];
        destinationViewController.trainingProgram = self.trainingProgram;
    }
}


@end
