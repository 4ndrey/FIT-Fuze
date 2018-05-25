//
//  WorkoutPageContainerViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 24.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "WorkoutPageContainerViewController.h"
#import "WorkoutViewController.h"
#import "WorkoutPageViewControllerDelegate.h"
#import "CurrentFitManager.h"
#import "TrainingPlanGroupSelectorViewController.h"
#import "RESideMenu.h"
#import "WSCoachMarksView.h"
#import "WorkoutExecutionWatchdog.h"
#import "DKCircleImageView.h"
#import "CurrentFitManager.h"

@import MagicalRecord;

@interface WorkoutPageContainerViewController () <WorkoutPageViewControllerDelegate, WSCoachMarksViewDelegate>

@property (nonatomic, strong) NSOrderedSet *exerciseObjects;
@property (nonatomic, strong) DKCircleImageView *touchView;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableArray *contentViewControllers;
@property (weak, nonatomic) IBOutlet UIView *workoutFinishedView;
@property (weak, nonatomic) IBOutlet UIView *trainingPlanFinishedView;
@property (weak, nonatomic) IBOutlet UILabel *workoutFinishedLabel;
@property (weak, nonatomic) IBOutlet UILabel *trainingPlanFinishedLabel;
@property (weak, nonatomic) IBOutlet UIButton *chooseNextPlanButton;
@property (strong, nonatomic) NSArray *pagingViewControllers;

@end

@implementation WorkoutPageContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.workoutFinishedLabel.text = NSLocalizedString(@"WorkoutFinished_Label_Text", nil);
    self.workoutFinishedLabel.numberOfLines = 2;
    self.workoutFinishedLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.trainingPlanFinishedLabel.text = NSLocalizedString(@"TrainingPlanFinished_Label_Text", nil);
    self.trainingPlanFinishedLabel.numberOfLines = 2;
    self.trainingPlanFinishedLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.chooseNextPlanButton setTitle:NSLocalizedString(@"ChooseNextPlan_Button_Title", nil) forState:UIControlStateNormal];
    
    self.title = self.workout.name;
    self.exerciseObjects = [[CurrentFitManager sharedManager] getOrderedSetOfExerciseObjectsForWorkout:self.workout];
    
    self.pageControl.numberOfPages = self.exerciseObjects.count;
    
    self.contentViewControllers = [[NSMutableArray alloc] init];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WorkoutPageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    //setup ContentViewController
    [self setupContentViewController];
    
    WorkoutViewController *workoutViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[workoutViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height+37);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    // Bring the common controls to the foreground (they were hidden since the frame is taller)
    [self.view bringSubviewToFront:self.pageControl];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    for (UIGestureRecognizer *recognizer in self.pageViewController.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            recognizer.enabled = NO;
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

- (void)disableScrolling
{
    for (UIScrollView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]] && ![view isKindOfClass:[UICollectionView class]]) {
            view.scrollEnabled = NO;
        }
    }
}

- (void)enableScrolling
{
    for (UIScrollView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]] && ![view isKindOfClass:[UICollectionView class]]) {
            view.scrollEnabled = YES;
        }
    }
}

/*
- (void)showTutorialCoachMarks
{
    
    int addition = ([[UIScreen mainScreen] bounds].size.width == 320.0f) ? 0 : 20;
    
    self.touchView = [[DKCircleImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.touchView.backgroundColor = [UIColor colorWithRed:88/255.0 green:183/255.0 blue:223/255.0 alpha:0.8];
    self.touchView.hidden = YES;
    [self.navigationController.view addSubview: self.touchView];

    NSArray *coachMarks = @[
                            @{
                                @"rect": [NSValue valueWithCGRect:(CGRect){{90+addition,153+addition},{45,45}}],
                                @"caption": NSLocalizedString(@"Tap_for_animated_exercise_hint", nil),
                                @"shape": @"other"
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:(CGRect){{140+addition,180+addition},{80,25}}],
                                @"caption": NSLocalizedString(@"Tap_for_exercise_details_hint", nil),
                                @"shape": @"other"
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:(CGRect){{0,206+addition},{self.view.frame.size.width,97}}],
                                @"caption": NSLocalizedString(@"Workout_execution_line_hint", nil),
                                @"shape": @"other"
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:(CGRect){{self.view.frame.size.width/2-50,206+addition},{100,97}}],
                                @"caption": NSLocalizedString(@"Current_set_hint", nil),
                                @"shape": @"other"
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:(CGRect){{self.view.frame.size.width/2-40,220+addition},{80,70}}],
                                @"caption": NSLocalizedString(@"Weight_repetitions_hint", nil),
                                @"shape": @"other"
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:(CGRect){{self.view.frame.size.width/2+20,210+addition},{30,18}}],
                                @"caption": NSLocalizedString(@"Numbers_of_sets_hint", nil),
                                @"shape": @"other"
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:(CGRect){{self.view.frame.size.width/2-15,285+addition},{30,20}}],
                                @"caption": NSLocalizedString(@"Triange_meaning_hint", nil),
                                @"shape": @"other"
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:(CGRect){{0,320},{self.view.frame.size.width, self.view.frame.size.height - 350}}],
                                @"caption": NSLocalizedString(@"Workout_status_area_hint", nil),
                                @"shape": @"other"
                                }
                            ];
    WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.view.bounds coachMarks:coachMarks];
    coachMarksView.maskColor = [UIColor colorWithWhite:0.0 alpha:0.75];
    coachMarksView.enableContinueLabel = NO;
    [self.navigationController.view addSubview:coachMarksView];
    coachMarksView.delegate = self;
    [coachMarksView start];
}

- (void)coachMarksView:(WSCoachMarksView*)coachMarksView didNavigateToIndex:(NSUInteger)index
{
    int addition = ([[UIScreen mainScreen] bounds].size.width == 320.0f) ? 0 : 20;

    if(index == 0)
    {
        self.touchView.center = CGPointMake(112+addition,175+addition);
        [self animateTapForView:self.touchView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self animateTapForView:self.touchView];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self animateTapForView:self.touchView];
        });
    }
    if(index == 1)
    {
        self.touchView.center = CGPointMake(180+addition,190+addition);
        [self animateTapForView:self.touchView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self animateTapForView:self.touchView];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self animateTapForView:self.touchView];
        });
    }
    if(index == 2)
    {
        self.touchView.hidden = NO;
        CGPoint startPoint = CGPointMake(self.view.frame.size.width/2+100, 250+addition);
        CGPoint endPoint = CGPointMake(self.view.frame.size.width/2-100, 250+addition);
        self.touchView.center = startPoint;

        [UIView animateWithDuration:1.5 animations:^{
            self.touchView.center = endPoint;
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:1.9 animations:^{
                self.touchView.center = startPoint;
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:1.9 animations:^{
                    self.touchView.center = endPoint;
                    self.touchView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    self.touchView.hidden = YES;
                }];
            }];
        }];
    }
}

*/

- (void)animateTapForView: (UIView *)view {
    
    CGRect pathFrame = CGRectMake(-CGRectGetMidX(view.bounds), -CGRectGetMidY(view.bounds), view.bounds.size.width, view.bounds.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathFrame cornerRadius:view.layer.cornerRadius];
    
    // accounts for left/right offset and contentOffset of scroll view
    CGPoint shapePosition = [view.superview convertPoint:view.center fromView:view.superview];
    
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = path.CGPath;
    circleShape.position = shapePosition;
    circleShape.fillColor = [UIColor clearColor].CGColor;
    circleShape.opacity = 0;
    circleShape.strokeColor = [UIColor whiteColor].CGColor;
    circleShape.lineWidth = 2.0;
    
    [view.superview.layer addSublayer:circleShape];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.5, 2.5, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    
    animation.animations = @[scaleAnimation, alphaAnimation];
    animation.duration = 0.5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [circleShape addAnimation:animation forKey:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (void)setupContentViewController
{
    for (NSOrderedSet *mappingsSet in self.exerciseObjects)
    {
        // Create a new view controller and pass suitable data.
        WorkoutViewController *workoutViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WorkoutViewController"];
        workoutViewController.exerciseMetaMappings = mappingsSet;
        workoutViewController.pageIndex = [self.exerciseObjects indexOfObject:mappingsSet];
        workoutViewController.delegate = self;
        [self.contentViewControllers addObject:workoutViewController];
    }
}

- (WorkoutViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.exerciseObjects count] == 0) || (index >= [self.exerciseObjects count])) {
        return nil;
    }
    
    WorkoutViewController *workoutViewController = self.contentViewControllers[index];
    return workoutViewController;
}

#pragma mark - PageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((WorkoutViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;

    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((WorkoutViewController*) viewController).pageIndex;
    [self.pageControl setCurrentPage:index];

    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.exerciseObjects count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return self.exerciseObjects.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

#pragma mark - PageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    WorkoutViewController *currentViewController = pageViewController.viewControllers[0];
    [self.pageControl setCurrentPage:currentViewController.pageIndex];
}


#pragma mark - WorkoutPageViewControllerDelegate

- (CGFloat)getCurrentTrainingPlanProgress
{
    CGFloat workoutProgress = 0.0f;
    for (Training *workout in self.workout.trainingProgram.trainings)
    {
        workoutProgress += MIN(1.0f,[workout.repetitionCounter floatValue] / [self.workout.trainingProgram.workoutRepetition floatValue]);
    }
    CGFloat trainingPlanProgress = workoutProgress / self.workout.trainingProgram.trainings.count;
    return trainingPlanProgress;
}

- (void)goToNextExercise
{
    [[CurrentFitManager sharedManager] switchToNextExercise];
    
    //all exercises finished
    if ([[WorkoutExecutionWatchdog sharedWatchdog] workoutIsFinished])
    {
        self.workout.repetitionCounter = @([self.workout.repetitionCounter integerValue] + 1);
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        //check if trainingplan is finished
        if ([self getCurrentTrainingPlanProgress] >= 1.0f) // trainingprogram finished
        {
            [self.view bringSubviewToFront:self.trainingPlanFinishedView];
            self.trainingPlanFinishedView.alpha = 0;
            self.trainingPlanFinishedView.hidden = NO;
            [UIView animateWithDuration:0.5 animations:^{
                self.trainingPlanFinishedView.alpha = 1;
            }];
            SAConfettiView *cView = [[SAConfettiView alloc] initWithFrame:self.trainingPlanFinishedView.bounds];
            [self.trainingPlanFinishedView addSubview:cView];
            [self.trainingPlanFinishedView sendSubviewToBack:cView];
            [cView startConfetti];
        }
        else // workout finished
        {
            [self.view bringSubviewToFront:self.workoutFinishedView];
            self.workoutFinishedView.alpha = 0;
            self.workoutFinishedView.hidden = NO;
            [UIView animateWithDuration:0.5 animations:^{
                self.workoutFinishedView.alpha = 1;
            }];
        }
        return;
    }
    
    int nextPageIndex = (int)self.pageControl.currentPage+1;
    // last page - return
    if ((self.pageControl.currentPage >= self.exerciseObjects.count-1))
    {
        for(int i = (int)(self.exerciseObjects.count - 1); i>=0; i--)
        {
            NSOrderedSet *mappings = self.exerciseObjects[i];
            ExerciseMetaMapping *mapping = mappings[0];
            if ([[WorkoutExecutionWatchdog sharedWatchdog] statusForExercise:mapping.exercise] == ExerciseExecutionStatusSkipped) {
                nextPageIndex = i;
            }
        }
    }
    
    //page to next workoutview controller
    WorkoutViewController *upcomingViewController = [self viewControllerAtIndex:nextPageIndex];
    [self.pageViewController setViewControllers:@[upcomingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self.pageControl setCurrentPage:upcomingViewController.pageIndex];
}

- (void)jumpToExerciseAtIndex:(NSInteger)index
{
    WorkoutViewController *upcomingViewController = [self viewControllerAtIndex:index];
    [self.pageViewController setViewControllers:@[upcomingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self.pageControl setCurrentPage:upcomingViewController.pageIndex];
}

- (NSInteger)currentExerciseIndex {
    int currentPage = self.pageControl.currentPage;
    int currentExerciseIndex = 1;
    
    for(int i=0; i<self.pageControl.currentPage; i++) {
        currentExerciseIndex += [self.exerciseObjects[currentPage] count];
    }
    
    currentExerciseIndex--;
    
    return currentExerciseIndex;
}

#pragma mark - IBActions

- (IBAction)workoutFinishedButtonPressed:(id)sender
{
    [self.sideMenuRootViewController finishWorkout];
}

- (IBAction)gotToTrainingPlanSelection:(id)sender
{
    __block UIViewController *controller = self.navigationController.presentingViewController;
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        TrainingPlanGroupSelectorViewController *destinationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TrainingPlanGroupSelectorViewController"];
        UINavigationController *navController = (UINavigationController *)(((RESideMenu *)controller).contentViewController);
        NSMutableArray *controllers = [NSMutableArray arrayWithArray:navController.viewControllers];
        [controllers addObject:destinationViewController];
        [navController setViewControllers:controllers animated:YES];
    }];
    
}

@end
