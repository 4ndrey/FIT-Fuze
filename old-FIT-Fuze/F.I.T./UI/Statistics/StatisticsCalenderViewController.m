//
//  StatisticsCalenderViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 08.07.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "StatisticsCalenderViewController.h"
#import "THDatePickerViewController.h"
#import "WorkoutModificationTableViewCell.h"
#import "FIT-Swift.h"
#import "ExerciseModificationCollectionViewCell.h"
#import "SettingsViewController.h"
#import "ExerciseModificationTableViewCell.h"
#import "StatisticsContainerViewController.h"
#import "UIColor+FIT.h"
@import MagicalRecord;

@interface StatisticsCalenderViewController () <THDatePickerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) THDatePickerViewController * datePicker;
@property (nonatomic, strong) NSArray *exercisesWithStatistics;
@property (nonatomic, strong) NSArray *datesWithStatistics;
@property (strong, nonatomic) StatisticsProvider *statisticProvider;
@property (strong, nonatomic) NSDate *selectedDate;
@property (weak, nonatomic) IBOutlet UITableView *statisticsTableView;
@property (strong, nonatomic) NSDateFormatter *dateComparisonFormatter;
@property (weak, nonatomic) IBOutlet UILabel *noStatisticsLabel;

@end

@implementation StatisticsCalenderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.noStatisticsLabel.text = NSLocalizedString(@"NoStatisticsOnThisDate_Label_Text", nil);
    self.exercisesWithStatistics = [self getExercisesForDate:[NSDate date]];
    self.dateComparisonFormatter = [[NSDateFormatter alloc] init];
    [self.dateComparisonFormatter setDateFormat:@"yyyy-MM-dd"];
    self.datesWithStatistics = [self getAllDatesWithStatistics];
    [self setupPicker];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.exercisesWithStatistics.count == 0) {
        self.noStatisticsLabel.hidden = NO;
    } else {
        self.noStatisticsLabel.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.exercisesWithStatistics.count == 0) {
        [self changeDate];
    }
}

- (void)setupPicker
{
    
    self.selectedDate = [NSDate date];
    self.datePicker = [THDatePickerViewController datePicker];
    self.datePicker.date = self.selectedDate;
    self.datePicker.delegate = self;
    [self.datePicker setAllowClearDate:NO];
    [self.datePicker setClearAsToday:YES];
    [self.datePicker setAutoCloseOnSelectDate:NO];
    [self.datePicker setAllowSelectionOfSelectedDate:YES];
    [self.datePicker setDisableHistorySelection:NO];
    [self.datePicker setDisableFutureSelection:NO];
    //[self.datePicker setAutoCloseCancelDelay:5.0];
    [self.datePicker setSelectedBackgroundColor:[UIColor mainColor]];
    self.datePicker.currentDateColorSelected = [UIColor mainColor];
    [self.datePicker setCurrentDateColorSelected:[UIColor whiteColor]];
    
    __weak typeof(self) weakself = self;
    [self.datePicker setDateHasItemsCallback:^BOOL(NSDate *date) {
        NSString *formattedDate = [weakself.dateComparisonFormatter stringFromDate:date];
        return [weakself.datesWithStatistics containsObject:formattedDate];
    }];
}

- (void)changeDate
{
    [self presentSemiViewController:self.datePicker withOptions:@{
                                                                  KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                                  KNSemiModalOptionKeys.animationDuration : @(0.5),
                                                                  KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
                                                                  }];
}

#pragma mark - TableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ExerciseModificationTableViewCell class]])
    {
        ExerciseModificationTableViewCell *tableViewCell = (ExerciseModificationTableViewCell *)cell;
        NSInteger index = (indexPath.row - 1) / 2;
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


#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.exercisesWithStatistics.count * 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row % 2 == 0)
    {
        static NSString *cellIdentifier = @"WorkoutModificationCell";
        WorkoutModificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        Exercise *exercise = self.exercisesWithStatistics[indexPath.row/2];
        cell.workoutTitleLabel.text = NSLocalizedString(exercise   .name,nil);
        Images *image = exercise.images.count > 6 ? [exercise.images objectAtIndex:6] : [exercise.images objectAtIndex:0];
        cell.workoutImageView.image = [UIImage imageWithData:image.image];
        
        return cell;
        
    }
    else
    {
        static NSString *cellIdentifier = @"ExerciseModificationCell";
        ExerciseModificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return self.exercisesWithStatistics.count == 0 ? 0.01 : 0;
}


#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *statisticsForExercise = [self getStatisticsForDate:self.selectedDate andExercise:self.exercisesWithStatistics[collectionView.tag]];
    return statisticsForExercise.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
//    NSArray *statisticsForExercise = [self.statisticProvider getHistoryWithExercise:((Exercise *)self.exercisesWithStatistics[collectionView.tag]).name];
    NSArray *statisticsForExercise = [self getStatisticsForDate:self.selectedDate andExercise:self.exercisesWithStatistics[collectionView.tag]];

    History *history = statisticsForExercise[indexPath.row];
    
    ExerciseModificationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ExerciseModificationCollectionViewCell" forIndexPath:indexPath];
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    NSString *kgOrLbls = [[sharedDefaults objectForKey:kilogrammChoosenKey] boolValue] ? NSLocalizedString(@"kg", nil) : NSLocalizedString(@"lbs", nil);
    
    cell.numberLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)indexPath.row+1, (long)statisticsForExercise.count];
    cell.weightLabel.text = [NSString stringWithFormat:@"%@%@", history.convertedWeight,kgOrLbls];
    cell.repetitionLabel.text = [NSString stringWithFormat:@"×%@ ", history.repetitions];
    
        return cell;
}

#pragma mark - DatePickerDelegate


- (void)datePickerDonePressed:(THDatePickerViewController *)datePicker
{
    self.selectedDate = datePicker.date;
    [self dismissSemiModalView];
}

- (void)datePickerCancelPressed:(THDatePickerViewController *)datePicker
{
    [self dismissSemiModalView];
}

- (void)datePicker:(THDatePickerViewController *)datePicker selectedDate:(NSDate *)selectedDate
{
    self.selectedDate = datePicker.date;
    self.exercisesWithStatistics = [self getExercisesForDate:selectedDate];
    [self.statisticsTableView reloadData];
    [(StatisticsContainerViewController *)self.parentViewController updateNavigationBarItemDate:self.selectedDate];
    if (self.exercisesWithStatistics.count == 0) {
        self.noStatisticsLabel.hidden = NO;
    } else {
        self.noStatisticsLabel.hidden = YES;
    }
}


#pragma mark - Helpers

- (NSArray *)getAllDatesWithStatistics
{
    NSArray *statitics = [History MR_findAllSortedBy:@"date" ascending:YES];
    NSMutableArray *datesWithStatistics = [[NSMutableArray alloc] init];
    for (History *history in statitics)
    {
        NSString *formattedDate = [self.dateComparisonFormatter stringFromDate:history.date];
        if(![datesWithStatistics containsObject:formattedDate])
        {
            [datesWithStatistics addObject:formattedDate];
        }
    }
    return datesWithStatistics;
}


- (NSArray *)getExercisesForDate:(NSDate *)date
{
    NSDate *endDate = [date dateByAddingTimeInterval:1*24*60*60];
    NSDate *startDate = [date dateByAddingTimeInterval:-1*24*60*60];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date <= %@)", startDate, endDate];
    NSArray *statitics = [History MR_findAllSortedBy:@"date" ascending:YES withPredicate:predicate];
    NSMutableArray *exercises = [[NSMutableArray alloc] init];
    for (History *history in statitics)
    {
        if (![exercises containsObject:history.exercise])
        {
            [exercises addObject:history.exercise];
        }
    }
    return exercises;
}

- (NSArray *)getStatisticsForDate:(NSDate *)date andExercise:(Exercise *)exercise
{
    NSDate *endDate = [date dateByAddingTimeInterval:1*24*60*60];
    NSDate *startDate = [date dateByAddingTimeInterval:-1*24*60*60];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date <= %@) AND exercise.name == %@", startDate, endDate, exercise.name];
    NSArray *statitics = [History MR_findAllSortedBy:@"date" ascending:YES withPredicate:predicate];

    return statitics;
}

@end
