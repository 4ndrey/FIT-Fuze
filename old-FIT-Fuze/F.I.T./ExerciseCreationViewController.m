//
//  ExerciseCreationViewController.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 05/09/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "ExerciseCreationViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "FIT-Swift.h"
#import "UIColor+FIT.h"
#import "GKImagePicker.h"

@import AVFoundation;
@import MagicalRecord;

@interface ExerciseCreationViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, GKImagePickerDelegate>
{
    BOOL pointerRotated;
    BOOL notifyAboutMuscles;
}
@property (weak, nonatomic) IBOutlet UIButton *createExerciseButton;
@property (weak, nonatomic) IBOutlet UIImageView *demoImageView;
@property (weak, nonatomic) IBOutlet UIButton *addVideoButton;
@property (weak, nonatomic) IBOutlet UITextView *nameTextView;
@property (weak, nonatomic) IBOutlet UIPickerView *musclesPicker;
@property (nonatomic, strong) GKImagePicker *camera;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameExerciseFieldConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *frontMusclesImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backMusclesImageView;
@property (weak, nonatomic) IBOutlet UIButton *bigPlusAddDemoButton;

@property (strong, nonatomic) NSArray *muscleGroupNames;
@property (strong, nonatomic) NSMutableArray *selectedMuscles;
@property (weak, nonatomic) IBOutlet UIButton *addExerciseButton;
@property (strong, nonatomic) UIImageView *viewedMuscleImageView;
@property (weak, nonatomic) UIImageView *currentMuscleImageView;
@property (weak, nonatomic) IBOutlet UILabel *pointerView;

@property (strong, nonatomic) UIImage *exerciseImage;

@property (strong, nonatomic) NSMutableDictionary *addedMuscleImagesDictionary;


@end

@implementation ExerciseCreationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"New_exercise_title", nil);
    
    notifyAboutMuscles = NO;
    _backMusclesImageView.alpha = 0;
    [_createExerciseButton setTitle:NSLocalizedString(@"Create_exercise_button_title", nil) forState:UIControlStateNormal];
    _camera = [self setupImagePicker];
    _nameTextView.text = NSLocalizedString(@"Provide_name_text", nil);
    _nameTextView.textColor = [UIColor lightGrayColor];
    [_addVideoButton setTitle:NSLocalizedString(@"add_demo_title", nil) forState:UIControlStateNormal];
    _addedMuscleImagesDictionary = [NSMutableDictionary new];

    if (!_camera) {
        [_demoImageView removeFromSuperview];
        [_addVideoButton removeFromSuperview];
        [_bigPlusAddDemoButton removeFromSuperview];
    }

    self.muscleGroupNames = [[ContentProvider new] getAllMuscles];
    self.muscleGroupNames = [self.muscleGroupNames sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *o1 = obj1;
        NSString *o2 = obj2;
        NSString *first = NSLocalizedString(o1, nil);
        NSString *second = NSLocalizedString(o2, nil);
        return [first compare:second];
    }];
    
    _selectedMuscles = [[NSMutableArray alloc] initWithCapacity:self.muscleGroupNames.count];
    for (int i = 0; i < _muscleGroupNames.count; i++) {
        _selectedMuscles[i] = [NSNumber numberWithBool:NO];
    }
    
    //self.navigationController.navigationBar.tintColor = [UIColor editColor];
    
    [UIView animateWithDuration:0.3 animations:^{
        _pointerView.transform = CGAffineTransformMakeRotation(M_PI_2);
        pointerRotated = YES;
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (IBAction)addDemo:(id)sender {
    if(_camera)
    {
        [_camera showActionSheetOnViewController:self onPopoverFromView:self.view];
    } else {
        
    }
}

- (GKImagePicker *)setupImagePicker
{
    _camera = [[GKImagePicker alloc] init];
    _camera.cropSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width);
    _camera.delegate = self;
    return _camera;
}

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image
{
    _demoImageView.image = image;
    _bigPlusAddDemoButton.alpha = 0;
    [_addVideoButton setTitle:NSLocalizedString(@"change_demo_title", nil) forState:UIControlStateNormal];
    _exerciseImage = image;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (([[UIScreen mainScreen] bounds].size.height == 480)&&(_camera)) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.center = CGPointMake(self.view.center.x, self.view.center.y-153);
        }];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (([[UIScreen mainScreen] bounds].size.height == 480)&&(_camera)) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.center = CGPointMake(self.view.center.x, self.view.center.y+153);
        }];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString: NSLocalizedString(@"Provide_name_text", nil)])
    {
        textView.textColor = [UIColor blackColor];
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.nameTextView resignFirstResponder];
    if([textView.text isEqualToString: @""])
    {
        textView.textColor = [UIColor lightGrayColor];
        textView.text = NSLocalizedString(@"Provide_name_text", nil);
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if([textView.text isEqualToString: @""])
        {
            textView.textColor = [UIColor lightGrayColor];
            textView.text = NSLocalizedString(@"Provide_name_text", nil);
        }
        return NO;
    }
    
    return YES;
}

#pragma mark - uipicker methods

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.muscleGroupNames.count+1;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,45)];
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(33, 0, contentView.bounds.size.width-50, 45);
    label.textAlignment = NSTextAlignmentLeft;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    
    if(row == 0)
    {
        label.textColor = notifyAboutMuscles ? [UIColor failureColor] : [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        label.text = NSLocalizedString(@"add_involved_muscle_groups_title", nil);
    }
    else
    {
        if ([_selectedMuscles[row-1] boolValue]) {
            label.textColor = [UIColor mainColor];
            label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        } else {
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightLight];
        }
        label.text = [NSString stringWithFormat:@"%@",NSLocalizedString(self.muscleGroupNames[row-1], nil)];
    }
    
    [contentView addSubview:label];
    
    return contentView;
}

- (IBAction)addButtonPressed:(id)sender {
    notifyAboutMuscles = NO;
    NSInteger currentRow = [_musclesPicker selectedRowInComponent:0];
    if(currentRow == 0) {
        return;
    }
    
    currentRow--;
    _selectedMuscles[currentRow] = [NSNumber numberWithBool: ![_selectedMuscles[currentRow] boolValue]];
    [_musclesPicker reloadAllComponents];

    if([_selectedMuscles[currentRow] boolValue])
    {
        [_addExerciseButton setImage:[UIImage imageNamed:@"addedMuscle"] forState:UIControlStateNormal];
        UIImageView *selectedMuscleImage = [[UIImageView alloc] initWithFrame:_currentMuscleImageView.bounds];
        NSString *muscleName = _muscleGroupNames[currentRow];
        selectedMuscleImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"Primary-%@", muscleName]];
        [_currentMuscleImageView addSubview:selectedMuscleImage];
        [_addedMuscleImagesDictionary setObject:selectedMuscleImage forKey:muscleName];
    }
    else
    {
        [_addExerciseButton setImage:[UIImage imageNamed:@"addMuscle"] forState:UIControlStateNormal];
        NSString *muscleName = _muscleGroupNames[currentRow];
        UIImageView *muscleToRemove = [_addedMuscleImagesDictionary objectForKey:muscleName];
        [muscleToRemove removeFromSuperview];
        [_addedMuscleImagesDictionary removeObjectForKey:muscleName];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(row == 0) {
        [_addExerciseButton setImage:[UIImage imageNamed:@"empty_image"] forState:UIControlStateNormal];
        [_viewedMuscleImageView removeFromSuperview];
        
        [UIView animateWithDuration:0.3 animations:^{
            _pointerView.transform = CGAffineTransformMakeRotation(M_PI_2);
            pointerRotated = YES;
        }];
        
        return;
    }
    
    if(pointerRotated)
    {
        pointerRotated = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _pointerView.transform = CGAffineTransformMakeRotation(0);
        }];
    }
    row = row - 1;
    if([_selectedMuscles[row] boolValue])
    {
        [_addExerciseButton setImage:[UIImage imageNamed:@"removeMuscle"] forState:UIControlStateNormal];
    } else {
        [_addExerciseButton setImage:[UIImage imageNamed:@"addMuscle"] forState:UIControlStateNormal];
    }
    
    NSString *muscleName = _muscleGroupNames[row];
    NSString *musclePosition = [[ContentProvider new] getMusclePosition:muscleName];
    
    if ([musclePosition isEqualToString:@"back"]) {
        _frontMusclesImageView.alpha = 0;
        _backMusclesImageView.alpha = 1;
        _currentMuscleImageView = _backMusclesImageView;
    } else {
        _frontMusclesImageView.alpha = 1;
        _backMusclesImageView.alpha = 0;
        _currentMuscleImageView = _frontMusclesImageView;
    }
    
    [_viewedMuscleImageView removeFromSuperview];
    _viewedMuscleImageView = [[UIImageView alloc] initWithFrame:_currentMuscleImageView.bounds];
    _viewedMuscleImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Secondary-%@", muscleName]];
    [_currentMuscleImageView addSubview:_viewedMuscleImageView];
    [_currentMuscleImageView setBackgroundColor:[UIColor redColor]];
    [self.view bringSubviewToFront:_currentMuscleImageView];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 45;
}

- (void)showEmptyNameWarning {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:NSLocalizedString(@"Provide_name_warning", nil)
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

- (void)showNoGroupsSelectedWarning {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:NSLocalizedString(@"Select_muscle_group_warning", nil)
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

- (IBAction)createExerciseButtonPressed:(id)sender {
    if ([self.nameTextView.text isEqualToString:NSLocalizedString(@"Provide_name_text", nil)]) {
        self.nameTextView.textColor = [UIColor failureColor];
        [self showEmptyNameWarning];
    } else if ([[Exercise MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", self.nameTextView.text]] firstObject]) {
        [self showDuplicateError];
        self.nameTextView.textColor = [UIColor failureColor];
    } else {
        NSMutableArray *selected = [NSMutableArray new];
        for(int i = 0; i < self.selectedMuscles.count; i++) {
            NSNumber *key = self.selectedMuscles[i];
            if ([key boolValue] == YES) {
                [selected addObject:self.muscleGroupNames[i]];
            }
        }
        
        if (selected.count == 0 && [_musclesPicker selectedRowInComponent:0] == 0) {
            notifyAboutMuscles = YES;
            [_musclesPicker reloadAllComponents];
            [self showNoGroupsSelectedWarning];
            return;
        }
        else if (selected.count == 0) {
            [self addButtonPressed:self];
            for(int i = 0; i < self.selectedMuscles.count; i++) {
                NSNumber *key = self.selectedMuscles[i];
                if ([key boolValue] == YES) {
                    [selected addObject:self.muscleGroupNames[i]];
                }
            }
        }
        if(!self.exerciseImage) {
            self.exerciseImage = [UIImage imageNamed:@"default_image"];
        }
        Exercise *exercise = [[Exercise alloc] initWithName:self.nameTextView.text exerciseImage:self.exerciseImage muscles:[selected copy]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"exerciseWasCreated" object:nil];
        
        if([[[self navigationController] presentingViewController] presentedViewController] == [self navigationController]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [[self navigationController] popViewControllerAnimated:YES];
        }
        
        if([self presentingViewController])
        {
            
        }
    }
}

- (void)showDuplicateError {
    NSString *name = self.nameTextView.text;
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

@end
