//
//  WorkoutSelectorViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 08.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "WorkoutSelectorViewController.h"
#import "WorkoutSelectorTableViewCell.h"
#import "WorkoutSelectorExerciseTableViewCell.h"
#import "WorkoutSelectorTableViewCellDelegate.h"
#import "ExercisesModificationViewController.h"
#import "UIColor+Fit.h"
#import "CurrentFitManager.h"
#import "SettingsViewController.h"

@interface WorkoutSelectorViewController () <IAPProviderDelegate>

@property (weak, nonatomic) IBOutlet UITableView *workoutTableView;
@property (nonatomic, strong) NSArray *workouts;
@property (nonatomic, strong) Training *selectedWorkout;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;

@end

@implementation WorkoutSelectorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.workoutTableView setContentInset:UIEdgeInsetsMake(0,0,65,0)];
    [self setupButton];
    [self setupIndicatorView];

    self.navigationItem.title = NSLocalizedString(self.trainingProgram.name, nil);
    
    [IAPProvider sharedInstance].viewController = self;
    if (![[IAPProvider sharedInstance] areProgramsFetched])
    {
        [[IAPProvider sharedInstance] fetchTrainingPrograms];
    }
    [self updateBottomButton];
    self.workouts = [self.trainingProgram.trainings array];
}

- (void)setupButton {
    self.bottomButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.bottomButton.titleLabel.numberOfLines = 2;
    self.bottomButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.bottomButton.titleLabel.minimumScaleFactor = 0.5;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
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


- (void)updateBottomButton
{
    if ((![self.trainingProgram.isFree boolValue] && ![self.trainingProgram.isPurchased boolValue]))
    {
        if ([IAPProvider sharedInstance].programsFetched)
        {
            [self.bottomButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"BuyTrainingPlan_Button_Title", nil),[[IAPProvider sharedInstance] getPrice:self.trainingProgram.programId]] forState:UIControlStateNormal];
        }
        else
        {
            if ([IAPProvider sharedInstance].inAppPurchasesAllowed)
            {
                [self.bottomButton setTitle:NSLocalizedString(@"RetryConnection_Button_Title", nil) forState:UIControlStateNormal];
            }
            else
            {
                self.tableViewBottomConstraint.constant = 0;
                self.bottomButton.hidden = YES;
            }
        }
    }
    else
    {
        [self.bottomButton setTitle:NSLocalizedString(@"SelectTrainingplan_Button_Title", nil) forState:UIControlStateNormal];

    }
}

- (void)activateCurrentTrainingProgram
{
    BOOL duplicateTrainingprogram = ![self.trainingProgram.userProgram boolValue];
    //copy trainingplan then save it to nsuserdefaults
    [[CurrentFitManager sharedManager] saveCurrentProgram:self.trainingProgram dublicate:duplicateTrainingprogram];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserChangedPlan" object:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - IBActions

- (IBAction)bottomButtonPressed:(id)sender
{
    if (([self.trainingProgram.isFree boolValue] || [self.trainingProgram.isPurchased boolValue]))
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:NSLocalizedString(@"Training_Plan_Contains_Default_Values_Title", nil)
                                      message:NSLocalizedString(@"Training_Plan_Contains_Default_Values_Text", nil)
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"AlertView_OK_Title", nil)
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [self activateCurrentTrainingProgram];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else
    {
    
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        [IAPProvider sharedInstance].delegate = self;
        
        if ([IAPProvider sharedInstance].programsFetched)
        {
            [[IAPProvider sharedInstance] buyTrainingProgram:self.trainingProgram.programId];
        }
        else
        {
            [[IAPProvider sharedInstance] fetchTrainingPrograms];
        }
    }
}

#pragma mark - IAPProviderDelegate


- (void)transactionSuccessful
{
    [self updateBottomButton];
    [self.workoutTableView reloadData];
    [self.activityIndicator stopAnimating];
}

- (void)transactionFailed
{
    [self.activityIndicator stopAnimating];
}

- (void)fetchingFinished
{   [self.activityIndicator stopAnimating];
    [self updateBottomButton];
}

- (void)restoreTransactionsFinished{}
- (void)restoreTransactionsFailed{}

#pragma mark - TableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    int height = (int)(16*NSLocalizedString(self.trainingProgram.programDescription,nil).length/25+110);
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    
    UILabel *explanationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.view.frame.size.width - 10, height)];
    explanationLabel.textColor = [UIColor darkGrayColor];
    explanationLabel.numberOfLines = 0;
    explanationLabel.textAlignment = NSTextAlignmentLeft;
    explanationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    explanationLabel.text = NSLocalizedString(self.trainingProgram.programDescription,nil);
    [footerView addSubview:explanationLabel];
    
    tableView.tableFooterView = footerView;
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.workouts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"WorkoutCell";
    WorkoutSelectorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    Training *workout = self.workouts[indexPath.row];
    
    //set exerciseImage for workout
    ExerciseMetaMapping *exerciseMetaMapping = [[workout.exerciseMetaMappings array] firstObject];
    NSArray *arrayOfImages = [((Exercise *)exerciseMetaMapping.exercise).images array];
    Images *image = arrayOfImages.count > 6 ? [arrayOfImages objectAtIndex:6] : [arrayOfImages objectAtIndex:0];
    cell.workoutImageView.image = [UIImage imageWithData:image.image];
    
    cell.workoutTitleLabel.text = NSLocalizedString(workout.name,nil);
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    NSInteger restTime = [[sharedDefaults objectForKey:restTimeKey] integerValue] ? : 60;
    int seconds  = 0;
    NSArray *exerciseMetaMappings = [workout.exerciseMetaMappings array];
    
    for (int i = 0; i<exerciseMetaMappings.count; i++)
    {
        ExerciseMetaMapping *exercisMetaMapping = exerciseMetaMappings[i];
        ExerciseMeta *exerciseMeta = (ExerciseMeta *)exercisMetaMapping.exerciseMeta;
        for (WorkoutSet *set in exerciseMeta.sets)
        {
            seconds += [set.repetitions integerValue] * 5;
            seconds += restTime;
        }
        
        //time between exercises
        seconds += 120;
    }
    
    cell.workoutDurationLabel.text = [NSString stringWithFormat:@"%dm", (seconds/60 + 1)];
    if ([self.trainingProgram.isFree boolValue] || [self.trainingProgram.isPurchased boolValue])
    {
        cell.exerciseDetailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"ExercisesWithArrow_Button_Title", nil), (unsigned long)workout.exerciseMetaMappings.count];
        cell.exerciseDetailLabel.textColor = [UIColor mainColor];
        cell.userInteractionEnabled = YES;
    }
    else
    {
        cell.exerciseDetailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"ExercisesWithoutArrow_Button_Title", nil), (unsigned long)workout.exerciseMetaMappings.count];
        cell.exerciseDetailLabel.textColor = [UIColor lightGrayColor];
        cell.userInteractionEnabled = NO;
        
    }
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedWorkout = self.workouts[indexPath.row];
    [self performSegueWithIdentifier:@"showExerciseScreen" sender:nil];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showExerciseScreen"])
    {
        ExercisesModificationViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.workout = self.selectedWorkout;
        destinationViewController.editModeIsUnavailable = YES;
    }
}


@end
