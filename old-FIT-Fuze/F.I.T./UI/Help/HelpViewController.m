//
//  HelpViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 22.04.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "HelpViewController.h"
#import "FIT-Swift.h"
#import "UIColor+FIT.h"
#import "UIViewController+RESideMenu.h"

@interface HelpViewController ()

@property (weak, nonatomic) IBOutlet UILabel *questionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionsDescriptionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *responsibilityButton;

@end

@implementation HelpViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"HelpViewControllerNavBar_title", nil);

    self.questionsLabel.text = NSLocalizedString(@"Questions_Label_Text", nil);
    self.questionsDescriptionsLabel.text = NSLocalizedString(@"QuestionsDescription_Label_Text", nil);
    [self.responsibilityButton setTitle:NSLocalizedString(@"Responsibility_Button_Title",nil) forState:UIControlStateNormal];
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setFrame:CGRectMake(0.0f, 0.0f, 27.0f, 19.0f)];
    [menuButton setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [menuButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    [menuButton setImage:[UIImage imageNamed:@"list-menu"] forState:UIControlStateNormal];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = button;
}

#pragma mark - IBActions

- (IBAction)termsOfUseButtonPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://fit-fuze.com/agb.html"]];
}


#pragma mark - WalkthroughDelegate

- (void)walkthroughCloseButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)walkthroughNextButtonPressed
{
    
}

- (void)walkthroughPageDidChange:(NSInteger)pageNumber
{
    
}

- (void)walkthroughPrevButtonPressed
{
    
}

@end
