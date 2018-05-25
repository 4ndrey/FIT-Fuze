//
//  AddEditSetViewController.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 22/05/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import "AddEditSetViewController.h"
#import "FIT-Swift.h"
#import "ExerciseDescriptionViewController.h"
#import "AddEditSetTableViewCell.h"
#import "WorkoutExecutionWatchdog.h"
@import MagicalRecord;

@interface AddEditSetViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, assign) NSUInteger currentExerciseIndex;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextDoneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation AddEditSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentExerciseIndex = 0;
    // Do any additional setup after loading the view.
    if([self isAddingNew]) {
        self.title = NSLocalizedString(@"Add_new_set_Label", nil);
    } else {
        self.title = NSLocalizedString(@"Change_existing_set_Label", nil);
    }
    [self.deleteButton setTitle:NSLocalizedString(@"Delete_set_button_title", nil) forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.nextDoneButton.title = NSLocalizedString(@"Done_Button_Title", nil);
    self.cancelButton.title = NSLocalizedString(@"Cancel_Button_Title", nil);
    if(self.disableDelete || self.editingSetIndex == -1) {
        self.deleteButton.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    AddEditSetTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell setActive];
}

- (BOOL)isAddingNew
{
    return (self.editingSetIndex == -1);
}

- (BOOL)checkIfAllFieldsAreFilled
{
    BOOL everythingIsFilled = YES;
    
    for(int i = 0; i < self.exerciseMetaMappings.count && everythingIsFilled; i++) {
        AddEditSetTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if([cell isSomethingMissing]) {
            [cell setActive];
            everythingIsFilled = NO;
        }
    }
    
    return everythingIsFilled;
}

- (IBAction)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonPressed:(id)sender {
    
    if([self isAddingNew]) {
        if([self checkIfAllFieldsAreFilled]) {
            [self addNewSet];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:NSLocalizedString(@"Not_filled_properly_Alert", nil)
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
    } else {
        [self saveUpdatedSet];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewController methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.exerciseMetaMappings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"exerciseCellID";
    AddEditSetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    ExerciseMetaMapping *mapping = self.exerciseMetaMappings[indexPath.row];
    [cell setupWithExerciseMetaMappings:mapping withSetIndex:self.editingSetIndex == -1 ? (int)(mapping.exerciseMeta.sets.count - 1) : self.editingSetIndex];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (void)addNewSet {
    for(int i = 0; i < self.exerciseMetaMappings.count; i++) {
        AddEditSetTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        ExerciseMetaMapping *exerciseMetaMapping = cell.exerciseMetaMapping;
        ExerciseMeta *exerciseMeta = exerciseMetaMapping.exerciseMeta;
        NSMutableArray *exerciseSets = [[exerciseMeta.sets array] mutableCopy];
        if (!exerciseSets)
        {
            exerciseSets = [[NSMutableArray alloc] init];
        }
        WorkoutSet *newSet = [NSEntityDescription insertNewObjectForEntityForName:@"WorkoutSet" inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
        newSet.weights = @(cell.weight);
        newSet.repetitions = @(cell.repetitions);
        [exerciseSets addObject:newSet];
        [exerciseMeta setSets:[[NSOrderedSet alloc] initWithArray:exerciseSets]];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    [self.delegate setEditingDone];
}

- (void)saveUpdatedSet
{
    for(int i = 0; i < self.exerciseMetaMappings.count; i++) {
        AddEditSetTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        ExerciseMetaMapping *exerciseMetaMapping = cell.exerciseMetaMapping;
        ExerciseMeta *exerciseMeta = exerciseMetaMapping.exerciseMeta;
        WorkoutSet *exerciseSet = [exerciseMeta.sets array][self.editingSetIndex];
        exerciseSet.repetitions = @(cell.repetitions);
        exerciseSet.weights = @(cell.weight);
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    
    if(self.needSaveResults) {
        for(int i = 0; i < self.exerciseMetaMappings.count; i++) {
            AddEditSetTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            ExerciseMetaMapping *exerciseMetaMapping = cell.exerciseMetaMapping;
            Exercise *currentExercise = exerciseMetaMapping.exercise;
            
            [[WorkoutExecutionWatchdog sharedWatchdog] saveResultForExerciseWithName:currentExercise.name withWeight:cell.weight andReps:cell.repetitions];
        }
    }
    
    [self.delegate setEditingDone];
}

- (IBAction)deleteButtonPressed:(id)sender {
    for(int i = 0; i < self.exerciseMetaMappings.count; i++) {
        AddEditSetTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        ExerciseMetaMapping *exerciseMetaMapping = cell.exerciseMetaMapping;
        ExerciseMeta *exerciseMeta = exerciseMetaMapping.exerciseMeta;
        WorkoutSet *exerciseSet = [exerciseMeta.sets array][self.editingSetIndex];
        NSMutableOrderedSet *setToChange = [NSMutableOrderedSet orderedSetWithOrderedSet: exerciseMeta.sets];
        [setToChange removeObject:exerciseSet];
        exerciseMeta.sets = [setToChange copy];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    [self.delegate setEditingDone];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
