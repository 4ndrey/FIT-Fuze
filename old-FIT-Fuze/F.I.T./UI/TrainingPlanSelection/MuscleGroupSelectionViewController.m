//
//  TrainingPlanMuscleGroupViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 15.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "MuscleGroupSelectionViewController.h"
#import "MuscleGroupTableViewCell.h"
#import "UIViewController+RESideMenu.h"
#import "UIColor+FIT.h"

@interface MuscleGroupSelectionViewController ()

@property (nonatomic, strong) NSArray *localizedMuscleGroups;
@property (nonatomic, strong) NSArray *musleGroups;
@property (nonatomic, strong) NSArray *musleGroupIcons;
@property (nonatomic, strong) NSString *selectedType;

@end

@implementation MuscleGroupSelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"MuscleGroupSelection_Navbar_Title", nil);
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"createModeON"]) {
        self.navigationController.navigationBar.tintColor = [UIColor editColor];
    }

    self.localizedMuscleGroups = @[NSLocalizedString(@"Abs_Label_Text", nil),NSLocalizedString(@"Arms_Label_Text", nil),NSLocalizedString(@"Back_Label_Text", nil),NSLocalizedString(@"Chest_Label_Text", nil),NSLocalizedString(@"Legs_Label_Text", nil),NSLocalizedString(@"Shoulders_Label_Text", nil)];
    self.musleGroups = @[@"Abs",@"Arms",@"Back",@"Chest",@"Legs",@"Shoulders"];
    self.musleGroupIcons = @[@"abs-icon",@"arms-icon",@"back-icon",@"chest-icon",@"legs-icon",@"shoulders-icon"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if (!self.exercisesAreSelectable)
    {
        //replace back button with side menu button
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setFrame:CGRectMake(0.0f, 0.0f, 27.0f, 19.0f)];
        [menuButton setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [menuButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
        [menuButton setImage:[UIImage imageNamed:@"list-menu"] forState:UIControlStateNormal];
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
        self.navigationItem.leftBarButtonItem = button;
        
        //hide multiple selectionbutton
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
        [closeButton setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [closeButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"createModeON"]) {
            [closeButton setImage:[UIImage imageNamed:@"close_green"] forState:UIControlStateNormal];
        } else {
            [closeButton setImage:[UIImage imageNamed:@"close_blue"] forState:UIControlStateNormal];
        }
        UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
        self.navigationItem.leftBarButtonItem = closeBarButton;
    }
}

- (void)showSupersetHint
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:NSLocalizedString(@"Superset_Hint_Title", nil)
                                  message:NSLocalizedString(@"Superset_Hint_Alert", nil)
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"AlertView_OK_Title", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)closeSelf
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddExerciseModalViewControllerDismissed" object:nil];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return self.musleGroups.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return NSLocalizedString(@"MuscleGroupNoSeperation_TableView_Header", nil);
    }
    else
    {
        return NSLocalizedString(@"MuscleGroupSeperation_TableView_Header", nil);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"musleGroupCellIdentifier";
    MuscleGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
 
    if (indexPath.section == 0)
    {
        cell.titleLabel.text = NSLocalizedString(@"AllExercises_TableViewCell_Text", nil);
        cell.muscleGroupImageView.image = [UIImage imageNamed:@"body-icon"];
    }
    else
    {
        cell.titleLabel.text = self.localizedMuscleGroups[indexPath.row];
        cell.muscleGroupImageView.image = [UIImage imageNamed:self.musleGroupIcons[indexPath.row]];
    }
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        self.selectedType = @"all";
    }
    else
    {
        self.selectedType = [self.musleGroups[indexPath.row] lowercaseString];
    }
    
    [self performSegueWithIdentifier:@"showExerciseSelection" sender:nil];
}

#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showExerciseSelection"])
    {
        ExerciseSelectionTableViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.exercisesAreSelectable = self.exercisesAreSelectable;
        destinationViewController.isSuperset = self.isSuperset;
        destinationViewController.workout = self.workout;
        destinationViewController.exerciseType = self.selectedType;
        destinationViewController.delegate = self.delegate;
    }

}


@end
