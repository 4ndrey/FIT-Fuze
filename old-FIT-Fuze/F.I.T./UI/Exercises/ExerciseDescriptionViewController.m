//
//  ExerciseDescriptionViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 15.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "ExerciseDescriptionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GKImagePicker.h"
#import "NavigationTextView.h"

@import MagicalRecord;

@interface ExerciseDescriptionViewController () <UITextFieldDelegate, UITextViewDelegate, GKImagePickerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *exerciseImageView;
@property (strong, nonatomic) NSArray *exerciseImageArray;
@property (nonatomic) int imageCount;

@property (weak, nonatomic) IBOutlet UILabel *primaryMuscleGroupLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondaryMuscleGroupLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITextView *exerciseDescriptionTextView;

@property (weak, nonatomic) IBOutlet UIView *instructionView;
@property (weak, nonatomic) IBOutlet UIView *muscleGroupView;
@property (weak, nonatomic) IBOutlet UICollectionView *muscleGroupColletionView;

@property (strong, nonatomic) NSDictionary *muscleGroupDictionary;
@property (weak, nonatomic) IBOutlet UIPageControl *muscleGroupPageControl;

@property (strong, nonatomic) NSString *oldTitle;
@property (nonatomic) CGFloat muscleImageHeight;
@property (weak, nonatomic) IBOutlet UIButton *changeImageButton;
@property (nonatomic, strong) GKImagePicker *camera;
@property (nonatomic, strong) NavigationTextView *navigationTextView;

@end

@implementation ExerciseDescriptionViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTitles];

    ContentProvider *contentProvider = [[ContentProvider alloc] init];
    self.muscleGroupDictionary = [contentProvider getMuscleDetails:self.exercise];
    self.changeImageButton.hidden = ![self.exercise.type isEqualToString:@"own"];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"createModeON"]) {
        self.segmentedControl.layer.borderColor = [UIColor editColor].CGColor;
        [self.segmentedControl setTintColor:[UIColor editColor]];
    } else {
        self.segmentedControl.layer.borderColor = [UIColor mainColor].CGColor;
    }
    
    [self setupViews];
}

- (void)viewDidLayoutSubviews
{
    self.muscleImageHeight = self.muscleGroupColletionView.frame.size.height;
}

#pragma mark - all about description and keyboard appearance

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y - 256);
    }];

    if([textView.text isEqualToString: NSLocalizedString(@"Provide_description_text", nil)])
    {
        textView.textColor = [UIColor blackColor];
        textView.text = @"";
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if([textView.text isEqualToString: @""])
        {
            textView.textColor = [UIColor lightGrayColor];
            textView.text = NSLocalizedString(@"Provide_description_text", nil);
        }
        return NO;
    }
    
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView == self.exerciseDescriptionTextView) {
        if ((textView.text.length > 0)&&(![textView.text isEqualToString:NSLocalizedString(@"Provide_description_text", nil)])) {
            [self.exercise setExerciseDescription:textView.text];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y + 256);
    }];
    
    return YES;
}

#pragma mark - internal methods

- (void)setupTitles {
    [self.segmentedControl setTitle:NSLocalizedString(@"HowTo_SegmentedControl_Title", nil) forSegmentAtIndex:0];
    [self.segmentedControl setTitle:NSLocalizedString(@"Muscles_SegmentedControl_Title", nil) forSegmentAtIndex:1];
    
    [self.changeImageButton setTitle:NSLocalizedString(@"change_demo_title", nil) forState:UIControlStateNormal];
    
    self.exerciseDescriptionTextView.text = self.exercise.exerciseDescription;
    if (self.exerciseDescriptionTextView.text.length == 0) {
        self.exerciseDescriptionTextView.text = NSLocalizedString(@"Provide_description_text", nil);
        self.exerciseDescriptionTextView.textColor = [UIColor lightGrayColor];
    }
}

- (IBAction)changeImage:(id)sender {
    if(!_camera) {
        _camera = [[GKImagePicker alloc] init];
        _camera.cropSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width);
        _camera.delegate = self;
    }

    [_camera showActionSheetOnViewController:self onPopoverFromView:self.view];
}

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image
{
    [self.exercise setImage:image];
    self.exerciseImageView.animationImages = nil;
    self.exerciseImageView.image = image;
    [self.exerciseImageView setNeedsDisplay];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.segmentedControl.layer.cornerRadius = 5;
    self.segmentedControl.layer.borderWidth = 1;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.oldTitle = self.navigationController.navigationBar.topItem.title;
    self.navigationController.navigationBar.topItem.title = @"";
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.topItem.title = self.oldTitle;
}

- (void)setupViews
{
    if(!self.exercise.images)
        return;
    
    if ([self.muscleGroupDictionary allKeys].count <= 1)
    {
        self.muscleGroupPageControl.hidden = YES;
    }
    
    self.segmentedControl.selectedSegmentIndex = 0;
    
    if ([self.exercise.type isEqualToString:@"own"])
    {
        self.navigationTextView = [[NavigationTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 120, 64)];
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"createModeON"]) {
            self.navigationTextView.titleTextField.textColor = [UIColor editColor];
        }
        self.navigationTextView.titleTextField.text = NSLocalizedString(self.exercise.name,nil);
        self.navigationTextView.titleTextField.returnKeyType = UIReturnKeyDone;
        self.navigationTextView.titleTextField.delegate = self;
        self.navigationTextView.titleTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.navigationTextView.descriptionLabel.text = NSLocalizedString(@"WorkoutModificationChangeWorkout_Navbar_Title", nil);
        self.navigationItem.titleView = self.navigationTextView;
    } else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 480, 44)];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(self.exercise.name,nil);
        label.font = [UIFont systemFontOfSize:20 weight:UIFontWeightLight];
        if (label.text.length > 20) {
            label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightLight];
        }
        if (label.text.length > 35) {
            label.numberOfLines = 2;
        }
        label.minimumScaleFactor = 0.5;
        label.adjustsFontSizeToFitWidth = YES;
        label.textAlignment = NSTextAlignmentCenter;
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"createModeON"]) {
            label.textColor = [UIColor editColor];
        } else {
            label.textColor = [UIColor mainColor];
        }
        self.navigationItem.titleView = label;
    }
    

    
    [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16 weight:UIFontWeightLight], NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.segmentedControl.selectedSegmentIndex = 0;

    //setup image animation stuff
    NSMutableArray *mutableImageArray = [[NSMutableArray alloc] init];
    NSMutableArray *mutableImageArray2 = [[NSMutableArray alloc] init];

    [mutableImageArray addObjectsFromArray:[self.exercise.images array]];
    
    if (mutableImageArray.count <= 7) //non-symmetric exercises should not be reverted
    {
        [mutableImageArray addObjectsFromArray:[[[self.exercise.images array] reverseObjectEnumerator] allObjects]];
    }
    
    for (Images *image in mutableImageArray)
    {
        UIImage *exerciseImage = [UIImage imageWithData:image.image];
        [mutableImageArray2 addObject:exerciseImage];
    }
    
    self.exerciseImageArray = [NSArray arrayWithArray:[[mutableImageArray2 objectEnumerator] allObjects]];
    self.exerciseImageView.animationImages = self.exerciseImageArray;
    self.exerciseImageView.animationRepeatCount = 0;
    self.exerciseImageView.animationDuration = 0.3*self.exerciseImageArray.count;
    self.imageCount = 0;
    self.exerciseImageView.image = self.exerciseImageArray[0];
    
    [self startExerciseImageAnimation];
    
    //setup and images
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    [mutableString appendString:NSLocalizedString(@"PrimaryMuscles_Label_Text", nil)];
    NSInteger startIndex = mutableString.length;
    for (PrimaryExerciseType *primaryType in self.exercise.primary)
    {
        [mutableString appendString:[NSString stringWithFormat:@"%@, ",NSLocalizedString( primaryType.type, nil)]];
    }
    self.primaryMuscleGroupLabel.text = [mutableString substringToIndex:[mutableString length] - 2];
    
    NSMutableAttributedString *text =[[NSMutableAttributedString alloc] initWithAttributedString: self.primaryMuscleGroupLabel.attributedText];
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor colorWithRed:71/255.0f green:181/255.0f blue:217/255.0f alpha:1.0f]
                 range:NSMakeRange(startIndex, self.primaryMuscleGroupLabel.text.length-startIndex)];
    [self.primaryMuscleGroupLabel setAttributedText: text];
    
    mutableString = [[NSMutableString alloc] init];
    [mutableString appendString:NSLocalizedString(@"SecondaryMuscles_Label_Text", nil)];
    startIndex = mutableString.length;
    int length = (int)mutableString.length;
    for (SecondaryExerciseType *secondaryType in self.exercise.secondary)
    {
        length++;
        [mutableString appendString:[NSString stringWithFormat:@"%@, ",NSLocalizedString(secondaryType.type,nil)]];
        length++;
    }
    
    if (length == mutableString.length)
    {
        self.secondaryMuscleGroupLabel.text = @"";
    }
    else
    {
        self.secondaryMuscleGroupLabel.text = [mutableString substringToIndex:[mutableString length] - 2];;
        NSMutableAttributedString *text =[[NSMutableAttributedString alloc] initWithAttributedString: self.secondaryMuscleGroupLabel.attributedText];
        [text addAttribute:NSForegroundColorAttributeName
                     value:[UIColor colorWithRed:184/255.0f green:74/255.0f blue:217/255.0f alpha:1.0f]
                     range:NSMakeRange(startIndex, self.secondaryMuscleGroupLabel.text.length-startIndex)];
        [self.secondaryMuscleGroupLabel setAttributedText: text];
    }
    
    [self.muscleGroupView layoutIfNeeded];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Save_Button_Title", nil);
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationTextView.descriptionLabel.alpha = 0;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
#warning - we don't take localizations into account!
    Exercise *anotherExercise = [[Exercise MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", self.navigationTextView.titleTextField.text]] firstObject];
    if ((anotherExercise)&&(anotherExercise != self.exercise)) {
        [self showDuplicateError];
        return NO;
    } else {
        self.navigationItem.rightBarButtonItem.title = nil;
        self.navigationTextView.descriptionLabel.alpha = 1;
        [textField resignFirstResponder];
        self.navigationItem.hidesBackButton = NO;
        return YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.exercise setName:textField.text];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)showDuplicateError {
    NSString *name = self.navigationTextView.titleTextField.text;
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:[NSString stringWithFormat: NSLocalizedString(@"Name_duplicate", nil), name]
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

- (void)startExerciseImageAnimation
{
    [self.exerciseImageView startAnimating];
}

- (IBAction)selectedControlPressed:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        self.muscleGroupView.hidden = YES;
        self.instructionView.hidden = NO;
    }
    else
    {
        //setup collection view layout
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.itemSize = CGSizeMake(self.view.frame.size.width, self.muscleGroupColletionView.frame.size.height);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.muscleGroupColletionView.collectionViewLayout = layout;
        [self.muscleGroupColletionView reloadData];
        
        self.muscleGroupView.hidden = NO;
        self.instructionView.hidden = YES;
    }

}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.muscleGroupDictionary allKeys].count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"muscleGroupCell" forIndexPath:indexPath];

    NSDictionary *muscleGroup = self.muscleGroupDictionary[[[self.muscleGroupDictionary allKeys] objectAtIndex:indexPath.row]];
    UIImageView *muscleGroupBackGroundImage = (UIImageView *)[cell viewWithTag:1860];
    [muscleGroupBackGroundImage layoutIfNeeded];
    muscleGroupBackGroundImage.image = [UIImage imageNamed:[[[self.muscleGroupDictionary allKeys] objectAtIndex:indexPath.row] lowercaseString]];
    [muscleGroupBackGroundImage.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    //add muscle images
    for (NSString *primaryType in muscleGroup[@"primary"])
    {
        NSString *imageName = [NSString stringWithFormat:@"Primary-%@",primaryType];
        UIImageView *muscleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, muscleGroupBackGroundImage.frame.size.width, muscleGroupBackGroundImage.frame.size.height)];
        muscleImageView.image = [UIImage imageNamed:imageName];
        muscleImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [muscleGroupBackGroundImage addSubview:muscleImageView];
        
        [muscleGroupBackGroundImage addConstraint:[NSLayoutConstraint constraintWithItem:muscleImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:muscleGroupBackGroundImage attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
        [muscleGroupBackGroundImage addConstraint:[NSLayoutConstraint constraintWithItem:muscleImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:muscleGroupBackGroundImage attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
        [muscleGroupBackGroundImage addConstraint:[NSLayoutConstraint constraintWithItem:muscleImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:muscleGroupBackGroundImage attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
        [muscleGroupBackGroundImage addConstraint:[NSLayoutConstraint constraintWithItem:muscleImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:muscleGroupBackGroundImage attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    }
    
    for (NSString *secondaryType in muscleGroup[@"secondary"])
    {
        NSString *imageName = [NSString stringWithFormat:@"Secondary-%@",secondaryType];
        UIImageView *muscleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, muscleGroupBackGroundImage.frame.size.width, muscleGroupBackGroundImage.frame.size.height)];
        muscleImageView.image = [UIImage imageNamed:imageName];
        muscleImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [muscleGroupBackGroundImage addSubview:muscleImageView];
        
        [muscleGroupBackGroundImage addConstraint:[NSLayoutConstraint constraintWithItem:muscleImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:muscleGroupBackGroundImage attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
        [muscleGroupBackGroundImage addConstraint:[NSLayoutConstraint constraintWithItem:muscleImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:muscleGroupBackGroundImage attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
        [muscleGroupBackGroundImage addConstraint:[NSLayoutConstraint constraintWithItem:muscleImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:muscleGroupBackGroundImage attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
        [muscleGroupBackGroundImage addConstraint:[NSLayoutConstraint constraintWithItem:muscleImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:muscleGroupBackGroundImage attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    }
    
    return cell;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.muscleGroupColletionView.frame.size.width;
    self.muscleGroupPageControl.currentPage = self.muscleGroupColletionView.contentOffset.x / pageWidth;
}

@end
