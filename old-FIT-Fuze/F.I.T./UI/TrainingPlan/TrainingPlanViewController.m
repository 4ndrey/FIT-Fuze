//
//  TrainingPlanViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 17.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "TrainingPlanViewController.h"
#import "WorkoutSelectorTableViewCell.h"
#import "WorkoutPageContainerViewController.h"
#import "WorkoutExecutionRootViewController.h"
#import "FIT-Swift.h"
#import "WorkoutSelectorTableViewCellDelegate.h"
#import "WorkoutSelectorExerciseTableViewCell.h"
#import "MGSwipeButton.h"
#import "NSManagedObjectContext+FetchedObjectFromURI.h"
#import "UIColor+FIT.h"
#import "ExercisesModificationViewController.h"
#import "ExerciseDescriptionViewController.h"
#import "CurrentFitManager.h"
#import "UAAppReviewManager.h"
#import "SettingsViewController.h"
#import "ActionSheetStringPicker.h"
#import "UIViewController+Tutorial.h"
#import "WhatsNewViewController.h"
#import "WorkoutExecutionWatchdog.h"
#import "CBZSplashView.h"

@import MagicalRecord;

@interface TrainingPlanViewController ()  <WorkoutSelectorTableViewCellDelegate, MGSwipeTableCellDelegate, WhatsNewViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *trainingTableView;
@property (weak, nonatomic) IBOutlet UIButton *startTodaysWorkoutButton;

@property (nonatomic, strong) TrainingProgram *currentTrainingProgram;
@property (nonatomic, strong) NSMutableArray *workouts;
@property (nonatomic, strong) Training *selectedWorkout;
@property (nonatomic, strong) Exercise *selectedExercise;
@property (nonatomic) BOOL isInEditingMode;
@property (nonatomic) BOOL hasExpandedCell;

@property (nonatomic) BOOL workoutIsExpended;
@property (nonatomic) NSInteger exepandedCellIndex;
@property (nonatomic) NSInteger exerciseCellStartIndex;
@property (nonatomic) NSInteger exerciseCellStopIndex;
@property (nonatomic) NSInteger shownExerciseCellsCount;
@property (nonatomic) NSMutableArray *expandedCellPaths;
@property (nonatomic) NSInteger todayBannerIndex;
@property (weak, nonatomic) IBOutlet UIButton *selectFirstPlanButton;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) IBOutlet UIVisualEffectView *bottomEffectView;
@property (strong, nonatomic) IBOutlet UIButton *leftBarButton;
@property (strong, nonatomic) IBOutlet UIButton *rightBarButton;
@property (strong, nonatomic) UIRefreshControl *syncWithWatchRefreshControl;

@end

@implementation TrainingPlanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.workoutIsExpended = NO;
    [self.trainingTableView setContentInset:UIEdgeInsetsMake(0,0,65,0)];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"UserChangedPlan" object:nil];

    [self setTitle: NSLocalizedString(@"Trainingplans_Label_Text",nil)];
    
    [self.trainingTableView setSeparatorInset:UIEdgeInsetsZero];
    [self.startTodaysWorkoutButton setTitle:NSLocalizedString(@"StartTodayWorkout_Button_Title", nil) forState:UIControlStateNormal];
    self.startTodaysWorkoutButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.startTodaysWorkoutButton.titleLabel.numberOfLines = 2;
    self.startTodaysWorkoutButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.startTodaysWorkoutButton.titleLabel.minimumScaleFactor = 0.5;
    
    NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];
    self.currentTrainingProgram = (TrainingProgram *)[moc objectWithURI:[[NSUserDefaults standardUserDefaults] URLForKey:@"currentTrainingplan"]];
    
    self.selectFirstPlanButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.selectFirstPlanButton setTitle:NSLocalizedString(@"Select_First_Plan_Button_title", nil) forState:UIControlStateNormal];
    self.welcomeLabel.text = NSLocalizedString(@"Welcome_to_FITFuze_text", nil);
    
    NSString *welcomeText = NSLocalizedString(@"Welcome_to_FITFuze_text", nil);
    NSRange rangeBold = [welcomeText rangeOfString:@"FIT Fuze"];
    
    UIFont *fontText = [UIFont boldSystemFontOfSize:30];
    NSDictionary *dictBoldText = [NSDictionary dictionaryWithObjectsAndKeys:fontText, NSFontAttributeName, nil];
    
    NSMutableAttributedString *mutAttrTextViewString = [[NSMutableAttributedString alloc] initWithString:welcomeText];
    [mutAttrTextViewString setAttributes:dictBoldText range:rangeBold];
    
    self.welcomeLabel.attributedText = mutAttrTextViewString;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        UIImage *icon = [UIImage imageNamed:@"logo_white"];
        CBZSplashView *splashView = [CBZSplashView splashViewWithIcon:icon backgroundColor:[UIColor mainColor] offset:CGPointMake(0, -40)];
        splashView.animationDuration = 0.5;
        // customize duration, icon size, or icon color here;
        [self.navigationController.view addSubview:splashView];
        [splashView startAnimation];
    });
    
    self.syncWithWatchRefreshControl = [[UIRefreshControl alloc] init];
    self.syncWithWatchRefreshControl.backgroundColor = [UIColor mainColor];
    self.syncWithWatchRefreshControl.tintColor = [UIColor whiteColor];
    self.syncWithWatchRefreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Sync with Watch" attributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.syncWithWatchRefreshControl addTarget:self
                            action:@selector(syncWithWatch)
                  forControlEvents:UIControlEventValueChanged];
    [self.trainingTableView addSubview:self.syncWithWatchRefreshControl];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - internal

- (void)syncWithWatch
{
    [[CurrentFitManager sharedManager] getWatchData];
    
    [self.syncWithWatchRefreshControl endRefreshing];
}

- (IBAction)goToPlansSelection
{
    [self performSegueWithIdentifier:@"showAvailableTrainingPlans" sender:self];
}

- (void)userHasSeenWhatsNew
{
    if (!self.currentTrainingProgram)
    {
        self.selectFirstPlanButton.hidden = NO;
        self.welcomeLabel.hidden = NO;
    }
}

- (void)refresh
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];
        self.currentTrainingProgram = (TrainingProgram *)[moc objectWithURI:[[NSUserDefaults standardUserDefaults] URLForKey:@"currentTrainingplan"]];
        
        self.selectFirstPlanButton.hidden = self.currentTrainingProgram != nil;
        self.welcomeLabel.hidden = self.selectFirstPlanButton.hidden;
        
        self.startTodaysWorkoutButton.hidden = !self.selectFirstPlanButton.hidden;
        self.bottomEffectView.hidden = !self.selectFirstPlanButton.hidden;
        
        NSString *title = NSLocalizedString(self.currentTrainingProgram.name,nil);
        
        if(title && title.length > 0) {
            [self setTitle: NSLocalizedString(self.currentTrainingProgram.name,nil)];
        }
        
        self.workouts = [[self.currentTrainingProgram.trainings array] mutableCopy];
        
        //check todayBanner index
        [self checkTodayBanner];
        [self.trainingTableView reloadData];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shouldGoToRoot"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldGoToRoot"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"createModeON"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [UAAppReviewManager showPromptIfNecessary];
    [self refresh];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"shouldStartCurrentWorkout"])
    {
        [self startTodaysWorkout:nil];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldStartCurrentWorkout"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"Updates_20_shown"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Updates_20_shown"];
        [self performSegueWithIdentifier:@"showUpdateNotes" sender:nil];
        return;
    }
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Menu_BarItem_Title",nil) attributes:@{
                                                                                                                                                NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12],
                                                                                                                                                NSForegroundColorAttributeName : [UIColor darkGrayColor],
                                                                                                                                                }];
    [self.leftBarButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    attributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Plans_TabBar_Button_title",nil) attributes:@{
                                                                                                                                   NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12],
                                                                                                                                   NSForegroundColorAttributeName : [UIColor darkGrayColor],
                                                                                                                                   }];
    [self.rightBarButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    if (!self.currentTrainingProgram)
    {
        self.selectFirstPlanButton.hidden = NO;
        self.welcomeLabel.hidden = NO;
        
    }
    
    [self.trainingTableView reloadData] ;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refresh];
}

- (void)setTitle:(NSString *)titleString
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-90, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.text = titleString;
    label.font = [UIFont systemFontOfSize:20 weight:UIFontWeightLight];
    if (label.text.length > 25) {
        label.numberOfLines = 2;
    }
    label.minimumScaleFactor = 0.5;
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor mainColor];
    self.navigationItem.titleView = label;
}

#pragma mark - internal

- (void)checkTodayBanner {
    NSInteger repetitionCounter = [[self.workouts.lastObject repetitionCounter] integerValue];
    for (NSInteger i = (self.workouts.count-1); i >= 0; i--)
    {
        Training *workout = self.workouts[i];
        if ([workout.repetitionCounter integerValue] <= repetitionCounter)
        {
            repetitionCounter = [workout.repetitionCounter integerValue];
            self.todayBannerIndex = i;
        }
    }
    [[CurrentFitManager sharedManager] setCurrentWorkoutIndex:self.todayBannerIndex];
}

#pragma mark - Internal

- (void)setupSwipeButtonsForTableViewCell:(WorkoutSelectorTableViewCell *)cell andIndexPath:(NSIndexPath *)indexPath
{
    //configure right buttons
    
    MGSwipeButton *editButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Edit_Button_Title", nil) backgroundColor:[UIColor mainColor]];
    editButton.titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightLight];
    editButton.buttonWidth = 110;
    editButton.tag = indexPath.row;
    __weak MGSwipeButton *weakEditButton = editButton;
    editButton.callback = (^BOOL(MGSwipeTableCell *sender)
                           {
                               self.selectedWorkout = self.workouts[weakEditButton.tag];
                               [self performSegueWithIdentifier:@"showEditWorkoutScreen" sender:nil];
                               return YES;
                           });
    
    /* not in v1.0
    MGSwipeButton *todayButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Today_Button_Title", nil) backgroundColor:[UIColor lightGrayColor]];
    todayButton.titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightLight];
    todayButton.tag = indexPath.row;
    todayButton.callback = (^BOOL(MGSwipeTableCell *sender)
                            {
                                self.todayBannerIndex = indexPath.row;
                                [[CurrentFitManager sharedManager] setCurrentWorkoutIndex:indexPath.row];
                                [self.trainingTableView reloadData];
                                return YES;
                            });
    todayButton.buttonWidth = deleteButton.buttonWidth;
     */
    
    cell.rightButtons = @[editButton];
    cell.rightSwipeSettings.transition = MGSwipeTransitionStatic;
}

#pragma mark - IBActions

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender
{
    self.isInEditingMode = !self.isInEditingMode;
    [self.trainingTableView setEditing:self.isInEditingMode animated:YES];
}

- (IBAction)startTodaysWorkout:(id)sender
{
    if(!self.currentTrainingProgram)
    {
        [self performSegueWithIdentifier:@"showAvailableTrainingPlans" sender:nil];
        return;
    }
    
    if (self.workouts.count >= 1) {
        self.selectedWorkout = self.workouts[self.todayBannerIndex];
        [self performSegueWithIdentifier:@"showWorkoutPlan" sender:nil];
    }
    else{
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:NSLocalizedString(@"Training_plan_is_empty_warning_title", nil)
                                      message:NSLocalizedString(@"Training_plan_is_empty_warning_text", nil)
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
}

#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //detail exercise cells
    if (self.workoutIsExpended && (indexPath.row >= self.exerciseCellStartIndex) && (indexPath.row < self.exerciseCellStopIndex))
    {
        return 60;
    }
    
    return 85;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.workoutIsExpended)
    {
        return self.workouts.count + self.shownExerciseCellsCount;
    }
    
    return self.workouts.count;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //detail exercise cells
    if (self.workoutIsExpended && (indexPath.row >= self.exerciseCellStartIndex) && (indexPath.row < self.exerciseCellStopIndex))
    {
        Training *workout = self.workouts[self.exepandedCellIndex];
        NSArray *exerciseMetaMappings = [workout.exerciseMetaMappings array];
        ExerciseMetaMapping *exercisMetaMapping = exerciseMetaMappings[indexPath.row - self.exerciseCellStartIndex];
        
        if(!exercisMetaMapping.withNext) {
            // Remove seperator inset
            if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                [cell setSeparatorInset:UIEdgeInsetsZero];
            }
            
            // Prevent the cell from inheriting the Table View's margin settings
            if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
                [cell setPreservesSuperviewLayoutMargins:NO];
            }
            
            // Explictly set your cell's layout margins
            if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                [cell setLayoutMargins:UIEdgeInsetsZero];
            }
        } else {
            // Remove seperator inset
            if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                [cell setSeparatorInset:UIEdgeInsetsMake(0, 1000, 0, 0)];
            }
            
            // Prevent the cell from inheriting the Table View's margin settings
            if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
                [cell setPreservesSuperviewLayoutMargins:NO];
            }
            
            // Explictly set your cell's layout margins
            if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                [cell setLayoutMargins:UIEdgeInsetsMake(0, 1000, 0, 0)];
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //detail exercise cells
    if (self.workoutIsExpended && (indexPath.row >= self.exerciseCellStartIndex) && (indexPath.row < self.exerciseCellStopIndex))
    {
        static NSString *cellIdentifier = @"WorkoutExerciseCell";
        WorkoutSelectorExerciseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        Training *workout = self.workouts[self.exepandedCellIndex];
        NSArray *exerciseMetaMappings = [workout.exerciseMetaMappings array];
        ExerciseMetaMapping *exercisMetaMapping = exerciseMetaMappings[indexPath.row - self.exerciseCellStartIndex];
        ExerciseMeta *exerciseMeta = (ExerciseMeta *)exercisMetaMapping.exerciseMeta;
        Exercise *exercise = (Exercise *)exercisMetaMapping.exercise;
        cell.exerciseTitleLabel.text = NSLocalizedString(exercise.name,nil);
        
        int min = 100, curr = 0, max = 0;
        for (WorkoutSet *currSet in exerciseMeta.sets) {
            curr = [currSet.repetitions intValue];
            if (min > curr) {
                min = curr;
            }
            if (max < curr) {
                max = curr;
            }
        }
        NSString *repsString = min == max ? [NSString stringWithFormat:@"%d", max] : [NSString stringWithFormat:@"%d-%d", min, max];
        cell.exerciseMetaInformationLabel.text = [NSString stringWithFormat:NSLocalizedString(@"ExerciseMetaInformation_Label_Text", nil) ,exerciseMeta.sets.count, repsString];
        Images *image = exercise.images.count > 6 ? [exercise.images objectAtIndex:6] : [exercise.images objectAtIndex:0];
        cell.workoutExerciseImageView.image = [UIImage imageWithData:image.image];
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        [cell setTintColor:[UIColor lightGrayColor]];
        
        if(exercisMetaMapping.withNext) {
            cell.showWithNextSign = YES;
        } else {
            cell.showWithNextSign = NO;
        }
        
        return cell;
    }
    else
    {
        static NSString *cellIdentifier = @"WorkoutCell";
        WorkoutSelectorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        Training *workout = self.workouts[indexPath.row - (self.workoutIsExpended && (indexPath.row >= self.exerciseCellStopIndex) ? (self.exerciseCellStopIndex - self.exerciseCellStartIndex) : 0 )];
        
        cell.accessoryType = UITableViewCellAccessoryNone;

        //set exerciseImage for workout
        ExerciseMetaMapping *exerciseMetaMapping = [[workout.exerciseMetaMappings array] firstObject];
        NSArray *arrayOfImages = [((Exercise *)exerciseMetaMapping.exercise).images array];
        Images *image = arrayOfImages.count > 6 ? [arrayOfImages objectAtIndex:6] : [arrayOfImages objectAtIndex:0];
        cell.workoutImageView.image = [UIImage imageWithData:image.image];
        
        cell.workoutTitleLabel.text = NSLocalizedString(workout.name,nil);
        
        unsigned long countOfExercises = (unsigned long)workout.exerciseMetaMappings.count;
        NSString *countString = [NSString stringWithFormat:NSLocalizedString(@"ExerciseDetails_Button_Title_Down", nil), countOfExercises];
        [cell.exerciseDetailButton setTitle:countString forState:UIControlStateNormal];

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
        cell.selectorDelegate = self;
        cell.delegate = self;
        cell.todayLabel.hidden = !(indexPath.row == self.todayBannerIndex);
        cell.todayBanner.hidden = cell.todayLabel.hidden;
        cell.todayLabel.text = NSLocalizedString(@"Next_Label_Text", nil);
        NSString *repetitionsDone = [NSString stringWithFormat:NSLocalizedString(@"ExerciseRepetition_Label_Text", nil),workout.repetitionCounter,[self.currentTrainingProgram.workoutRepetition integerValue]];
        [cell.repetitionsDoneButton setTitle:repetitionsDone forState:UIControlStateNormal];
        
        [self setupSwipeButtonsForTableViewCell:cell andIndexPath:indexPath];
        
        if ((self.expandedCellPaths.count > 0) && (indexPath.row == self.exepandedCellIndex)) {
            [cell showDetails];
        } else {
            [cell dismissDetails];
        }
        
        return cell;
    }
}

- (void)repetitionsButtonPressedTableViewCell:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [self.trainingTableView indexPathForCell:cell];
    __block Training *workout = self.workouts[indexPath.row - (self.workoutIsExpended && (indexPath.row >= self.exerciseCellStopIndex) ? (self.exerciseCellStopIndex - self.exerciseCellStartIndex) : 0 )];
    
    NSInteger workoutMaxRepetition = [self.currentTrainingProgram.workoutRepetition integerValue];
    NSMutableArray *repetitions = [[NSMutableArray alloc] initWithCapacity: workoutMaxRepetition+1];
    for(int i = 0; i <= (int)workoutMaxRepetition; i++) {
        [repetitions addObject:[NSString stringWithFormat:@"%d", i]];
    }
    ActionSheetStringPicker *repetitonsPicker = [[ActionSheetStringPicker alloc] initWithTitle:NSLocalizedString(@"Workout_Duration_Correct_Picker_Title", nil)
                                                                                          rows:[repetitions copy]
                                                                              initialSelection:[workout.repetitionCounter integerValue]
                                                                                     doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, NSString *selectedValue) {
                                                                                         workout.repetitionCounter = @([selectedValue integerValue]);
                                                                                         [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                                                                                         
                                                                                         //save trainingplan id to user defaults
                                                                                         [[CurrentFitManager sharedManager] saveCurrentProgram:self.currentTrainingProgram dublicate:NO];
                                                                                         [self checkTodayBanner];
                                                                                         [self.trainingTableView reloadData];
                                                                                     }
                                                                                   cancelBlock:^(ActionSheetStringPicker *picker) {
                                                                                       NSLog(@"Block Picker Canceled");
                                                                                   }
                                                                                        origin:cell];
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
    weeksLabel.text = NSLocalizedString(@"Workout_Correction_Picker_Times_Label", nil);
    weeksLabel.font = [UIFont systemFontOfSize:20];
    [overlay addSubview:weeksLabel];
    
    [repetitonsPicker.pickerView addSubview:overlay];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[WorkoutSelectorExerciseTableViewCell class]]) //exerciseCell
    {
        return;
    }
    else if (self.workoutIsExpended && indexPath.row > self.exepandedCellIndex) //workout cell, but exercises are expanded
    {
        Training *expandedWorkout = self.workouts[self.exepandedCellIndex];
        NSArray *exerciseMetaMappings = [expandedWorkout.exerciseMetaMappings array];
        self.selectedWorkout = self.workouts[indexPath.row - exerciseMetaMappings.count];
        [self performSegueWithIdentifier:@"showWorkoutPlan" sender:nil];
    }
    else //workout cell, exercises are collapsed
    {
        self.selectedWorkout = self.workouts[indexPath.row];
        [self performSegueWithIdentifier:@"showWorkoutPlan" sender:nil];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    Training *workout = self.workouts[self.exepandedCellIndex];
    NSArray *exerciseMetaMappings = [workout.exerciseMetaMappings array];
    ExerciseMetaMapping *exercisMetaMapping = exerciseMetaMappings[indexPath.row - self.exerciseCellStartIndex];
    self.selectedExercise = (Exercise *)exercisMetaMapping.exercise;
    [self performSegueWithIdentifier:@"showExerciseDetails" sender:nil];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.isInEditingMode;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.isInEditingMode;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id objectToMove = [self.workouts objectAtIndex:sourceIndexPath.row];
    [self.workouts removeObjectAtIndex:sourceIndexPath.row];
    [self.workouts insertObject:objectToMove atIndex:destinationIndexPath.row];
    [tableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.workouts removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
    }
}

#pragma mark - WorkoutTableViewCellDelegate

- (void)detailButtonPressedTableViewCell:(WorkoutSelectorTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.trainingTableView indexPathForCell:cell];
    [self.trainingTableView beginUpdates];
    
    if (!self.workoutIsExpended)
    {
        //expand new cells
        [self expandCellsForIndexPath:indexPath andTableView:self.trainingTableView andAnimation:UITableViewRowAnimationAutomatic];
        
    }
    else if(self.workoutIsExpended && indexPath.row == self.exepandedCellIndex) //cell is expanded and is taped once again - delete rows
    {
        self.workoutIsExpended = NO;
        [self.trainingTableView deleteRowsAtIndexPaths:self.expandedCellPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if(self.workoutIsExpended) // cell is expanded - another cell is taped - remove expanded cell and expand cells of new workout
    {
        //calculate new indexpath
        NSIndexPath *newIndexPath;
        UITableViewRowAnimation animation;
        if (indexPath.row > self.exepandedCellIndex)
        {
            newIndexPath = [NSIndexPath indexPathForRow:indexPath.row - self.shownExerciseCellsCount inSection:0];
            animation = UITableViewRowAnimationTop;
        }
        else
        {
            newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            animation = UITableViewRowAnimationBottom;
        }
        
        //remove expanded cells
        [self.trainingTableView deleteRowsAtIndexPaths:self.expandedCellPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
        //expand new cells
        [self expandCellsForIndexPath:newIndexPath andTableView:self.trainingTableView andAnimation :UITableViewRowAnimationAutomatic];
    }
    
    [self.trainingTableView endUpdates];
    
    
}

- (void)expandCellsForIndexPath:(NSIndexPath *)indexPath andTableView:(UITableView *)tableView andAnimation:(UITableViewRowAnimation)animation
{
    self.workoutIsExpended = YES;
    self.exepandedCellIndex  = indexPath.row;
    self.exerciseCellStartIndex = indexPath.row+1;
    Training *workout = self.workouts[self.exepandedCellIndex];
    NSArray *exerciseMetaMappings = [workout.exerciseMetaMappings array];
    self.exerciseCellStopIndex =  self.exerciseCellStartIndex + exerciseMetaMappings.count;
    self.shownExerciseCellsCount = exerciseMetaMappings.count;
    
    self.expandedCellPaths = nil;
    self.expandedCellPaths = [[NSMutableArray alloc] init];
    for (NSInteger i = self.exerciseCellStartIndex; i < self.exerciseCellStopIndex ; i++)
    {
        [self.expandedCellPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    //insert cells
    [tableView insertRowsAtIndexPaths:self.expandedCellPaths withRowAnimation:animation];
}

#pragma mark Swipe Delegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return YES;
}


-(void) swipeTableCell:(MGSwipeTableCell*) cell didChangeSwipeState:(MGSwipeState)state gestureIsActive:(BOOL)gestureIsActive
{
    NSString * str;
    switch (state) {
        case MGSwipeStateNone: str = @"None"; break;
        case MGSwipeStateSwippingLeftToRight: str = @"SwippingLeftToRight"; break;
        case MGSwipeStateSwippingRightToLeft: str = @"SwippingRightToLeft"; break;
        case MGSwipeStateExpandingLeftToRight: str = @"ExpandingLeftToRight"; break;
        case MGSwipeStateExpandingRightToLeft: str = @"ExpandingRightToLeft"; break;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showWorkoutPlan"])
    {
        if ([self.selectedWorkout.exerciseMetaMappings array].count == 0) {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"Workout_is_empty_warning_title", nil)
                                          message:NSLocalizedString(@"Workout_is_empty_warning_text", nil)
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
        else
        {
            UINavigationController *nav = [segue destinationViewController];
            //start watchdog of exercise execution
            [[WorkoutExecutionWatchdog sharedWatchdog] initStatusesForTraining:self.selectedWorkout];
            
            WorkoutExecutionRootViewController *rootViewContoller = (WorkoutExecutionRootViewController *)nav.topViewController;
            rootViewContoller.workout = self.selectedWorkout;
        }
    }
    else if ([segue.identifier isEqualToString:@"showEditWorkoutScreen"])
    {
        ExercisesModificationViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.workout = self.selectedWorkout;
    }
    else if ([segue.identifier isEqualToString:@"showExerciseDetails"])
    {
        ExerciseDescriptionViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.exercise = self.selectedExercise;
    }
    else if ([segue.identifier isEqualToString:@"showUpdateNotes"])
    {
        WhatsNewViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.delegate = self;
    }
    
}

@end
