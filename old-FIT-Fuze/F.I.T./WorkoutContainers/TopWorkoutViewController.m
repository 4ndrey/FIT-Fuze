//
//  TopWorkoutViewController.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 21/05/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import "TopWorkoutViewController.h"
#import "FIT-Swift.h"
#import "UIColor+FIT.h"
#import "SizeHelper.h"

@interface TopWorkoutViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *exerciseImageView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *detailsButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageSideConstraint;

@end

@implementation TopWorkoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupImage];
    self.imageSideConstraint.constant = [SizeHelper workoutOneImageHeight];
}

- (void)setupImage {
    //setup image animation stuff
    NSMutableArray *mutableImageArray = [[NSMutableArray alloc] init];
    NSMutableArray *mutableImageArray2 = [[NSMutableArray alloc] init];
    Exercise *exercise = self.exerciseMapping.exercise;
    
    [mutableImageArray addObjectsFromArray:[exercise.images array]];
    
    if (mutableImageArray.count <= 7) //non-symmetric exercises should not be reverted
    {
        [mutableImageArray addObjectsFromArray:[[[exercise.images array] reverseObjectEnumerator] allObjects]];
    }
    
    for (Images *image in mutableImageArray)
    {
        UIImage *exerciseImage = [UIImage imageWithData:image.image];
        [mutableImageArray2 addObject:exerciseImage];
    }
    
    self.exerciseImageView.animationImages = [NSArray arrayWithArray:[[mutableImageArray2 objectEnumerator] allObjects]];
    self.exerciseImageView.animationRepeatCount = 1;
    self.exerciseImageView.animationDuration = 0.3*self.exerciseImageView.animationImages.count;
    self.exerciseImageView.image = self.exerciseImageView.animationImages[0];
    [self.view bringSubviewToFront:self.playButton];
    
    NSMutableAttributedString *locAttrTitle = [self.detailsButton.currentAttributedTitle mutableCopy];
    [locAttrTitle.mutableString setString: NSLocalizedString(@"DetailButton_Title", nil)];
    [self.detailsButton setAttributedTitle:locAttrTitle forState:UIControlStateNormal];
}

- (void)setupViews {
    self.exerciseImageView.layer.cornerRadius = 3;
    self.exerciseImageView.clipsToBounds = YES;
    
    Exercise *exercise = self.exerciseMapping.exercise;
    self.nameLabel.text = NSLocalizedString(exercise.name,nil);
}

#pragma mark - IBActions

- (IBAction)playPressed:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    sender.hidden = YES;
    [self.exerciseImageView startAnimating];
    [self performSelector:@selector(didFinishAnimatingImageView:)
               withObject:sender
               afterDelay:self.exerciseImageView.animationDuration];
}

- (IBAction)showDetails:(id)sender {
    [self.delegate showDetailsForExerciseMetaMapping:self.exerciseMapping];
}

- (void)didFinishAnimatingImageView:(UIButton *)sender
{
    sender.userInteractionEnabled = YES;
    sender.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
