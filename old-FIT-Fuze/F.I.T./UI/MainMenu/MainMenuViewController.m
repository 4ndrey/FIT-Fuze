//
//  MainMenuViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 17.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "MainMenuViewController.h"
#import "MainMenuTableViewCell.h"
#import "FIT-Swift.h"
#import "NSManagedObjectContext+FetchedObjectFromURI.h"
#import <Twitter/Twitter.h>
#import "UIColor+FIT.h"
#import "MuscleGroupSelectionViewController.h"

#import "KAProgressLabel.h"
@import MagicalRecord;


@interface MainMenuViewController ()

@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (weak, nonatomic) IBOutlet UILabel *currentTrainingPlanNameLabel;
@property (weak, nonatomic) IBOutlet KAProgressLabel *trainingPlanProgressLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTrainingPlanLabel;

@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) NSArray *icons;
@property (nonatomic, strong) TrainingProgram *currentTrainingProgram;
@property (nonatomic, strong) NSIndexPath* currentlyChosenCellPath;

@end

@implementation MainMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentlyChosenCellPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.currentTrainingPlanLabel.text = NSLocalizedString(@"CurrentTrainingPlan_Label_Text", nil);

    self.menuTitles = @[NSLocalizedString(@"Trainingplans_Label_Text", nil),NSLocalizedString(@"Exercises_Label_Text", nil),NSLocalizedString(@"Statistics_Label_Text", nil),NSLocalizedString(@"Settings_Label_Text", nil),NSLocalizedString(@"Help_Label_Text", nil)];
    self.icons = @[@"TrainingPlansIcon",@"ExercisesIcon",@"StatisticsIcon",@"SettingsIcon",@"HelpIcon"];
    [self.menuTableView setSeparatorInset:UIEdgeInsetsZero];
    
    [self setupRoundedProgressLabel];
}

- (void)updateUserInterface
{
    NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];
    self.currentTrainingProgram = (TrainingProgram *)[moc objectWithURI:[[NSUserDefaults standardUserDefaults] URLForKey:@"currentTrainingplan"]];
    self.currentTrainingPlanNameLabel.text = NSLocalizedString(self.currentTrainingProgram.name,nil);
    
    
    [self.trainingPlanProgressLabel setProgress:[self getCurrentTrainingProgress]
                                         timing:TPPropertyAnimationTimingEaseOut
                                       duration:1.0
                                          delay:1];
    [self.menuTableView reloadData];
}

#pragma mark - Internal

- (CGFloat)getCurrentTrainingProgress
{
    if (!self.currentTrainingProgram || self.currentTrainingProgram.trainings.count == 0)
    {
        return 0;
    }
    
    CGFloat workoutProgress = 0.0f;
    for (Training *workout in self.currentTrainingProgram.trainings)
    {
        workoutProgress += MIN(1.0f,[workout.repetitionCounter floatValue] / [self.currentTrainingProgram.workoutRepetition floatValue]);
    }
    CGFloat trainingPlanProgress = workoutProgress / self.currentTrainingProgram.trainings.count;
    
    return trainingPlanProgress;
}

- (void)setupRoundedProgressLabel
{

    self.trainingPlanProgressLabel.fillColor = [UIColor clearColor];
    self.trainingPlanProgressLabel.trackColor = [UIColor colorWithRed:194/255.0f green:236/255.0f blue:255/255.0f alpha:1];
    self.trainingPlanProgressLabel.progressColor = [UIColor colorWithRed:72/255.0f green:206/255.0f blue:253/255.0f alpha:1];
    self.trainingPlanProgressLabel.trackWidth = 15;
    self.trainingPlanProgressLabel.progressWidth = 15;
    self.trainingPlanProgressLabel.roundedCornersWidth = 15;
    
    self.trainingPlanProgressLabel.textColor = self.trainingPlanProgressLabel.progressColor;
    
    self.trainingPlanProgressLabel.labelVCBlock = ^(KAProgressLabel *label) {
        label.text = [NSString stringWithFormat:@"%.0f%%", (label.progress * 100)];
    };
    self.trainingPlanProgressLabel.progress = 0;
}

#pragma mark - IBActions

- (IBAction)facebookButtonPressed:(id)sender
{
    SLComposeViewController *facebookController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result) {

        [facebookController dismissViewControllerAnimated:YES completion:Nil];
    };
    facebookController.completionHandler = myBlock;
    [facebookController setInitialText:NSLocalizedString(@"Facebook_Share_Text", nil)];
    [facebookController addURL:[NSURL URLWithString:@"http://fit-fuze.com"]];
    [facebookController addImage:[UIImage imageNamed:@"icon.png"]];
    [self presentViewController:facebookController animated:YES completion:Nil];
}

- (IBAction)twitterButtonPressed:(id)sender
{
    SLComposeViewController *twitterController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result) {
        [twitterController dismissViewControllerAnimated:YES completion:Nil];
    };
    twitterController.completionHandler = myBlock;
    [twitterController setInitialText:NSLocalizedString(@"Twitter_Share_Text", nil)];
    [self presentViewController:twitterController animated:YES completion:Nil];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.currentlyChosenCellPath = indexPath;
    
    switch (indexPath.row) {
        case 0:
            [self.sideMenuViewController setContentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"trainingPlanNavController"]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 1: {
            UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"exerciseListNavigationController"];
            MuscleGroupSelectionViewController *destinationViewController = navController.viewControllers[0];
            destinationViewController.exercisesAreSelectable = NO;
            [self.sideMenuViewController setContentViewController:navController
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        case 2:
            [self.sideMenuViewController setContentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"statisticsNavController"]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 3:
            [self.sideMenuViewController setContentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"settingsNavController"]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 4:
            [self.sideMenuViewController setContentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"helpNavController"]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        default:
            break;
    }
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return self.menuTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MenuCell";
    
    MainMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.titleLabel.text = self.menuTitles[indexPath.row];
    NSString *imageName = self.icons[indexPath.row];
    cell.iconImageView.image = [UIImage imageNamed:imageName];
    cell.iconImageView.image = [cell.iconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    if ([self.currentlyChosenCellPath isEqual:indexPath]) {
        cell.titleLabel.textColor = [UIColor mainColor];
        cell.iconImageView.tintColor = [UIColor mainColor];
    } else {
        cell.titleLabel.textColor = [UIColor darkGrayColor];
        cell.iconImageView.tintColor = [UIColor darkGrayColor];
    }
    
    return cell;
}




@end
