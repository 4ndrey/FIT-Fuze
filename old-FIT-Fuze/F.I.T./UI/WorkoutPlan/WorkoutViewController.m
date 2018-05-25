//
//  WorkoutViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 24.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "WorkoutViewController.h"
#import "ExerciseDetailCollectionViewCell.h"
#import "UIColor+FIT.h"
#import "ExerciseBottomView.h"
#import "ExerciseDescriptionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "EditSetActionSheetPickerDelegate.h"
#import "SettingsViewController.h"
#import "CurrentFitManager.h"
#import "TopWorkoutViewController.h"
#import "AddEditSetViewController.h"
#import "WorkoutExecutionWatchdog.h"
#import "TopWorkoutCollectionViewController.h"
@import MagicalRecord;
#import "SizeHelper.h"

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface WorkoutViewController () <TopWorkoutViewControllerDelegate, AddEditSetViewControllerDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *startExerciseButton;
@property (weak, nonatomic) IBOutlet ExerciseBottomView *exerciseBottomView;
@property (weak, nonatomic) IBOutlet UIButton *minusTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *plusTimeButton;
@property (weak, nonatomic) IBOutlet UILabel *remainingTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UIView *middleViewBackground;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *editSetButton;
@property (weak, nonatomic) IBOutlet UILabel *setIsFinishedLabel;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UIButton *restartButton;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (weak, nonatomic) IBOutlet UIButton *succeedButton;
@property (weak, nonatomic) IBOutlet UIButton *failureButton;
@property (weak, nonatomic) IBOutlet UILabel *setInProgressLabel;
@property (weak, nonatomic) IBOutlet UILabel *setNotYetExecutedLabel;
@property (weak, nonatomic) IBOutlet UILabel *pauseBeforeSetLabel;
@property (weak, nonatomic) IBOutlet UILabel *pauseBeforeSetNotificationsRequestLabel;
@property (weak, nonatomic) IBOutlet UIButton *editFinishedSetButton;
@property (weak, nonatomic) IBOutlet UILabel *setWasImplementedLabel;
@property (weak, nonatomic) IBOutlet UIButton *editFinishedLastSetButton;
@property (weak, nonatomic) IBOutlet UIButton *goToNextExerciseButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *startWelcomeLabel;  //NEW
@property (weak, nonatomic) IBOutlet UIView *collectionTopContainer;
@property (weak, nonatomic) IBOutlet UIView *oneAndOnlyTopContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topContainerLeadingConstraint; //NEW

@property (nonatomic) NSInteger activeExercise;
@property (nonatomic) NSInteger activeSet;
@property (assign, nonatomic) BOOL failedButtonPressed;
@property (assign, nonatomic) BOOL addButtonPressed;
@property (assign, nonatomic) int addEditExerciseIndex;

@property (nonatomic, strong) NSTimer *restTimer;
@property (nonatomic) NSInteger restTime;
@property (nonatomic, strong) NSDate *restTimeEndDate;

@property (nonatomic, strong) NSTimer *activeSetTimer;
@property (nonatomic) NSInteger activeSetTime;
@property (nonatomic, strong) NSDate *activeSetBeginTimeDate;

@property (nonatomic) ExerciseSetState currentSetState;
@property (nonatomic) NSInteger selectedRowForEditMode;
@property (nonatomic) BOOL scrollToNextSetAfterReturningFromEditMode;
@property (nonatomic) BOOL initialCollectionViewOffsetWasSet;
@property (nonatomic) NSMutableArray *successStatesArray; //0 is emtpy, 1 is successful, 2 is failed
@property (nonatomic) BOOL exerciseFinished;

@property (weak, nonatomic) IBOutlet UIView *notificationOverlayView;
@property (weak, nonatomic) IBOutlet UILabel *notificationOverlayLabel;
@property (weak, nonatomic) IBOutlet UIButton *notificationOverlayOkButton;

@property (weak, nonatomic) IBOutlet UIButton *editFirstSetButton; //NEW
@property (weak, nonatomic) IBOutlet UIButton *skipExerciseButton; //NEW
@property (weak, nonatomic) IBOutlet UILabel *superSetIndicatorLabel; //NEW

@end

@implementation WorkoutViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupLocalizations];
    [self setupDefaultStates];
    [self setupSetStates];
    [self setupViews];
    //[self updateStatusesFromWatchdog];
    
    self.topViewHeightConstraint.constant = [SizeHelper workoutCollectionViewHeight];
    [self.view layoutIfNeeded];

    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"Finish" style:UIBarButtonItemStylePlain target:self action:@selector(actionBack:)];
    ((UIViewController *)self.delegate).navigationItem.leftBarButtonItem = left;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusesFromWatchdog) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusesFromWatchdog) name:@"FITConnectionUpdateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAllTimers) name:@"WorkoutTimersInvalidate" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self saveStatus:ExerciseExecutionStatusInProgress];
    self.editFinishedLastSetButton.hidden = NO;
    self.editFinishedSetButton.hidden = YES;
    self.goToNextExerciseButton.hidden = NO;
    
    //return from other viewcontroller - set correct offset for active cell
    if (self.initialCollectionViewOffsetWasSet)
    {
        NSIndexPath *currentCellPath = [NSIndexPath indexPathForItem:self.activeSet inSection:0];
        [self centerAHorizontallyCellAtIndexPath:currentCellPath];
        self.exerciseBottomView.exerciseSetState = self.currentSetState;
    }
    self.initialCollectionViewOffsetWasSet = YES;
    
    BOOL isSignallingAllowed = ([[UIApplication sharedApplication] currentUserNotificationSettings].types & UIUserNotificationTypeSound) != 0;
    BOOL alertWasShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"notificationAllowanceRequestShown"];
    if (!isSignallingAllowed && !alertWasShown) {
        //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notificationAllowanceRequestShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self showNotificationsInvitation];
    }
    
    if (!isSignallingAllowed && alertWasShown) {
        self.pauseBeforeSetNotificationsRequestLabel.hidden = NO;
        self.pauseBeforeSetLabel.hidden = YES;
    }
}

- (void)stopAllTimers {
    [self.restTimer invalidate];
    self.restTimer = nil;
}

- (void)updateStatusesFromWatchdog {
    if (self.isViewLoaded && self.view.window) {
        ExerciseMetaMapping *generalExerciseMetaMapping = self.exerciseMetaMappings[0];
        Exercise *exercise = generalExerciseMetaMapping.exercise;
        ExerciseMeta *exerciseMeta = generalExerciseMetaMapping.exerciseMeta;
        
        NSArray *results = [[WorkoutExecutionWatchdog sharedWatchdog] resultsForExercise:exercise];
        
        if(self.successStatesArray.count == 0) {
            for (int i = 0; i < generalExerciseMetaMapping.exerciseMeta.sets.count; i++)
            {
                [self.successStatesArray addObject:@(ExerciseSuccessStateEmpty)];
            }
        }
        
        for(int i = 0; i<results.count; i++) {
            NSDictionary *result = results[i];
            WorkoutSet *currentSet = [exerciseMeta.sets array][i];
            if(([result[@"reps"] integerValue] == currentSet.repetitions.integerValue) && ([result[@"weight"] integerValue] == currentSet.weights.integerValue)) {
                [self.successStatesArray replaceObjectAtIndex:i withObject:@(ExerciseStateSuccessSuccessful)];
            } else {
                [self.successStatesArray replaceObjectAtIndex:i withObject:@(ExerciseStateSuccessFailed)];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.initialCollectionViewOffsetWasSet = YES;
            
            for(long i = self.activeSet; i<results.count; i++){
                NSIndexPath *cellPath = [NSIndexPath indexPathForItem:i inSection:0];
                ExerciseDetailCollectionViewCell *cell = (ExerciseDetailCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:cellPath];
                cell.successState = [self.successStatesArray[i] integerValue];
                cell.active = NO;
            }
            
            ExerciseMetaMapping *exerciseMetaMapping = self.exerciseMetaMappings[0];
            if(results.count < (exerciseMetaMapping.exerciseMeta.sets.count)) {
                self.activeSet = results.count;
                
                NSIndexPath *currentCellPath = [NSIndexPath indexPathForItem:self.activeSet inSection:0];
                //set cell for current set to state active
                ExerciseDetailCollectionViewCell *cell = (ExerciseDetailCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:currentCellPath];
                cell.active = YES;
                
                [self scrollToActiveSet];
            } else {
                NSIndexPath *oldCellPath = [NSIndexPath indexPathForItem:self.activeSet inSection:0];
                ExerciseDetailCollectionViewCell *cell = (ExerciseDetailCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:oldCellPath];
                cell.active = NO;
                
                self.exerciseFinished = YES;
                [self saveStatus:ExerciseExecutionStatusFinished];
                
                self.selectedRowForEditMode = self.activeSet;
                self.currentSetState = ExerciseSetStatePreviousSet;
                self.activeSet++;
                [self goToNextExercise];
            }

        });
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    ExerciseMetaMapping *mapping = self.exerciseMetaMappings[0];
    if([[WorkoutExecutionWatchdog sharedWatchdog] statusForExercise:mapping.exercise] == ExerciseExecutionStatusInProgress) {
        [self saveStatus:ExerciseExecutionStatusNotDone];
    }
}

- (void)dealloc
{
    [self.activeSetTimer invalidate];
    [self.restTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    self.activeSetTimer = nil;
    self.restTimer = nil;
}


#pragma mark - setups

- (void)setupSetStates {
    //setup success states array
    //0 is emtpy, 1 is successful, 2 is failed
    ExerciseMetaMapping *generalExerciseMetaMapping = self.exerciseMetaMappings[0];
    if(generalExerciseMetaMapping) {
        self.successStatesArray = [[NSMutableArray alloc] init]; //one set/superset - one state
        for (int i = 0; i < generalExerciseMetaMapping.exerciseMeta.sets.count; i++)
        {
            [self.successStatesArray addObject:@(ExerciseSuccessStateEmpty)];
        }
    }
}

- (void)setupDefaultStates {
    self.failedButtonPressed = NO;
    self.addButtonPressed = NO;
    self.activeSet = 0;
    self.selectedRowForEditMode = 0;
    self.currentSetState = ExerciseSetStateStarting;
}

- (void)setupLocalizations
{
    //localizations
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"StartButton_Title",nil) attributes:@{
                                                                                                                           NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:22],
                                                                                                                           NSForegroundColorAttributeName : [UIColor mainColor],
                                                                                                                           }];
    [self.startButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    attributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"EditSetButton_Title",nil) attributes:@{
                                                                                                                             NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:22],
                                                                                                                             NSForegroundColorAttributeName : [UIColor mainColor],
                                                                                                                             }];
    [self.editFirstSetButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    
    attributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"SkipSetButton_Title",nil) attributes:@{
                                                                                                                             NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:22],
                                                                                                                             NSForegroundColorAttributeName : [UIColor mainColor],
                                                                                                                             }];
    [self.skipExerciseButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    self.skipExerciseButton.titleLabel.minimumScaleFactor = 0.5;
    
    attributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"EditSetButton_Title",nil) attributes:@{
                                                                                                                             NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:22],
                                                                                                                             NSForegroundColorAttributeName : [UIColor mainColor],
                                                                                                                             }];
    [self.editSetButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    attributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"FinishButton_Title",nil) attributes:@{
                                                                                                                            NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:22],
                                                                                                                            NSForegroundColorAttributeName : [UIColor mainColor],
                                                                                                                            }];
    [self.finishButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    attributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"RestartButton_Title",nil) attributes:@{
                                                                                                                             NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:22],
                                                                                                                             NSForegroundColorAttributeName : [UIColor mainColor],
                                                                                                                             }];
    [self.restartButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    attributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"SucceedButton_Title",nil) attributes:@{
                                                                                                                             NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:22],
                                                                                                                             NSForegroundColorAttributeName : [UIColor colorWithRed:92/255.0f green:224/255.0f blue:127/255.0f alpha:1.0],
                                                                                                                             }];
    [self.succeedButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    attributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"FailureButton_Title",nil) attributes:@{
                                                                                                                             NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:22],
                                                                                                                             NSForegroundColorAttributeName : [UIColor colorWithRed:255/255.0f green:127/255.0f blue:0/255.0f alpha:1.0],
                                                                                                                             }];
    [self.failureButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    attributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"EditImplementedSetButton_Label_Text", nil) attributes:@{
                                                                                                                                              NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:22],
                                                                                                                                              NSForegroundColorAttributeName : [UIColor mainColor],
                                                                                                                                              }];
    [self.editFinishedSetButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    attributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"EditImplementedSetButton_Label_Text", nil) attributes:@{
                                                                                                                                              NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:20],
                                                                                                                                              NSForegroundColorAttributeName : [UIColor mainColor],
                                                                                                                                              }];
    [self.editFinishedLastSetButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    
    NSString *goToNextTitle = NSLocalizedString(@"ContinueWorkoutButton_Label_Text", nil);
    if (goToNextTitle.length > 8) {
        attributedString = [[NSAttributedString alloc] initWithString:goToNextTitle attributes:@{
                                                                                                 NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:19.5],
                                                                                                 NSForegroundColorAttributeName : [UIColor mainColor],
                                                                                                 NSKernAttributeName : @(-0.3f)
                                                                                                 }];
    } else {
        attributedString = [[NSAttributedString alloc] initWithString:goToNextTitle attributes:@{
                                                                                                 NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:19.5],
                                                                                                 NSForegroundColorAttributeName : [UIColor mainColor]
                                                                                                 }];
    }
    
    [self.goToNextExerciseButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    self.setIsFinishedLabel.text = NSLocalizedString(@"SetIsFinished_Label_Text", nil);
    self.orLabel.text = NSLocalizedString(@"Or_Label_Text", nil);
    self.setInProgressLabel.text = NSLocalizedString(@"SetInProgress_Label_Text", nil);
    self.setNotYetExecutedLabel.text = NSLocalizedString(@"SetNotYetImplemented_Label_Text", nil);
    self.setIsFinishedLabel.text = NSLocalizedString(@"SetIsFinished_Label_Text", nil);
    self.setWasImplementedLabel.text = NSLocalizedString(@"SetImplemented_Label_Text", nil);
    self.pauseBeforeSetLabel.text = NSLocalizedString(@"PauseBeforeSet_Label_Text", nil);
    self.pauseBeforeSetNotificationsRequestLabel.text = NSLocalizedString(@"PauseBeforeSet_Allow_Notifications_Text", nil);
    self.startWelcomeLabel.text = NSLocalizedString(@"AreYouReady_WelcomeText", nil);
    self.superSetIndicatorLabel.text = NSLocalizedString(@"Superset_IndicatorText", nil);
    
    self.notificationOverlayLabel.text = NSLocalizedString(@"Overlay_Allow_Notifications_Text", nil);
}

- (void)setupViews
{
    self.middleViewBackground.layer.borderColor = [UIColor colorWithRed:206/255.0f green:226/255.0f blue:233/255.0f alpha:1.0].CGColor;
    self.middleViewBackground.layer.borderWidth = 1.0f;
    [self addGradientToCollectionView];
    
    //setup rounded corners
    self.startExerciseButton.layer.cornerRadius = 3;
    self.succeedButton.layer.cornerRadius = 3;

    //add long press gesture
    UILongPressGestureRecognizer *btn_LongPress_gesture = [[UILongPressGestureRecognizer alloc]
                                                           initWithTarget:self action:@selector(minusTimeButtonPressedAndHold:)];
    [self.minusTimeButton addGestureRecognizer:btn_LongPress_gesture];
    
    //set inital offset for collectionview
    
    CGFloat cellWidth = [self getCellWidth];

    CGFloat collectionViewWidth = CGRectGetWidth(self.view.frame);
    [self.collectionView setContentInset:UIEdgeInsetsMake(0, collectionViewWidth / 2 - cellWidth / 2, 0, collectionViewWidth / 2)];
    
    if(self.exerciseMetaMappings.count == 1) {
        self.collectionTopContainer.alpha = 0;
        self.collectionTopContainer.userInteractionEnabled = NO;
        self.oneAndOnlyTopContainer.alpha = 1;
        self.oneAndOnlyTopContainer.userInteractionEnabled = YES;
        self.superSetIndicatorLabel.hidden = YES;
    } else {
        self.collectionTopContainer.alpha = 1;
        self.collectionTopContainer.userInteractionEnabled = YES;
        self.oneAndOnlyTopContainer.alpha = 0;
        self.oneAndOnlyTopContainer.userInteractionEnabled = NO;
        self.superSetIndicatorLabel.hidden = NO;
    }
    
    if(self.exerciseMetaMappings.count == 2) {
        self.topContainerLeadingConstraint.constant = [SizeHelper topContainerLeadingConstantForTwo];
    }
}

- (CGFloat)getCellWidth {
    CGFloat cellWidth;
    NSUInteger numberOfExercisesInSet = self.exerciseMetaMappings.count;

    switch(numberOfExercisesInSet)
    {
        case 1: { cellWidth = 98; break; }
        case 2: { cellWidth = 165; break; }
        case 3: { cellWidth = 220; break; }
        case 4: { cellWidth = 250; break; }
        default: { cellWidth = 250; break; }
    }
    
    return cellWidth;
}

- (void)addGradientToCollectionView
{
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    maskLayer.bounds = self.view.layer.bounds;
    maskLayer.anchorPoint = CGPointZero;
    CGColorRef outerAlpha = [UIColor colorWithWhite:1.0 alpha:0.1].CGColor;
    CGColorRef fullAlpha = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
    maskLayer.colors = @[(__bridge id) outerAlpha, (__bridge id) fullAlpha, (__bridge id) fullAlpha, (__bridge id) outerAlpha];
    maskLayer.startPoint = CGPointMake(0.0f, 0.5f);
    maskLayer.endPoint = CGPointMake(1.0f, 0.5f);
    
    CGFloat fullWidth = maskLayer.bounds.size.width;
    CGFloat leftPercent = 15 / fullWidth;
    CGFloat rightPercent = 1.0f - 15 / fullWidth;
    NSArray *locations = @[@(0.0f), @(leftPercent), @(rightPercent), @(1.0f)];
    
    maskLayer.locations = locations;
    self.middleView.layer.mask = maskLayer;
}


#pragma mark - tutorials and notifications setup

- (void)showNotificationsInvitation {
    self.notificationOverlayView.alpha = 0;
    self.notificationOverlayView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.notificationOverlayView.alpha = 1;
    } completion:nil];
}

#pragma mark - internal actions

- (void)actionBack:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention!" message:@"Your current workout progress would be lost. Are you sure you want to finish it and go to menu?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [((UIViewController *)self.delegate).navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - State processing

- (void)setCurrentSetState:(ExerciseSetState)currentSetState
{
    _currentSetState = currentSetState;
    self.exerciseBottomView.exerciseSetState = _currentSetState;
}

- (void)setSuccessStateForFinishedSet:(BOOL)success
{
    //set cell for current set succeess image or fail image
    NSIndexPath *currentCellPath = [NSIndexPath indexPathForItem:self.activeSet inSection:0];
    ExerciseDetailCollectionViewCell *cell = (ExerciseDetailCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:currentCellPath];
    cell.successState = success ? ExerciseStateSuccessSuccessful : ExerciseStateSuccessFailed;
    [self.successStatesArray replaceObjectAtIndex:self.activeSet withObject:@(cell.successState)];
}

#pragma mark - Internal

- (void)saveStatus:(ExerciseExecutionStatusType)status {
    for(ExerciseMetaMapping *mapping in self.exerciseMetaMappings) {
        [[WorkoutExecutionWatchdog sharedWatchdog] setStatus:status forExercise:mapping.exercise];
    }
}

- (void)startCurrentSet
{
    //set state to doing exercise for the bottom view
    self.currentSetState = ExerciseSetStateDoingExercise;
    
    //start set timer
    self.activeSetTime = 0;
    self.activeSetBeginTimeDate = self.restTimeEndDate ? : [NSDate date];
    
    [self.activeSetTimer invalidate];
    self.activeSetTimer = nil;
    self.activeSetTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                       target: self
                                                     selector: @selector(updateSetTimerLabel)
                                                     userInfo: nil
                                                      repeats: YES];
    [self.activeSetTimer fire];
}

- (void)updateSetTimerLabel
{
    self.activeSetTime++;
    self.exerciseBottomView.timeInExercise = -[self.activeSetBeginTimeDate timeIntervalSinceNow];
}

- (void)scrollToNextSet
{
    //set cell for old set to state inactive
    NSIndexPath *oldCellPath = [NSIndexPath indexPathForItem:self.activeSet inSection:0];
    ExerciseDetailCollectionViewCell *cell = (ExerciseDetailCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:oldCellPath];
    cell.active = NO;

    // increase set + scroll to next cell, then start the set
    self.activeSet++;
    NSIndexPath *currentCellPath = [NSIndexPath indexPathForItem:self.activeSet inSection:0];
    [self centerAHorizontallyCellAtIndexPath:currentCellPath];
    
    //set cell for current set to state active
    cell = (ExerciseDetailCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:currentCellPath];
    cell.active = YES;
}

- (void)scrollToActiveSet
{
    NSIndexPath *currentCellPath = [NSIndexPath indexPathForItem:self.activeSet inSection:0];
    [self centerAHorizontallyCellAtIndexPath:currentCellPath];
    self.exerciseBottomView.exerciseSetState = self.currentSetState;
    self.exerciseFinished = NO;
}

- (void)startPauseTimer
{
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    self.restTime = [[sharedDefaults objectForKey:restTimeKey] integerValue];
    self.restTimeEndDate = [NSDate dateWithTimeIntervalSinceNow:self.restTime];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    
    notif.fireDate = [NSDate dateWithTimeIntervalSinceNow:self.restTime-4];
    notif.timeZone = [NSTimeZone defaultTimeZone];
    notif.alertBody = NSLocalizedString(@"Timer done!", nil);
    notif.soundName = @"timerEnd.caf";
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
    
    [self.restTimer invalidate];
    self.restTimer = nil;
    self.restTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                       target: self
                                                     selector: @selector(udpdatePauseTimeLabel)
                                                     userInfo: nil
                                                      repeats: YES];
    [self.restTimer fire];
}

- (void)udpdatePauseTimeLabel
{
    if (self.restTime == 4) {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"timerEnd" ofType:@"caf"];
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
        AudioServicesPlaySystemSound (soundID);
    }
    if (self.restTime <= 0)
    {
        [self.restTimer invalidate];
        self.restTimer = nil;
        
        //start next set
        [self startCurrentSet];
    }
    else
    {
        self.restTime = [self.restTimeEndDate timeIntervalSinceNow];
        [self setRemainingTimeForTimeLabel];
    }
}

- (void)setRemainingTimeForTimeLabel
{
    double seconds = fmod(self.restTime, 60.0);
    double minutes = fmod(trunc(self.restTime / 60.0), 60.0);
    self.remainingTimeLabel.text = [NSString stringWithFormat:@"%01.0f:%02.0f", minutes, seconds];
}


#pragma mark - IBActions

- (IBAction)hideNotificationOverlay:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.notificationOverlayView.alpha = 0;
    } completion: ^(BOOL finished) {
        self.notificationOverlayView.hidden = YES;
    }];
    
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
}

- (IBAction)skipButtonPressed:(id)sender {
    [self saveStatus:ExerciseExecutionStatusSkipped];
    [self.delegate goToNextExercise];
}

- (IBAction)startExerciseButtonPressed:(id)sender
{
    [self saveStatus:ExerciseExecutionStatusInProgress];
    
    if ([self.collectionView numberOfItemsInSection:0] == 1) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:NSLocalizedString(@"AlertView_No_Sets", nil)
                                      message:NSLocalizedString(@"AlertView_No_Sets_warning", nil)
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
        return;
    }
    //set cell for current set to state active
    ExerciseDetailCollectionViewCell *cell = (ExerciseDetailCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.activeSet inSection:0]];
    cell.active = YES;
    
    //start set
    [self startCurrentSet];
}

- (IBAction)succeedButtonPressed:(id)sender
{
    [self setSuccessStateForFinishedSet:YES];
    
    //save statistic
    for(ExerciseMetaMapping *exerciseMetaMapping in self.exerciseMetaMappings) {
        ExerciseMeta *exerciseMeta = exerciseMetaMapping.exerciseMeta;
        Exercise *currentExercise = exerciseMetaMapping.exercise;
        WorkoutSet *currentSet = [exerciseMeta.sets array][self.activeSet];        
        
        [[WorkoutExecutionWatchdog sharedWatchdog] saveResultForExerciseWithName:currentExercise.name withWeight:[currentSet.weights integerValue] andReps:[currentSet.repetitions integerValue]];
    }
    
    ExerciseMetaMapping *exerciseMetaMapping = self.exerciseMetaMappings[0];
    if (self.activeSet >= (exerciseMetaMapping.exerciseMeta.sets.count - 1))
    {
        //set cell for old set to state inactive
        NSIndexPath *oldCellPath = [NSIndexPath indexPathForItem:self.activeSet inSection:0];
        ExerciseDetailCollectionViewCell *cell = (ExerciseDetailCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:oldCellPath];
        cell.active = NO;
        
        self.exerciseFinished = YES;
        [self saveStatus:ExerciseExecutionStatusFinished];
        
        self.selectedRowForEditMode = self.activeSet;
        self.currentSetState = ExerciseSetStatePreviousSet;
        
        return;
    } else {
        self.currentSetState = ExerciseSetStateTimer;
        [self startPauseTimer];
        [self scrollToNextSet];
    }
}

- (IBAction)goToNextExercise
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    ExerciseMetaMapping *exerciseMetaMapping = self.exerciseMetaMappings[0];

    if (self.activeSet >= (exerciseMetaMapping.exerciseMeta.sets.count -1)) {
        if (self.exerciseFinished) {
            [self saveStatus:ExerciseExecutionStatusFinished];
            [self.delegate goToNextExercise];
        }
        else
        {
            [self scrollToActiveSet];
        }
    }
    else
    {
        if (!self.exerciseFinished) {
            [self scrollToActiveSet];
        } else {
            [self scrollToNextSet];
            [self startCurrentSet];
        }
    }
}

- (IBAction)failButtonPressed:(id)sender
{
    self.failedButtonPressed = YES;
    //save indexpath row for updatin cell after returning from edit popover
    self.selectedRowForEditMode = self.activeSet;

    //scroll to next set after returning from edit mode
    self.scrollToNextSetAfterReturningFromEditMode = YES;
    [self performSegueWithIdentifier:@"createEditSetSegueID" sender:self];
}

- (IBAction)minusTimeButtonPressed:(id)sender
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    if (self.restTime < 16) {
        self.restTimeEndDate = [NSDate date];
        self.restTime = 0;
    } else {
        self.restTime = self.restTime - 15;
        self.restTimeEndDate = [self.restTimeEndDate dateByAddingTimeInterval:-15];
        
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        notif.fireDate = [NSDate dateWithTimeIntervalSinceNow:self.restTime-4];
        notif.timeZone = [NSTimeZone defaultTimeZone];
        notif.alertBody = @"Timer done!";
        notif.soundName = @"timerEnd.caf";
        [[UIApplication sharedApplication] scheduleLocalNotification:notif];
    }

    [self setRemainingTimeForTimeLabel];
}

- (IBAction)minusTimeButtonPressedAndHold:(id)sender
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    self.restTime = 0;
    self.restTimeEndDate = [NSDate date];
    [self setRemainingTimeForTimeLabel];
}

- (IBAction)plusButtonTimePressed:(id)sender
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    self.restTime += 15;
    self.restTimeEndDate = [self.restTimeEndDate dateByAddingTimeInterval:15];
    [self setRemainingTimeForTimeLabel];
    
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    notif.fireDate = [NSDate dateWithTimeIntervalSinceNow:self.restTime-4];
    notif.timeZone = [NSTimeZone defaultTimeZone];
    notif.alertBody = @"Timer done!";
    notif.soundName = @"timerEnd.caf";
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
}

- (IBAction)finishSetButtonPressed:(id)sender
{
    //invalidete set timer
    [self.activeSetTimer invalidate];
    self.activeSetTimer = nil;
    
    //update setState
    self.currentSetState = ExerciseSetStateExerciseFinished;
}

- (IBAction)resetSetButtonPressed:(id)sender
{
    [self.activeSetTimer invalidate];
    self.activeSetTimer = nil;
    self.activeSetBeginTimeDate = [NSDate dateWithTimeIntervalSinceNow:0];
    self.activeSetTime = 0;
    self.activeSetBeginTimeDate = [NSDate dateWithTimeIntervalSinceNow:0];
    self.activeSetTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                           target: self
                                                         selector: @selector(updateSetTimerLabel)
                                                         userInfo: nil
                                                          repeats: YES];
    [self.activeSetTimer fire];
}

- (IBAction)editSetButtonPressed:(id)sender
{
    self.scrollToNextSetAfterReturningFromEditMode = NO;
    if(self.exerciseMetaMappings.count > 1) {
        self.addEditExerciseIndex = 0;
        [self performSegueWithIdentifier:@"createEditSetSegueID" sender:self];
    } else {
        [self showEditSetActionSheetFromSender:sender];
    }
}

#pragma mark - UICollectionViewDataSource Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.delegate disableScrolling];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self.delegate enableScrolling];
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    ExerciseMetaMapping *exerciseMetaMapping = self.exerciseMetaMappings[0];
    ExerciseMeta *exerciseMeta = exerciseMetaMapping.exerciseMeta;
    NSArray *collectionViewArray = [exerciseMeta.sets array];
    return collectionViewArray.count + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ExerciseDetailCollectionViewCell *cell;
    if (indexPath.row == [self.collectionView numberOfItemsInSection:0]-1) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddSetCollectionViewCell" forIndexPath:indexPath];
        return cell;
    }
    else
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
        [cell setupWithExerciseMetaMappings:self.exerciseMetaMappings withIndexPath:indexPath isActive:(self.activeSet == indexPath.row && !self.exerciseFinished)];
        cell.active = (self.activeSet == indexPath.row && !self.exerciseFinished);
        cell.successState = [self.successStatesArray[indexPath.row] integerValue];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ExerciseMetaMapping *mapping = self.exerciseMetaMappings[0];
    ExerciseMeta *exerciseMeta = (ExerciseMeta *)mapping.exerciseMeta;
    NSArray *sets = [exerciseMeta.sets array];
    
    if(indexPath.row >= sets.count)
    {
        return CGSizeMake(86, 86);
    }
    
    return CGSizeMake([self getCellWidth], 86);
}

#pragma mark - UICollectionViewDelegate Methods

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        CGRect f = self.collectionView.frame;
        NSIndexPath *currentCellPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(self.collectionView.contentOffset.x + self.view.frame.size.width/2, f.origin.y + f.size.height/2)];
        if (!currentCellPath) {
            if (self.collectionView.contentOffset.x > self.collectionView.frame.size.width/2) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(MAX(0, [self.collectionView numberOfItemsInSection:0] - 1)) inSection:0];
                [self centerAHorizontallyCellAtIndexPath:indexPath];
                self.exerciseBottomView.exerciseSetState = ExerciseSetStateEmtpy;
            }
            else {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
            }
            return;
        }
        [self collectionView:self.collectionView didSelectItemAtIndexPath:currentCellPath];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGRect f = self.collectionView.frame;
    NSIndexPath *currentCellPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(self.collectionView.contentOffset.x + self.view.frame.size.width/2, f.origin.y + f.size.height/2)];
    if (!currentCellPath) {
        if (self.collectionView.contentOffset.x > self.collectionView.frame.size.width/2) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(MAX(0, [self.collectionView numberOfItemsInSection:0] - 1)) inSection:0];
            [self centerAHorizontallyCellAtIndexPath:indexPath];
            self.exerciseBottomView.exerciseSetState = ExerciseSetStateEmtpy;
        }
        else {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
        }
        return;
    }
    [self collectionView:self.collectionView didSelectItemAtIndexPath:currentCellPath];
    
    [self.delegate enableScrolling];
}

- (void)centerAHorizontallyCellAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *activeCell = [self.collectionView cellForItemAtIndexPath:indexPath];
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.frame);
    [self.collectionView setContentInset:UIEdgeInsetsMake(0, collectionViewWidth / 2, 0, collectionViewWidth / 2)];
    
    CGPoint offset = CGPointMake(activeCell.center.x - collectionViewWidth / 2,0);
    [self.collectionView setContentOffset:offset animated:YES];
    self.selectedRowForEditMode = indexPath.row;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self centerAHorizontallyCellAtIndexPath:indexPath];
    ExerciseMetaMapping *exerciseMetaMapping = self.exerciseMetaMappings[0];
    ExerciseMeta *exerciseMeta = exerciseMetaMapping.exerciseMeta;
    if (indexPath.row == [exerciseMeta.sets count]) {
        self.exerciseBottomView.exerciseSetState = ExerciseSetStateEmtpy;
        if(self.exerciseMetaMappings.count > 1) {
            self.addButtonPressed = YES;
            [self performSegueWithIdentifier:@"createEditSetSegueID" sender:self];
        } else {
            [self showCreateSetActionSheetFromSender:self.view];
        }
    }
    else
    {
        //exercise already finished - all sets are finsihed
        if (self.exerciseFinished)
        {
            self.exerciseBottomView.exerciseSetState = ExerciseSetStatePreviousSet;
            return;
        }
        
        //exercise not yet finished
        if (indexPath.row == self.activeSet)
        {
            self.exerciseBottomView.exerciseSetState = self.currentSetState;
        }
        else if(indexPath.row > self.activeSet)
        {
            self.exerciseBottomView.exerciseSetState = ExerciseSetStateNextSet;
        }
        else if(indexPath.row < self.activeSet)
        {
            self.exerciseBottomView.exerciseSetState = ExerciseSetStatePreviousSet;
        }
    }
}

- (void)showEditSetActionSheetFromSender:(id)sender
{
    EditSetActionSheetPickerDelegate *delg = [[EditSetActionSheetPickerDelegate alloc] init];
    
    delg.onActionSheetDone = ^(AbstractActionSheetPicker *picker, NSInteger selectedWeight, NSInteger selectedRepetition) {
        NSIndexPath *currentCellPath = [NSIndexPath indexPathForItem:self.selectedRowForEditMode inSection:0];
        ExerciseDetailCollectionViewCell *cell = (ExerciseDetailCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:currentCellPath];
        if (self.selectedRowForEditMode != self.activeSet) {
            cell.successState = ExerciseStateSuccessFailed;
            [self.successStatesArray replaceObjectAtIndex:self.selectedRowForEditMode withObject:@(cell.successState)];
        }
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.selectedRowForEditMode inSection:0]]];
        [self setEditingDoneWithRepetitions:@(selectedRepetition) weight:@(selectedWeight)];
    };
    
    ExerciseMetaMapping *mm = self.exerciseMetaMappings[0];
    ExerciseMeta *exerciseMeta = (ExerciseMeta *)mm.exerciseMeta;
    WorkoutSet *exerciseSet = [exerciseMeta.sets array][self.selectedRowForEditMode];
    
    NSNumber *selectedWeight = @([exerciseSet.weights integerValue]);
    NSNumber *selectedRepetition = @([exerciseSet.repetitions integerValue]-1);
    
    delg.selectedWeight = [NSString stringWithFormat:@"%@",@([selectedWeight integerValue])];
    delg.selectedRepetitions = [NSString stringWithFormat:@"%@",@([selectedRepetition integerValue]+1)];
    
    NSArray *initialSelections = @[selectedWeight, selectedRepetition];
    ActionSheetCustomPicker *customPicker = [[ActionSheetCustomPicker alloc] initWithTitle:NSLocalizedString(@"WeightRepetitions_PickerView_Label", nil) delegate:delg showCancelButton:YES origin:sender initialSelections:initialSelections];
    
    
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
    
    [customPicker setDoneButton:doneButton];
    [customPicker setCancelButton:cancelButton];
    [customPicker showActionSheetPicker];
    
    UIView *overlay = [[UIView alloc] initWithFrame:customPicker.pickerView.frame];
    overlay.backgroundColor = [UIColor clearColor];
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    NSString *kgOrLbls = [[sharedDefaults objectForKey:kilogrammChoosenKey] boolValue] ? NSLocalizedString(@"kg", nil) : NSLocalizedString(@"lbs", nil);
    UILabel *weightLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 54, 40, 30)];
    weightLabel.text = kgOrLbls;
    weightLabel.font = [UIFont systemFontOfSize:20];
    [overlay addSubview:weightLabel];
    
    UILabel *repLabel = [[UILabel alloc] initWithFrame:CGRectMake(270, 54, 60, 30)];
    repLabel.text = NSLocalizedString(@"PickerView_Repetions_Label_Text", nil);
    repLabel.font = [UIFont systemFontOfSize:20];
    [overlay addSubview:repLabel];
    
    [customPicker.pickerView addSubview:overlay];
}

- (void)showCreateSetActionSheetFromSender:(id)sender
{
    self.addButtonPressed = YES;
    EditSetActionSheetPickerDelegate *delg = [[EditSetActionSheetPickerDelegate alloc] init];
    
    delg.onActionSheetDone = ^(AbstractActionSheetPicker *picker, NSInteger selectedWeight, NSInteger selectedRepetition) {
        
        [self setEditingDoneWithRepetitions:@(selectedRepetition) weight:@(selectedWeight)];
    };
    
    NSNumber *selectedWeight, *selectedRepetition;
    
    selectedWeight = @(10);
    selectedRepetition = @(9);
    
    delg.selectedWeight = [NSString stringWithFormat:@"%@",@([selectedWeight integerValue])];
    delg.selectedRepetitions = [NSString stringWithFormat:@"%@",@([selectedRepetition integerValue]+1)];
    
    NSArray *initialSelections = @[selectedWeight, selectedRepetition];
    ActionSheetCustomPicker *customPicker = [[ActionSheetCustomPicker alloc] initWithTitle:NSLocalizedString(@"WeightRepetitions_PickerView_Label", nil) delegate:delg showCancelButton:YES origin:sender initialSelections:initialSelections];
    
    
    UIBarButtonItem *doneButton = ({
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] init];
        doneButton.title = NSLocalizedString(@"Done_Button_Title", nil);
        [doneButton setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor blackColor], NSForegroundColorAttributeName,nil]
                                  forState:UIControlStateNormal];
        doneButton;
    });
    
    UIBarButtonItem *cancelButton = ({
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] init];
        cancelButton.title = NSLocalizedString(@"Cancel_Button_Title", nil);
        [cancelButton setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName,nil]
                                    forState:UIControlStateNormal];
        cancelButton;
    });
    
    [customPicker setDoneButton:doneButton];
    [customPicker setCancelButton:cancelButton];
    [customPicker showActionSheetPicker];
    
    UIView *overlay = [[UIView alloc] initWithFrame:customPicker.pickerView.frame];
    overlay.backgroundColor = [UIColor clearColor];
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    NSString *kgOrLbls = [[sharedDefaults objectForKey:kilogrammChoosenKey] boolValue] ? NSLocalizedString(@"kg", nil) : NSLocalizedString(@"lbs", nil);
    UILabel *weightLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 54, 40, 30)];
    weightLabel.text = kgOrLbls;
    weightLabel.font = [UIFont systemFontOfSize:20];
    [overlay addSubview:weightLabel];
    
    UILabel *repLabel = [[UILabel alloc] initWithFrame:CGRectMake(270, 54, 60, 30)];
    repLabel.text = NSLocalizedString(@"PickerView_Repetions_Label_Text", nil);
    repLabel.font = [UIFont systemFontOfSize:20];
    [overlay addSubview:repLabel];
    
    [customPicker.pickerView addSubview:overlay];
}

- (void)setEditingDoneWithRepetitions:(NSNumber *)repetitions weight:(NSNumber *)weight
{
    if (self.addButtonPressed) {
        self.addButtonPressed = NO;
        [self addSetToExerciseWithWeight:[weight integerValue] repetition:[repetitions integerValue]];
        self.exerciseFinished = NO;
        [[CurrentFitManager sharedManager] saveCurrentTraining];
        return;
    }
    
    ExerciseMetaMapping *mm = self.exerciseMetaMappings[0];
    ExerciseMeta *exerciseMeta = (ExerciseMeta *)mm.exerciseMeta;
    
    if (self.failedButtonPressed) {
        self.failedButtonPressed = NO;
        //save statistic
        for(ExerciseMetaMapping *exerciseMetaMapping in self.exerciseMetaMappings) {
            ExerciseMeta *exerciseMeta = exerciseMetaMapping.exerciseMeta;
            Exercise *currentExercise = exerciseMetaMapping.exercise;
            WorkoutSet *currentSet = [exerciseMeta.sets array][self.activeSet];
            
            [[WorkoutExecutionWatchdog sharedWatchdog] saveResultForExerciseWithName:currentExercise.name withWeight:[currentSet.weights integerValue] andReps:[currentSet.repetitions integerValue]];
        }
    }
    
    WorkoutSet *exerciseSet = [exerciseMeta.sets array][self.selectedRowForEditMode];
    exerciseSet.repetitions = repetitions;
    exerciseSet.weights = weight;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.selectedRowForEditMode inSection:0]]];
    
    if (self.scrollToNextSetAfterReturningFromEditMode)
    {
        [self setSuccessStateForFinishedSet:NO];
        
        if (self.activeSet >= ([exerciseMeta.sets count] - 1))
        {
            //set cell for old set to state inactive
            NSIndexPath *oldCellPath = [NSIndexPath indexPathForItem:self.activeSet inSection:0];
            ExerciseDetailCollectionViewCell *cell = (ExerciseDetailCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:oldCellPath];
            cell.active = NO;
            
            self.exerciseFinished = YES;
            self.selectedRowForEditMode = self.activeSet;
            self.currentSetState = ExerciseSetStatePreviousSet;
            
            return;
        }
        else
        {
            self.currentSetState = ExerciseSetStateTimer;
            [self startPauseTimer];
            [self scrollToNextSet];
        }
    }
    [[CurrentFitManager sharedManager] saveCurrentTraining];
}

- (void)addSetToExerciseWithWeight:(NSInteger)weight repetition:(NSInteger)repetitions
{
    //check if collectionView cell is add-set cell or normal cell
    ExerciseMetaMapping *mm = self.exerciseMetaMappings[0];
    ExerciseMeta *exerciseMeta = (ExerciseMeta *)mm.exerciseMeta;
    
    NSMutableArray *exerciseSets = [[exerciseMeta.sets array] mutableCopy];
    if (!exerciseSets)
    {
        exerciseSets = [[NSMutableArray alloc] init];
    }
    WorkoutSet *newSet = [NSEntityDescription insertNewObjectForEntityForName:@"WorkoutSet" inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    newSet.weights = @(weight);
    newSet.repetitions = @(repetitions);
    
    [exerciseSets addObject:newSet];
    [exerciseMeta setSets:[[NSOrderedSet alloc] initWithArray:exerciseSets]];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [self.successStatesArray addObject:@(ExerciseSuccessStateEmpty)];
    
    if (self.exerciseFinished )
    {
        self.activeSet++;
        [self startCurrentSet];
    }
    else
    {
        self.exerciseBottomView.exerciseSetState = ExerciseSetStateNextSet;
    }
    
    [self.collectionView reloadData];
    [[CurrentFitManager sharedManager] saveCurrentTraining];
}



#pragma mark - ActionSheetPickerStuff

- (void)setEditingDone
{
    if (self.addButtonPressed) {
        self.addButtonPressed = NO;
        self.exerciseFinished = NO;
        
        [self.successStatesArray addObject:@(ExerciseSuccessStateEmpty)];
        [self saveStatus:ExerciseExecutionStatusInProgress];
        if (self.exerciseFinished )
        {
            self.activeSet++;
            [self startCurrentSet];
        }
        else
        {
            self.exerciseBottomView.exerciseSetState = ExerciseSetStateNextSet;
        }
        
        [[CurrentFitManager sharedManager] saveCurrentTraining];
        [self.collectionView reloadData];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                ExerciseMetaMapping *mapping = self.exerciseMetaMappings[0];
                NSIndexPath *currentCellPath = [NSIndexPath indexPathForRow:mapping.exerciseMeta.sets.count-1 inSection:0];
                [self centerAHorizontallyCellAtIndexPath:currentCellPath];
            }];
        });

        return;
    } else {
        ExerciseMetaMapping *mm = self.exerciseMetaMappings[0];
        if(self.selectedRowForEditMode == mm.exerciseMeta.sets.count) {
            self.exerciseBottomView.exerciseSetState = ExerciseSetStateEmtpy;
        }
        [self.collectionView reloadData];   
    }
    
    if (self.failedButtonPressed) {
        self.failedButtonPressed = NO;
    }
    
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.selectedRowForEditMode inSection:0]]];

    if (self.scrollToNextSetAfterReturningFromEditMode)
    {
        [self setSuccessStateForFinishedSet:NO];
        ExerciseMetaMapping *generalMetaMapping = self.exerciseMetaMappings[0];
        
        if (self.activeSet >= ([generalMetaMapping.exerciseMeta.sets count] - 1))
        {
            //set cell for old set to state inactive
            NSIndexPath *oldCellPath = [NSIndexPath indexPathForItem:self.activeSet inSection:0];
            ExerciseDetailCollectionViewCell *cell = (ExerciseDetailCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:oldCellPath];
            cell.active = NO;
            
            self.exerciseFinished = YES;
            [self saveStatus:ExerciseExecutionStatusFinished];

            self.selectedRowForEditMode = self.activeSet;
            self.currentSetState = ExerciseSetStatePreviousSet;

            return;
        }
        else
        {
            self.currentSetState = ExerciseSetStateTimer;
            [self startPauseTimer];
            [self scrollToNextSet];
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{        NSIndexPath *currentCellPath = [NSIndexPath indexPathForRow:self.selectedRowForEditMode inSection:0];
        [self centerAHorizontallyCellAtIndexPath:currentCellPath];
        }];
    });
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showExerciseDetails"])
    {
        ExerciseDescriptionViewController *destinationViewController = [segue destinationViewController];
        ExerciseMetaMapping *exerciseMetaMapping = (ExerciseMetaMapping *)sender;
        Exercise *exercise = exerciseMetaMapping.exercise;
        destinationViewController.exercise = exercise;
    }
    
    if ([segue.identifier isEqualToString:@"createEditSetSegueID"])
    {
        UINavigationController *navController = [segue destinationViewController];
        AddEditSetViewController *destinationViewController = [[navController viewControllers] firstObject];
        destinationViewController.exerciseMetaMappings = self.exerciseMetaMappings;
        destinationViewController.delegate = self;
        destinationViewController.needSaveResults = self.failedButtonPressed;
        if(self.addButtonPressed) {
            destinationViewController.editingSetIndex = -1;
            destinationViewController.exampleWeight = 1;
            destinationViewController.exampleReps = 1;
        } else {
            destinationViewController.editingSetIndex = self.selectedRowForEditMode;
            ExerciseMetaMapping *mm = self.exerciseMetaMappings[0];
            if(mm.exerciseMeta.sets.count == 1) {
                destinationViewController.disableDelete = YES;
            }
        }
        self.initialCollectionViewOffsetWasSet = NO;
    }
    
    if([[segue destinationViewController] isKindOfClass:[TopWorkoutViewController class]]) {
        TopWorkoutViewController *vc = [segue destinationViewController];
        vc.exerciseMapping = self.exerciseMetaMappings[0];
        vc.delegate = self;
    }
    
    if([[segue destinationViewController] isKindOfClass:[TopWorkoutCollectionViewController class]]) {
        TopWorkoutCollectionViewController *vc = [segue destinationViewController];
        vc.exerciseMetaMappings = self.exerciseMetaMappings;
        vc.delegate = self.delegate;
        vc.detailsDelegate = self;
    }
}


#pragma mark - TopWorkoutViewControllerDelegate

- (void)showDetailsForExerciseMetaMapping:(ExerciseMetaMapping *)exerciseMetaMapping
{
    [self performSegueWithIdentifier:@"showExerciseDetails" sender:exerciseMetaMapping];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

@end
