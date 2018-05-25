//
//  WhatsNewViewController.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 27/09/15.
//  Copyright © 2015 FIT-Team. All rights reserved.
//

#import "WhatsNewViewController.h"

@interface WhatsNewViewController ()
@property (weak, nonatomic) IBOutlet UILabel *whatNewTitle;
@property (weak, nonatomic) IBOutlet UILabel *firstSubtitle;
@property (weak, nonatomic) IBOutlet UILabel *firstFeatureText;
@property (weak, nonatomic) IBOutlet UILabel *secondSubtitle;
@property (weak, nonatomic) IBOutlet UILabel *secondFeatureText;
@property (weak, nonatomic) IBOutlet UILabel *thirdSubtitle;
@property (weak, nonatomic) IBOutlet UILabel *thirdFeatureText;

@end

@implementation WhatsNewViewController

- (void)viewDidLoad
{
    self.whatNewTitle.text = NSLocalizedString(@"whatNewTitle", nil);
    self.firstSubtitle.text = NSLocalizedString(@"whatNew_firstSubtitle", nil);
    self.firstFeatureText.text = NSLocalizedString(@"whatNew_firstFeatureText", nil);
    self.secondSubtitle.text = NSLocalizedString(@"whatNew_secondSubtitle", nil);
    self.secondFeatureText.text = NSLocalizedString(@"whatNew_secondFeatureText", nil);
    self.thirdSubtitle.text = NSLocalizedString(@"whatNew_thirdSubtitle", nil);
    self.thirdFeatureText.text = NSLocalizedString(@"whatNew_thirdFeatureText", nil);
}

- (IBAction)okPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Updates_13_shown"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate) {
            [self.delegate userHasSeenWhatsNew];
        }
    }];
}

@end
