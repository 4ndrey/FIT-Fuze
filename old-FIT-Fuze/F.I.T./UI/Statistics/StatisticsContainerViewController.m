//
//  StatisticsContainerViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 08.07.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "StatisticsContainerViewController.h"
#import "StatisticsCalenderViewController.h"
#import "UIViewController+RESideMenu.h"

@interface StatisticsContainerViewController ()

@property (nonatomic, strong) UIViewController *currentVC;
@property (nonatomic, strong) UIViewController *initialVC;
@property (nonatomic, strong) StatisticsCalenderViewController *substituteVC;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) UIBarButtonItem *calenderBarButton;
@property (strong, nonatomic) UIButton *calenderButton;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation StatisticsContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.segmentedControl setTitle:NSLocalizedString(@"Graph", nil) forSegmentAtIndex:0];
    [self.segmentedControl setTitle:NSLocalizedString(@"Calendar", nil) forSegmentAtIndex:1];

    self.initialVC = self.childViewControllers.lastObject;
    self.substituteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StatisticsCalenderViewController"];
    self.currentVC = self.initialVC;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"dd.MM.yy"];
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setFrame:CGRectMake(0.0f, 0.0f, 27.0f, 19.0f)];
    [menuButton setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [menuButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    [menuButton setImage:[UIImage imageNamed:@"list-menu"] forState:UIControlStateNormal];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = button;

}

- (IBAction)segmentedControlChanged:(UISegmentedControl *)sender
{
    if (self.currentVC == self.substituteVC)
    {
        self.navigationItem.rightBarButtonItem = nil;
        [self addChildViewController:self.initialVC];
        self.initialVC.view.frame = self.container.bounds;
        [self moveToNewController:self.initialVC];
    }
    else if (self.currentVC == self.initialVC)
    {
        self.calenderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.calenderButton.frame = CGRectMake(0, 0, 60, 30);
        [self updateNavigationBarItemDate:[NSDate date]];
        self.calenderButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.calenderButton.layer.borderWidth = 1.5f;
        self.calenderButton.layer.cornerRadius = 4.0f;
        self.calenderButton.backgroundColor = [UIColor colorWithRed:47.0/255.0 green:96.0/255.0 blue:164.0/255.0 alpha:0.2];
        [self.calenderButton addTarget:self action:@selector(calenderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:self.calenderButton];
        
        self.calenderBarButton = buttonItem;
        self.navigationItem.rightBarButtonItem = self.calenderBarButton;
        [self addChildViewController:self.substituteVC];
        self.substituteVC.view.frame = self.container.bounds;
        [self moveToNewController:self.substituteVC];
    }
}

-(void)moveToNewController:(UIViewController *) newController
{
    [self.currentVC willMoveToParentViewController:nil];
    [self transitionFromViewController:self.currentVC toViewController:newController duration:.6 options:UIViewAnimationOptionTransitionFlipFromRight animations:nil
                            completion:^(BOOL finished) {
                                
                                [self.currentVC removeFromParentViewController];
                                [newController didMoveToParentViewController:self];
                                self.currentVC = newController;
                            }];
}

- (IBAction)calenderButtonPressed:(id)sender
{
    if (self.currentVC == self.substituteVC)
    {
        [self.substituteVC changeDate];
    }
}

#pragma mark - public

- (void)updateNavigationBarItemDate:(NSDate *)date
{
    NSDictionary *attrDict = [NSDictionary dictionaryWithObjects:@[[UIFont systemFontOfSize:12.0f], [UIColor whiteColor]] forKeys:@[NSFontAttributeName, NSForegroundColorAttributeName]];
    NSString *formattedDate = [self.dateFormatter stringFromDate:date];
    NSMutableAttributedString *dateString = [[NSMutableAttributedString alloc] initWithString:formattedDate attributes:attrDict];
    [self.calenderButton setAttributedTitle:dateString forState:UIControlStateNormal];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
