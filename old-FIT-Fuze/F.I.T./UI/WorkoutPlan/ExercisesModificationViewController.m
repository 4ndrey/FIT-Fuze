//
//  WorkoutModificationViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 04.04.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "ExercisesModificationViewController.h"
#import "WorkoutModificationTableViewCell.h"
#import "MuscleGroupSelectionViewController.h"
#import "NavigationTextView.h"
#import "ExerciseModificationTableViewCell.h"
#import "ExerciseDetailCollectionViewCell.h"
#import "ExerciseDescriptionViewController.h"
#import "EditSetActionSheetPickerDelegate.h"
#import "CurrentFitManager.h"
#import "SettingsViewController.h"
#import "CurrentFitManager.h"
#import "UIColor+FIT.h"
#import "AddEditSetViewController.h"
#import "MZFormSheetPresentationViewController.h"
#import "ExercisesListViewController.h"

#import "ActionSheetPicker.h"
@import MagicalRecord;

@interface ExercisesModificationViewController () <AddEditSetViewControllerDelegate, ExercisesListViewControllerDelegate,
                                                    UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate,
                                                    UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIBarButtonItem *rightBarButton;
@property (weak, nonatomic) IBOutlet UITableView *workoutModificationTableView;
@property (nonatomic, strong) NSOrderedSet *exercisesObjects;
@property (nonatomic, strong) NavigationTextView *navigationTextView;
@property (strong, nonatomic) NSString *rightBarButtonName;
@property (nonatomic, strong) Exercise *selectedExercise;
@property (nonatomic, strong) NSOrderedSet *selectedExerciseMappings;
@property (nonatomic, weak) UICollectionView *selectedCollection;

@property (nonatomic) NSInteger selectedWeight;
@property (nonatomic) NSInteger selectedRepetitions;
@property (nonatomic) NSInteger selectedExerciseIndex;
@property (nonatomic) NSInteger selectedSetIndex;
@property (nonatomic) BOOL addSetButtonPressed;
@property (weak, nonatomic) IBOutlet UIView *addExercisesView;
@property (weak, nonatomic) IBOutlet UIView *selectTraininPlanView;
@property (weak, nonatomic) IBOutlet UIButton *selectTrainingPlanButton;
@property (weak, nonatomic) IBOutlet UIButton *addExercisesButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) IBOutlet UIButton *addSupersetButton;
@property (strong, nonatomic) IBOutlet UIButton *addingFinishedButton;

@end

@implementation ExercisesModificationViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupButtons];
    [self.workoutModificationTableView setContentInset:UIEdgeInsetsMake(0,0,65,0)];

    [self.editButton setTitle:NSLocalizedString(@"Edit_Button_Title", nil)];
    
    [self.welcomeLabel setText:NSLocalizedString(@"AddExercises_WelcomeLabel_Title", nil)];
    
    self.selectedRepetitions = -1;
    self.selectedWeight = -1;
    
    if (self.editModeIsUnavailable) //editing not possible (predefined trainingplans)
    {
        self.title = NSLocalizedString(self.workout.name,nil);
        self.navigationItem.rightBarButtonItem = nil;
        self.addExercisesView.hidden = YES;
        self.selectTraininPlanView.hidden = NO;
    }
    else //editing possible (custom trainingplans)
    {
        self.navigationTextView = [[NavigationTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 130, 64)];
        self.navigationTextView.titleTextField.text = self.workout.name;
        self.navigationTextView.titleTextField.returnKeyType = UIReturnKeyDone;
        self.navigationTextView.titleTextField.delegate = self;
        self.navigationTextView.descriptionLabel.text = NSLocalizedString(@"ExerciseModificationChangeWorkout_Navbar_Title", nil);
        self.navigationItem.titleView = self.navigationTextView;
        
        self.isInEditingMode = NO;
        
        self.addExercisesView.hidden = NO;
        self.selectTraininPlanView.hidden = YES;
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"createModeON"]) {
        self.navigationTextView.titleTextField.textColor = [UIColor editColor];
        self.navigationTextView.descriptionLabel.textColor = [UIColor editColor];
        self.navigationController.navigationBar.tintColor = [UIColor editColor];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissModalViewController)
                                                 name:@"AddExerciseModalViewControllerDismissed"
                                               object:nil];
}

- (IBAction)finishAddition:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupButtons {
    [self.addExercisesButton setTitle:NSLocalizedString(@"AddExercises_Button_Title", nil) forState:UIControlStateNormal];
    self.addExercisesButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.addExercisesButton.titleLabel.numberOfLines = 2;
    self.addExercisesButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.addExercisesButton.titleLabel.minimumScaleFactor = 0.5;
    
    [self.selectTrainingPlanButton setTitle:NSLocalizedString(@"SelectTrainingplan_Button_Title", nil) forState:UIControlStateNormal];
    self.selectTrainingPlanButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.selectTrainingPlanButton.titleLabel.numberOfLines = 2;
    self.selectTrainingPlanButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.selectTrainingPlanButton.titleLabel.minimumScaleFactor = 0.5;
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Add_superset_Label",nil) attributes:@{
                                                                                                                                               NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12],
                                                                                                                                               NSForegroundColorAttributeName : [UIColor darkGrayColor],
                                                                                                                                               }];
    [self.addSupersetButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    attributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Done_Button_Title",nil) attributes:@{
                                                                                                                                                NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12],
                                                                                                                                                NSForegroundColorAttributeName : [UIColor darkGrayColor],
                                                                                                                                                }];
    [self.addingFinishedButton setAttributedTitle:attributedString forState:UIControlStateNormal];
}

- (void)didDismissModalViewController
{
    [self fillExerciseObjects];
    [self.workoutModificationTableView reloadData];
    [self refreshRightBarButton];
}

#pragma mark - ExerciseListViewControllerDelegate methods

- (void)supersetChangeFinished:(NSOrderedSet *)exerciseMetaMappings {
    NSMutableOrderedSet *exerciseMutableObjects = [self.exercisesObjects mutableCopy];
    exerciseMutableObjects[self.selectedExerciseIndex] = exerciseMetaMappings;
    self.exercisesObjects = [exerciseMutableObjects copy];
    [self saveChangedWorkout];
}

- (void)saveChangedWorkout {
    NSMutableOrderedSet *setOfMappings = [NSMutableOrderedSet new];
    for(NSOrderedSet *exerciseMetaMappings in self.exercisesObjects) {
        [setOfMappings addObjectsFromArray:[exerciseMetaMappings array]];
    }
    
    self.workout.exerciseMetaMappings = [setOfMappings copy];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

#pragma mark - data processing

- (void)fillExerciseObjects {
    self.exercisesObjects = [[CurrentFitManager sharedManager] getOrderedSetOfExerciseObjectsForWorkout:self.workout];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fillExerciseObjects];
    [self.workoutModificationTableView reloadData];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.exercisesObjects.count == 0) {
        [self.navigationTextView.titleTextField becomeFirstResponder];
    }
    [self refreshRightBarButton];
}

#pragma mark - Internal

- (void)refreshRightBarButton {
    if (self.exercisesObjects.count == 0) {
        self.welcomeLabel.hidden = NO;
        [self.editButton setTitle:@"    "];
        self.editButton.enabled = NO;
    } else {
        self.welcomeLabel.hidden = YES;
        [self.editButton setTitle:self.isInEditingMode ? NSLocalizedString(@"Done_Button_Title", nil) : NSLocalizedString(@"Edit_Button_Title", nil)];
        self.editButton.enabled = YES;
    }
}

- (void)addSetToExerciseWithWeight:(NSInteger)weight repetition:(NSInteger)repetitions
{
    //check if collectionView cell is add-set cell or normal cell
    ExerciseMetaMapping *exercisMetaMapping = self.exercisesObjects[self.selectedExerciseIndex][0];
    ExerciseMeta *exerciseMeta = (ExerciseMeta *)exercisMetaMapping.exerciseMeta;

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
    
    [self.workoutModificationTableView reloadData];
}

- (void)modifySetWithWeight:(NSInteger)weight repetition:(NSInteger)repetitions
{
    //check if collectionView cell is add-set cell or normal cell
    ExerciseMetaMapping *exercisMetaMapping = self.exercisesObjects[self.selectedExerciseIndex][0];
    ExerciseMeta *exerciseMeta = (ExerciseMeta *)exercisMetaMapping.exerciseMeta;
    
    NSArray *exerciseSets = [exerciseMeta.sets array];
    if (!exerciseSets)
    {
        exerciseSets = [[NSMutableArray alloc] init];
    }
    WorkoutSet *selectedSet = exerciseSets[self.selectedSetIndex];
    selectedSet.weights = @(weight);
    selectedSet.repetitions = @(repetitions);
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [self.workoutModificationTableView reloadData];
}

#pragma mark - IBActions

- (IBAction)addExerciseButtonTapped:(id)sender {
    self.isInEditingMode = false;

    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"exerciseListNavigationController"];
    navigationController.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;

    MuscleGroupSelectionViewController *muscleSelectionViewController = navigationController.viewControllers[0];
    muscleSelectionViewController.exercisesAreSelectable = YES;
    muscleSelectionViewController.workout = self.workout;

    MZFormSheetPresentationViewController *formSheetController = [[MZFormSheetPresentationViewController alloc] initWithContentViewController:navigationController];
    formSheetController.presentationController.contentViewSize = CGSizeMake(self.view.bounds.size.width*0.95, self.view.bounds.size.height*0.65);
    
    [self presentViewController:formSheetController animated:YES completion:nil];
}

- (IBAction)addSupersetButtonTapped:(id)sender {
    self.isInEditingMode = false;
    
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"exerciseListNavigationController"];
    navigationController.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    
    MuscleGroupSelectionViewController *muscleSelectionViewController = navigationController.viewControllers[0];
    muscleSelectionViewController.exercisesAreSelectable = YES;
    muscleSelectionViewController.isSuperset = YES;
    muscleSelectionViewController.workout = self.workout;
    
    MZFormSheetPresentationViewController *formSheetController = [[MZFormSheetPresentationViewController alloc] initWithContentViewController:navigationController];
    formSheetController.presentationController.contentViewSize = CGSizeMake(self.view.bounds.size.width*0.95, self.view.bounds.size.height*0.65);
    
    [self presentViewController:formSheetController animated:YES completion:nil];
}

- (IBAction)selectTraininPlanButtonPressed:(id)sender
{
    BOOL duplicateTraininprogram = self.editModeIsUnavailable;
    [[CurrentFitManager sharedManager] saveCurrentProgram:self.workout.trainingProgram dublicate:duplicateTraininprogram];
    //copy trainingplan then save it to nsuserdefaults
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)editExercisesButtonPressed:(UIBarButtonItem *)sender
{
    if (!self.rightBarButtonName)
    { //we're editing exercises
        self.isInEditingMode = !self.isInEditingMode;
        [sender setTitle:(self.isInEditingMode ? NSLocalizedString(@"Done_Button_Title", nil) : NSLocalizedString(@"Edit_Button_Title", nil))];
        [self.workoutModificationTableView setEditing:self.isInEditingMode animated:YES];
        [self fillExerciseObjects];
        [UIView animateWithDuration:1 animations:^{
            [self.workoutModificationTableView reloadData];
        }];
    }
    else
    { //if we're editing tr.plan name
        [self.navigationTextView.titleTextField resignFirstResponder];
        self.navigationTextView.descriptionLabel.alpha = 1;
        [self refreshRightBarButton];
        self.rightBarButtonName = nil;
    }
}


#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!self.isInEditingMode && !self.editModeIsUnavailable) // mode where sets can be modified
    {
        return self.exercisesObjects.count * 2;
    }
    else
    {
        return self.exercisesObjects.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0 || self.isInEditingMode || self.editModeIsUnavailable)
    {
        static NSString *cellIdentifier = @"WorkoutModificationCell";
        WorkoutModificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        NSInteger index = (!self.isInEditingMode && !self.editModeIsUnavailable) ? (indexPath.row + 1) / 2 : indexPath.row;
        NSArray *exercisMetaMappings = self.exercisesObjects[index];
        if(exercisMetaMappings.count == 1) {
            ExerciseMetaMapping *exerciseMetaMapping = exercisMetaMappings[0];
            Exercise *exercise = (Exercise *)exerciseMetaMapping.exercise;
            cell.workoutTitleLabel.text = NSLocalizedString(exercise.name,nil);
            
            Images *image = exercise.images.count > 6 ? [exercise.images objectAtIndex:6] : [exercise.images objectAtIndex:0];
            cell.workoutImageView.image = [UIImage imageWithData:image.image];
        } else {
            NSMutableAttributedString *names = [NSMutableAttributedString new];
            int i = 1;
            for (ExerciseMetaMapping *exerciseMetaMapping in exercisMetaMappings) {
                Exercise *exercise = (Exercise *)exerciseMetaMapping.exercise;
                NSString *name = [NSString stringWithFormat:@"► %@", NSLocalizedString(exercise.name,nil)];
                if(exerciseMetaMapping != [exercisMetaMappings lastObject]) {
                    name = [name stringByAppendingString:@"\n"];
                }
                
                NSMutableAttributedString *stringName = [[NSMutableAttributedString alloc] initWithString:name];
                NSRange range = NSMakeRange(0, 1);
                [stringName addAttribute:NSForegroundColorAttributeName
                               value:[UIColor arrayOfWorkoutColors][i-1]
                               range:range];

                [names appendAttributedString:stringName];
                i++;
            }
            cell.workoutTitleLabel.attributedText = names;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.workoutImageView.image = [UIImage imageNamed:@"default_image"];
        }

        
        return cell;
    }
    else
    {
        static NSString *cellIdentifier = @"ExerciseModificationCell";
        ExerciseDetailCollectionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        return cell;
    }
}

#pragma mark - TableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ExerciseModificationTableViewCell class]])
    {
        ExerciseModificationTableViewCell *tableViewCell = (ExerciseModificationTableViewCell *)cell;
        NSInteger index = !self.isInEditingMode ? (indexPath.row - 1) / 2 : indexPath.row;
        [tableViewCell setCollectionViewDataSourceDelegate:self index:index];
    }
    
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[WorkoutModificationTableViewCell class]])
    {
        NSInteger index = (!self.isInEditingMode && !self.editModeIsUnavailable) ? (indexPath.row) / 2 : indexPath.row;
        NSOrderedSet *exercisMetaMappings = self.exercisesObjects[index];
        if(exercisMetaMappings.count == 1) {
            ExerciseMetaMapping *exerciseMetaMapping = exercisMetaMappings[0];
            self.selectedExercise = (Exercise *)exerciseMetaMapping.exercise;
            [self performSegueWithIdentifier:@"showExerciseDetails" sender:nil];
        } else {
            self.selectedExerciseMappings = exercisMetaMappings;
            self.selectedExerciseIndex = index;
            [self performSegueWithIdentifier:@"showSupersetExercises" sender:nil];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.isInEditingMode && !self.editModeIsUnavailable;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.isInEditingMode && !self.editModeIsUnavailable;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSMutableOrderedSet *exerciseMutableObjects = [self.exercisesObjects mutableCopy];
    NSObject *exerciseObjectToMove = [exerciseMutableObjects objectAtIndex:sourceIndexPath.row];
    [exerciseMutableObjects removeObjectAtIndex:sourceIndexPath.row];
    [exerciseMutableObjects insertObject:exerciseObjectToMove atIndex:destinationIndexPath.row];
    self.exercisesObjects = [exerciseMutableObjects copy];
    [self saveChangedWorkout];
}

// Swipe to delete.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[WorkoutModificationTableViewCell class]])
        {
            NSArray *exerciseMetaMappings = self.exercisesObjects[indexPath.row];
            for(ExerciseMetaMapping *mapping in exerciseMetaMappings) {
                ExerciseMeta *exerciseMeta = (ExerciseMeta *)mapping.exerciseMeta;
                [[NSManagedObjectContext MR_defaultContext] deleteObject:mapping];
                [[NSManagedObjectContext MR_defaultContext] deleteObject:exerciseMeta];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            }
            
            [self fillExerciseObjects];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            if(self.exercisesObjects.count == 0) {
                self.welcomeLabel.hidden = NO;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    ExerciseMetaMapping *exerciseMetaMapping = self.exercisesObjects[collectionView.tag][0];
    ExerciseMeta *exerciseMeta = (ExerciseMeta *)exerciseMetaMapping.exerciseMeta;
    NSArray *sets = [exerciseMeta.sets array];
    return sets.count+1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //check if collectionView cell is add-set cell or normal cell
    NSOrderedSet *exerciseMetaMappings = self.exercisesObjects[collectionView.tag];
    ExerciseMetaMapping *mapping = exerciseMetaMappings[0];
    ExerciseMeta *exerciseMeta = (ExerciseMeta *)mapping.exerciseMeta;
    NSArray *sets = [exerciseMeta.sets array];
    
    if(indexPath.row >= sets.count)
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddSetCollectionViewCell" forIndexPath:indexPath];
        return cell;
    }
    else
    {
        ExerciseDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ExerciseDetailCollectionViewCell" forIndexPath:indexPath];
        [cell setupWithExerciseMetaMappings:exerciseMetaMappings withIndexPath:indexPath isActive:NO];
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSOrderedSet *exerciseMetaMappings = self.exercisesObjects[collectionView.tag];
    ExerciseMetaMapping *mapping = exerciseMetaMappings[0];
    ExerciseMeta *exerciseMeta = (ExerciseMeta *)mapping.exerciseMeta;
    NSArray *sets = [exerciseMeta.sets array];
    
    if(indexPath.row >= sets.count)
    {
        return CGSizeMake(85, 85);
    }
    
    return CGSizeMake([self getCellWidthForCollectionViewWithTag:collectionView.tag], 85);
}

- (CGFloat)getCellWidthForCollectionViewWithTag:(NSInteger)tag {
    CGFloat cellWidth;
    NSOrderedSet *exerciseMetaMappings = self.exercisesObjects[tag];
    NSUInteger numberOfExercisesInSet = exerciseMetaMappings.count;
    
    switch(numberOfExercisesInSet)
    {
        case 1: { cellWidth = 85; break; }
        case 2: { cellWidth = 165; break; }
        case 3: { cellWidth = 220; break; }
        case 4: { cellWidth = 250; break; }
        default: { cellWidth = 250; break; }
    }
    
    return cellWidth;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCollection = collectionView;
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ExerciseDetailCollectionViewCell class]])
    {
        self.addSetButtonPressed = NO;
        self.selectedExerciseIndex = collectionView.tag;
    }
    else
    {
        self.selectedExerciseIndex = collectionView.tag;
        self.addSetButtonPressed = YES;
    }
    
    self.selectedSetIndex = indexPath.row;
    
    NSOrderedSet *exerciseMetaMappingsArray = self.exercisesObjects[self.selectedExerciseIndex];
    if(exerciseMetaMappingsArray.count == 1) {
        [self showEditSetActionSheetFromSender:cell];
    } else {
        [self performSegueWithIdentifier:@"supersetEditSegueID" sender:nil];
    }
}

#pragma mark - ActionSheetPickerStuff

- (void)showEditSetActionSheetFromSender:(id)sender
{
    EditSetActionSheetPickerDelegate *delg = [[EditSetActionSheetPickerDelegate alloc] init];
    
    delg.onActionSheetDone = ^(AbstractActionSheetPicker *picker, NSInteger selectedWeight, NSInteger selectedRepetition) {
        
        [self setEditingDoneWithRepetitions:@(selectedRepetition) weight:@(selectedWeight)];
    };

    NSOrderedSet *exerciseMetaMappings = self.exercisesObjects[self.selectedExerciseIndex]; //this method is called only when this array consists of only one object
    ExerciseMetaMapping *exercisMetaMapping = exerciseMetaMappings[0];
    ExerciseMeta *exerciseMeta = (ExerciseMeta *)exercisMetaMapping.exerciseMeta;
    NSArray *sets = [exerciseMeta.sets array];
    
    NSNumber *selectedWeight, *selectedRepetition;
    if (self.addSetButtonPressed)
    {
        selectedWeight = (self.selectedWeight == -1 ?@(10) : @(self.selectedWeight));
        selectedRepetition = (self.selectedRepetitions == -1 ?@(9) : @(self.selectedRepetitions-1));
    }
    else
    {
        WorkoutSet *set = sets[self.selectedSetIndex];
        selectedWeight = @([set.weights integerValue]);
        selectedRepetition = @([set.repetitions integerValue]-1);
        
        //only add to delegate if set was already created - then it could be deleted
        delg.cancelButtonActsAsDelete = YES;
        delg.onActionSheetDelete = ^(AbstractActionSheetPicker *picker) {
            [self deleteEditingSet];
        };
    }
    
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
        cancelButton.title = (self.addSetButtonPressed ? NSLocalizedString(@"Cancel_Button_Title", nil) : NSLocalizedString(@"Delete_Button_Title", nil));
        [cancelButton setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          (self.addSetButtonPressed ? [UIColor blackColor] : [UIColor redColor]), NSForegroundColorAttributeName,nil]
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
    weightLabel.font = [UIFont systemFontOfSize:24];
    [overlay addSubview:weightLabel];
    
    UILabel *repLabel = [[UILabel alloc] initWithFrame:CGRectMake(270, 54, 60, 30)];
    repLabel.text = NSLocalizedString(@"PickerView_Repetions_Label_Text", nil);
    repLabel.font = [UIFont systemFontOfSize:24];
    [overlay addSubview:repLabel];
    
    [customPicker.pickerView addSubview:overlay];
}

- (void)setEditingDoneWithRepetitions:(NSNumber *)repetitions weight:(NSNumber *)weight
{
    self.selectedRepetitions = [repetitions integerValue];
    self.selectedWeight = [weight integerValue];
    if (self.addSetButtonPressed)
    {
        [self addSetToExerciseWithWeight:[weight integerValue] repetition:[repetitions integerValue]];
        [[CurrentFitManager sharedManager] saveCurrentTraining];
    }
    else
    {
        [self modifySetWithWeight:[weight integerValue] repetition:[repetitions integerValue]];
    }
}

- (void)deleteEditingSet
{
    //called only for simple sets
    NSArray *exerciseMetaMappings = self.exercisesObjects[self.selectedExerciseIndex];
    ExerciseMetaMapping *exercisMetaMapping = exerciseMetaMappings[0];
    ExerciseMeta *exerciseMeta = (ExerciseMeta *)exercisMetaMapping.exerciseMeta;
    NSArray *sets = [exerciseMeta.sets array];
    WorkoutSet *setToDelete = sets[self.selectedSetIndex];
    
    [[NSManagedObjectContext MR_defaultContext] deleteObject:setToDelete];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

    [self.workoutModificationTableView reloadData];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.rightBarButtonName = self.navigationItem.rightBarButtonItem.title;
    self.navigationItem.rightBarButtonItem.title = @"       ";
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationTextView.descriptionLabel.alpha = 0;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem.title = self.rightBarButtonName;
    self.rightBarButtonName = nil;
    self.navigationTextView.descriptionLabel.alpha = 1;
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.workout.name = textField.text;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.isInEditingMode = false;
    if ([segue.identifier isEqualToString:@"showExerciseDetails"])
    {
        ExerciseDescriptionViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.exercise = self.selectedExercise;
    }
    
    if ([segue.identifier isEqualToString:@"supersetEditSegueID"])
    {
        UINavigationController *navController = [segue destinationViewController];
        AddEditSetViewController *destinationViewController = [[navController viewControllers] firstObject];
        NSOrderedSet *exerciseMetaMappingsArray = self.exercisesObjects[self.selectedExerciseIndex];
        destinationViewController.exerciseMetaMappings = exerciseMetaMappingsArray;
        destinationViewController.delegate = self;
        destinationViewController.needSaveResults = NO;
        if(self.addSetButtonPressed) {
            destinationViewController.editingSetIndex = -1;
        } else {
            destinationViewController.editingSetIndex = (int)self.selectedSetIndex;
            ExerciseMetaMapping *mm = self.exercisesObjects[self.selectedExerciseIndex][0];
            if(mm.exerciseMeta.sets.count == 1) {
                destinationViewController.disableDelete = YES;
            }
        }
    }
    
    if ([segue.identifier isEqualToString:@"showSupersetExercises"]) {
        ExercisesListViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.delegate = self;
        destinationViewController.exerciseMetaMappings = self.selectedExerciseMappings;
    }
}

- (void)setEditingDone
{
    if(self.selectedCollection) {
        [self.selectedCollection reloadData];
        [self.selectedCollection scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedSetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}



@end
