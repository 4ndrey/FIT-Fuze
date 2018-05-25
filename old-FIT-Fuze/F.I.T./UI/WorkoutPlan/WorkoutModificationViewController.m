//
//  WorkoutCreationViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 04.04.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "WorkoutModificationViewController.h"
#import "WorkoutSelectorTableViewCell.h"
#import "WorkoutSelectorExerciseTableViewCell.h"
#import "WorkoutSelectorTableViewCellDelegate.h"
#import "ExercisesModificationViewController.h"
#import "NavigationTextView.h"
#import "CurrentFitManager.h"
#import "SettingsViewController.h"
#import "UIColor+FIT.h"

@import MagicalRecord;
#import "ActionSheetPicker.h"

@interface WorkoutModificationViewController () <UITextFieldDelegate>

@property (nonatomic) BOOL isInEditingMode;
@property (weak, nonatomic) IBOutlet UIView *addWorkoutView;
@property (weak, nonatomic) IBOutlet UIView *selectTrainingPlanView;
@property (strong, nonatomic) NSString *rightBarButtonName;
@property (nonatomic, strong) NavigationTextView *navigationTextView;
@property (nonatomic, strong) UIBarButtonItem *saveBarButton;

@property (weak, nonatomic) IBOutlet UITableView *workoutTableView;
@property (nonatomic, strong) NSArray *workouts;
@property (nonatomic) BOOL workoutIsExpended;
@property (nonatomic) NSInteger exepandedCellIndex;
@property (nonatomic) NSInteger exerciseCellStartIndex;
@property (nonatomic) NSInteger exerciseCellStopIndex;
@property (nonatomic) NSInteger shownExerciseCellsCount;
@property (nonatomic) NSMutableArray *expandedCellPaths;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editDoneButton;
@property (weak, nonatomic) IBOutlet UITableView *trainingPlanModificationTableView;
@property (weak, nonatomic) IBOutlet UIButton *selectTrainingPlanButton;
@property (weak, nonatomic) IBOutlet UIButton *addWorkoutsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveAndExitButton;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

@property (nonatomic, strong) Training *selectedWorkout;

@end

@implementation WorkoutModificationViewController

#pragma mark - Lifeclcycle

- (IBAction)saveAndExitAction:(id)sender {
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"createModeON"];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor mainColor]} forState:UIControlStateNormal];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName : [UIColor mainColor],
                                                           NSFontAttributeName: [UIFont systemFontOfSize:20 weight:UIFontWeightLight],
                                                           }];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"planWasCreated" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.trainingPlanModificationTableView setContentInset:UIEdgeInsetsMake(0,0,65,0)];

    [self setupButtons];
    self.workouts = [self.trainingProgram.trainings array];
    [self.editDoneButton setTitle:(self.isInEditingMode ? NSLocalizedString(@"Done_Button_Title", nil) : NSLocalizedString(@"Edit_Button_Title", nil))];
    [self.welcomeLabel setText:NSLocalizedString(@"AddWorkouts_WelcomeLabel_Title", nil)];
    self.isInEditingMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"createModeON"] || (!self.trainingProgram) || (!self.workouts) || (self.workouts.count == 0);

    self.navigationTextView = [[NavigationTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 120, 64)];
    self.navigationTextView.titleTextField.text = self.trainingProgram.name;
    
    if(self.navigationTextView.titleTextField.text.length == 0) {
        self.navigationTextView.titleTextField.text = NSLocalizedString(@"Title_of_the_new_plan", nil);
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"createModeON"]) {
        self.navigationTextView.titleTextField.textColor = [UIColor editColor];
        self.navigationTextView.descriptionLabel.textColor = [UIColor editColor];
        self.navigationController.navigationBar.tintColor = [UIColor editColor];
    }
    
    self.navigationTextView.titleTextField.returnKeyType = UIReturnKeyDone;
    self.navigationTextView.titleTextField.delegate = self;
    self.navigationTextView.descriptionLabel.text = NSLocalizedString(@"WorkoutModificationChangeWorkout_Navbar_Title", nil);
    self.navigationItem.titleView = self.navigationTextView;
    
    [self.workoutTableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"TableViewSectionFooterViewIdentifier"];
}

- (void)setupButtons {
    [self.addWorkoutsButton setTitle:NSLocalizedString(@"AddWorkouts_Button_Title", nil) forState:UIControlStateNormal];
    self.addWorkoutsButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.addWorkoutsButton.titleLabel.numberOfLines = 2;
    self.addWorkoutsButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.addWorkoutsButton.titleLabel.minimumScaleFactor = 0.5;
    
    [self.selectTrainingPlanButton setTitle:NSLocalizedString(@"SelectTrainingplan_Button_Title", nil) forState:UIControlStateNormal];
    self.selectTrainingPlanButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.selectTrainingPlanButton.titleLabel.numberOfLines = 2;
    self.selectTrainingPlanButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.selectTrainingPlanButton.titleLabel.minimumScaleFactor = 0.5;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.workouts = [self.trainingProgram.trainings array];
    [self.workoutTableView reloadData];
    [self refreshEditingView];
    [self refreshRightBarButton];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)refreshRightBarButton {
    if (self.workouts.count == 0) {
        self.welcomeLabel.hidden = NO;
        [self.editDoneButton setTitle:@""];
        self.editDoneButton.enabled = NO;
    } else {
        self.welcomeLabel.hidden = YES;
        [self.editDoneButton setTitle:self.isInEditingMode ? NSLocalizedString(@"Done_Button_Title", nil) : NSLocalizedString(@"Edit_Button_Title", nil)];
        self.editDoneButton.enabled = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.workouts.count == 0) {
        self.saveBarButton = self.saveAndExitButton;
        self.navigationItem.leftBarButtonItem = nil;
        [self.navigationTextView.titleTextField becomeFirstResponder];
    }
}

- (void)refreshEditingView
{
    if (self.isInEditingMode)
    {
        self.addWorkoutView.hidden = NO;
        self.selectTrainingPlanView.hidden = YES;
    }
    else
    {
        self.addWorkoutView.hidden = YES;
        self.selectTrainingPlanView.hidden = NO;
    }
}

#pragma mark - IBActions
- (IBAction)editButtonPressed:(id)sender
{
    if (!self.rightBarButtonName)
    { //we're editing workouts list
        self.isInEditingMode = !self.isInEditingMode;
        
        if(self.isInEditingMode) {
            self.saveBarButton = self.navigationItem.leftBarButtonItem;
            self.navigationItem.leftBarButtonItem = nil;
            [sender setTitle: NSLocalizedString(@"Done_Button_Title", nil)];
        } else {
            [sender setTitle: NSLocalizedString(@"Edit_Button_Title", nil)];
            if(self.saveBarButton) {
                self.navigationItem.leftBarButtonItem = self.saveBarButton;
                self.saveBarButton = nil;
            }
        }
        

        [self.trainingPlanModificationTableView setEditing:self.isInEditingMode animated:YES];
        [self refreshEditingView];
    }
    else
    { //if we're editing tr.plan name
        [self.navigationTextView.titleTextField resignFirstResponder];
        self.navigationTextView.descriptionLabel.alpha = 1;
        [self refreshRightBarButton];
        self.rightBarButtonName = nil;
        
        if(self.saveBarButton) {
            self.navigationItem.leftBarButtonItem = self.saveBarButton;
            self.saveBarButton = nil;
        }
    }
}

- (IBAction)selectTrainingPlanButtonPressed:(id)sender
{
    [self showWorkoutRepetitonsPicker:sender];
}

- (void)showWorkoutRepetitonsPicker:(id)sender;
{
    // Create an array of strings you want to show in the picker:
    NSArray *repetitions = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", nil];
    ActionSheetStringPicker *repetitonsPicker = [[ActionSheetStringPicker alloc] initWithTitle:NSLocalizedString(@"TrainingPlan_Duration_Picker_Title", nil)
                                                                                          rows:repetitions
                                                                              initialSelection:5
                                                                                     doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, NSString *selectedValue) {
                                                                                         self.trainingProgram.workoutRepetition = @([selectedValue integerValue]);
                                                                                         [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                                                                                         
                                                                                         //save trainingplan id to user defaults
                                                                                         [[CurrentFitManager sharedManager] saveCurrentProgram:self.trainingProgram dublicate:NO];
                                                                                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldGoToRoot"];
                                                                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                                                                         
                                                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                                                                         [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"createModeON"];
                                                                                         [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor mainColor]} forState:UIControlStateNormal];
                                                                                         [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                                                                                                                NSForegroundColorAttributeName : [UIColor mainColor],
                                                                                                                                                NSFontAttributeName: [UIFont systemFontOfSize:20 weight:UIFontWeightLight],
                                                                                                                                                }];
                                                              
                                                                                     }
                                                                                   cancelBlock:^(ActionSheetStringPicker *picker) {
                                                                                       NSLog(@"Block Picker Canceled");
                                                                                   }
                                                                                        origin:sender];
    repetitonsPicker.hideCancel = NO;

    UIBarButtonItem *doneButton = ({
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] init];
        doneButton.tintColor = [UIColor blackColor];
        doneButton.title = NSLocalizedString(@"Done_Button_Title", nil);
        [doneButton setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor blackColor], NSForegroundColorAttributeName,nil]
                                  forState:UIControlStateNormal];
        doneButton;
    });
    [repetitonsPicker setDoneButton:doneButton];
    
    UIBarButtonItem *cancelButton = ({
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] init];
        cancelButton.tintColor = [UIColor blackColor];
        cancelButton.title = NSLocalizedString(@"Cancel_Button_Title", nil);
        [cancelButton setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor blackColor], NSForegroundColorAttributeName,nil]
                                  forState:UIControlStateNormal];
        cancelButton;
    });
    [repetitonsPicker setCancelButton:cancelButton];
    
    [repetitonsPicker showActionSheetPicker];
    
    UIView *overlay = [[UIView alloc] initWithFrame:repetitonsPicker.pickerView.frame];
    overlay.backgroundColor = [UIColor clearColor];
    
    UILabel *weeksLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-120, 54, 120, 30)];
    weeksLabel.text = NSLocalizedString(@"TrainingPlan_Duration_Picker_Weeks_Label", nil);
    weeksLabel.font = [UIFont systemFontOfSize:20];
    [overlay addSubview:weeksLabel];
    
    [repetitonsPicker.pickerView addSubview:overlay];
}

- (IBAction)addWorkoutButtonPressed:(id)sender
{
    //create new workout
    Training *newWorkout = [NSEntityDescription insertNewObjectForEntityForName:@"Training" inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    newWorkout.name = NSLocalizedString(@"CustomWorkoutDefault_Title", nil);
    NSMutableArray *workouts = [[[self.trainingProgram trainings] array] mutableCopy];
    if (!workouts)
    {
        workouts = [[NSMutableArray alloc] init];
    }
    [workouts addObject:newWorkout];
    [self.trainingProgram setTrainings:[[NSOrderedSet alloc] initWithArray:workouts]];
    self.selectedWorkout = newWorkout;
    [self performSegueWithIdentifier:@"showWorkoutModification" sender:nil];
}


#pragma mark - TableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

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
    
    cell.workoutTitleLabel.text = NSLocalizedString(workout.name,nil);
    cell.exerciseDetailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"ExercisesWithArrow_Button_Title", nil), (unsigned long)workout.exerciseMetaMappings.count];
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedWorkout = self.workouts[indexPath.row];
    [self performSegueWithIdentifier:@"showWorkoutModification" sender:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.isInEditingMode;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Training *workout = self.workouts[indexPath.row];
        [[NSManagedObjectContext MR_defaultContext] deleteObject:workout];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        self.workouts = [self.trainingProgram.trainings array];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self refreshRightBarButton];
        
        if(self.workouts.count == 0) {
            self.welcomeLabel.hidden = NO;
        }
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSMutableArray *workouts = [self.workouts mutableCopy];
    Training *workoutToMove = workouts[sourceIndexPath.row];
    [workouts removeObjectAtIndex:sourceIndexPath.row];
    [workouts insertObject:workoutToMove atIndex:destinationIndexPath.row];
    self.workouts = workouts;
    self.trainingProgram.trainings = [[NSOrderedSet alloc]initWithArray:self.workouts];;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.saveBarButton = self.saveAndExitButton;
    self.navigationItem.leftBarButtonItem = nil;
    
    self.rightBarButtonName = self.navigationItem.rightBarButtonItem.title;
    self.navigationItem.rightBarButtonItem.title = @"";
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationTextView.descriptionLabel.alpha = 0;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.navigationTextView.titleTextField resignFirstResponder];
    self.navigationTextView.descriptionLabel.alpha = 1;
    [self refreshRightBarButton];
    self.rightBarButtonName = nil;
    
    if(self.saveBarButton) {
        self.navigationItem.leftBarButtonItem = self.saveBarButton;
    }
    
    self.saveBarButton = nil;
    [textField resignFirstResponder];

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.trainingProgram.name = textField.text;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showWorkoutModification"])
    {
        ExercisesModificationViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.workout = self.selectedWorkout;
        destinationViewController.isInEditingMode = YES;
    }
}

@end
