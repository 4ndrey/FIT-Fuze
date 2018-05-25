//
//  WorkoutExecutionSideMenuViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 13.07.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "WorkoutExecutionSideMenuViewController.h"
#import "WorkoutExecutionSideMenuCellTableViewCell.h"
#import "WorkoutExecutionWatchdog.h"

@interface WorkoutExecutionSideMenuViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *workoutTableView;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UIImageView *chainIcon;
@property (weak, nonatomic) IBOutlet UIView *leftLine;
@property (weak, nonatomic) IBOutlet UIView *rightLine;

@end

@implementation WorkoutExecutionSideMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)exitButtonPressed:(id)sender
{
    [self.sideMenuRootViewController finishWorkout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.exitButton setTitle:NSLocalizedString(@"exitButton_title", nil) forState:UIControlStateNormal];
}

- (void)forceRefresh
{
    [self.workoutTableView reloadData];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.workout.exerciseMetaMappings.count;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //detail exercise cells
    ExerciseMetaMapping *exercisMetaMapping = self.workout.exerciseMetaMappings[indexPath.row];
        
    if(!exercisMetaMapping.withNext) {
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
    } else {
        // Remove seperator inset
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 1000, 0, 0)];
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        
        // Explictly set your cell's layout margins
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsMake(0, 1000, 0, 0)];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"WorkoutExecutionSideMenuCell";
    WorkoutExecutionSideMenuCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    ExerciseMetaMapping *exercisMetaMapping = self.workout.exerciseMetaMappings[indexPath.row];
    Exercise *exercise = (Exercise *)exercisMetaMapping.exercise;
    cell.exerciseName.text = NSLocalizedString(exercise.name,nil);
    cell.withNext = exercisMetaMapping.withNext;
    
    ExerciseExecutionStatusType status = [[WorkoutExecutionWatchdog sharedWatchdog] statusForExercise:exercise];
    
    switch (status) {
        case ExerciseExecutionStatusInProgress:
            cell.exerciseProgressImage.image = [UIImage imageNamed:@"NextRainingPlan"];
            break;
            
        case ExerciseExecutionStatusFinished:
            cell.exerciseProgressImage.image = [UIImage imageNamed:@"Set-Succeed-button"];
            break;
            
        case ExerciseExecutionStatusSkipped:
            cell.exerciseProgressImage.image = [UIImage imageNamed:@"skipped"];
            break;
            
        default:
            cell.exerciseProgressImage.image = [UIImage imageNamed:@"emptyState"];
            break;
    }
    
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExerciseMetaMapping *exerciseMetaMapping = self.workout.exerciseMetaMappings[indexPath.row];
    int nextIdx = (int)[self.workout.exerciseMetaMappings indexOfObject:exerciseMetaMapping];

    for(int i = 0; i < [self.workout.exerciseMetaMappings indexOfObject:exerciseMetaMapping]; i++) {
        ExerciseMetaMapping *mapping = [self.workout.exerciseMetaMappings objectAtIndex:i];
        if(mapping.withNext) {
            nextIdx--;
        }
    }
    
    [self.sideMenuRootViewController jumpToExerciseAtIndex:nextIdx];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

@end
