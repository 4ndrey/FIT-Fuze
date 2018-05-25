//
//  ExercisesListViewController.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 25/06/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import "ExercisesListViewController.h"
#import "WorkoutModificationTableViewCell.h"
#import "FIT-Swift.h"
#import "ExerciseDescriptionViewController.h"
#import "MuscleGroupSelectionViewController.h"
#import "MZFormSheetPresentationViewController.h"
@import MagicalRecord;

@interface ExercisesListViewController () <UITableViewDelegate, UITableViewDataSource, ExerciseSelectionDelegate>

@property (nonatomic, strong) Exercise *selectedExercise;
@property (nonatomic) BOOL isInEditingMode;
@property (strong, nonatomic) IBOutlet UITableView *exercisesTableView;
@property (strong, nonatomic) IBOutlet UIVisualEffectView *bottomVisualEffect;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editBarButton;

@end

@implementation ExercisesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Superset_Modification_Title", nil);
    [self.editBarButton setTitle: NSLocalizedString(@"Edit_Button_Title", nil)];
    [self.exercisesTableView setContentInset:UIEdgeInsetsMake(0,0,65,0)];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.exerciseMetaMappings.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (IBAction)editExercisesButtonPressed:(UIBarButtonItem *)sender
{
    self.isInEditingMode = !self.isInEditingMode;
    self.bottomVisualEffect.hidden = self.isInEditingMode;
    
    [self.exercisesTableView setContentInset:UIEdgeInsetsMake(0,0, self.bottomVisualEffect.hidden ? 0 : 65,0)];
    
    [self.editBarButton setTitle:self.isInEditingMode ? NSLocalizedString(@"Done_Button_Title", nil) : NSLocalizedString(@"Edit_Button_Title", nil)];
    [self.exercisesTableView setEditing:self.isInEditingMode animated:YES];
    [UIView animateWithDuration:1 animations:^{
        [self.exercisesTableView reloadData];
    }];
}

- (IBAction)addExerciseButtonTapped:(id)sender {
    self.isInEditingMode = false;
    
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"exerciseListNavigationController"];
    navigationController.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    
    MuscleGroupSelectionViewController *muscleSelectionViewController = navigationController.viewControllers[0];
    muscleSelectionViewController.exercisesAreSelectable = YES;
    muscleSelectionViewController.delegate = self;

    MZFormSheetPresentationViewController *formSheetController = [[MZFormSheetPresentationViewController alloc] initWithContentViewController:navigationController];
    formSheetController.presentationController.contentViewSize = CGSizeMake(self.view.bounds.size.width*0.95, self.view.bounds.size.height*0.65);
    
    [self presentViewController:formSheetController animated:YES completion:nil];
}

- (void)exerciseSelected:(NSArray *)exercisesSelected {
    ExerciseMetaMapping *basicMapping = self.exerciseMetaMappings[0];
    long numberOfSets = basicMapping.exerciseMeta.sets.count;
    
    for(Exercise *exercise in exercisesSelected) {
        ExerciseMetaMapping *newExerciseMetaMapping = [NSEntityDescription insertNewObjectForEntityForName:@"ExerciseMetaMapping" inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
        newExerciseMetaMapping.exercise = exercise;
        
        //create metaObject
        ExerciseMeta *newExerciseMeta = [NSEntityDescription insertNewObjectForEntityForName:@"ExerciseMeta" inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
        newExerciseMetaMapping.exerciseMeta = newExerciseMeta;
        newExerciseMeta.defaultRepetitions = @10;
        newExerciseMeta.defaultRestTime = @60;
        
        NSMutableArray *exerciseSets = [[newExerciseMeta.sets array] mutableCopy];
        if (!exerciseSets)
        {
            exerciseSets = [[NSMutableArray alloc] init];
        }
        
        for(int i = 0; i < numberOfSets; i++) {
            WorkoutSet *newSet = [NSEntityDescription insertNewObjectForEntityForName:@"WorkoutSet" inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
            newSet.weights = @(10);
            newSet.repetitions = @(10);
            [exerciseSets addObject:newSet];
        }

        [newExerciseMeta setSets:[[NSOrderedSet alloc] initWithArray:exerciseSets]];
        NSMutableOrderedSet *emm = [self.exerciseMetaMappings mutableCopy];
        [emm addObject:newExerciseMetaMapping];
        self.exerciseMetaMappings = [emm copy];
    }
    
    for(ExerciseMetaMapping *mapping in self.exerciseMetaMappings) {
        mapping.withNext = YES;
    }
    ExerciseMetaMapping *mapping = self.exerciseMetaMappings.lastObject;
    mapping.withNext = NO;
    [self.exercisesTableView reloadData];
    [self.delegate supersetChangeFinished: self.exerciseMetaMappings];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ExerciseCell";
    WorkoutModificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSInteger index = indexPath.row;
    ExerciseMetaMapping *exerciseMetaMapping = self.exerciseMetaMappings[index];
    Exercise *exercise = (Exercise *)exerciseMetaMapping.exercise;
    cell.workoutTitleLabel.text = NSLocalizedString(exercise.name,nil);
    Images *image = exercise.images.count > 6 ? [exercise.images objectAtIndex:6] : [exercise.images objectAtIndex:0];
    cell.workoutImageView.image = [UIImage imageWithData:image.image];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExerciseMetaMapping *exerciseMetaMapping = self.exerciseMetaMappings[indexPath.row];
    self.selectedExercise = (Exercise *)exerciseMetaMapping.exercise;
    [self performSegueWithIdentifier:@"showExerciseDetails" sender:nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[WorkoutModificationTableViewCell class]])
        {            
            ExerciseMetaMapping *exerciseMetaMapping = self.exerciseMetaMappings[indexPath.row];
            ExerciseMeta *exerciseMeta = (ExerciseMeta *) exerciseMetaMapping.exerciseMeta;
            [[NSManagedObjectContext MR_defaultContext] deleteObject:exerciseMetaMapping];
            [[NSManagedObjectContext MR_defaultContext] deleteObject:exerciseMeta];
            
            NSMutableOrderedSet *set = [self.exerciseMetaMappings mutableCopy];
            [set removeObject:exerciseMetaMapping];
            self.exerciseMetaMappings = [set copy];
            ExerciseMetaMapping *metaMappingToUpdate = [self.exerciseMetaMappings lastObject];
            metaMappingToUpdate.withNext = NO;
            
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.isInEditingMode;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.isInEditingMode;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSMutableOrderedSet *exerciseMutableMetaMappings = [self.exerciseMetaMappings mutableCopy];
    ExerciseMetaMapping *exerciseObjectToMove = [exerciseMutableMetaMappings objectAtIndex:sourceIndexPath.row];
    
    [exerciseMutableMetaMappings removeObjectAtIndex:sourceIndexPath.row];
    [exerciseMutableMetaMappings insertObject:exerciseObjectToMove atIndex:destinationIndexPath.row];
    
    for(ExerciseMetaMapping *mapping in exerciseMutableMetaMappings) {
        mapping.withNext = YES;
    }
    ExerciseMetaMapping *mapping = exerciseMutableMetaMappings.lastObject;
    mapping.withNext = NO;
    
    self.exerciseMetaMappings = [exerciseMutableMetaMappings copy];
    [self.delegate supersetChangeFinished: self.exerciseMetaMappings];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showExerciseDetails"])
    {
        ExerciseDescriptionViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.exercise = self.selectedExercise;
    }
}


@end
