//
//  StatisticsViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 25.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "StatisticsGraphViewController.h"
#import "UIColor+FIT.h"
#import "FIT-Swift.h"
#import "SettingsViewController.h"
#import "ActionSheetPicker.h"

#import "Charts/Charts-Swift.h"

@interface StatisticsGraphViewController () <UIPickerViewDataSource, UIPickerViewDelegate, ChartViewDelegate, IChartAxisValueFormatter>

@property (weak, nonatomic) IBOutlet BarChartView *barChart;
@property (weak, nonatomic) IBOutlet UIView *lineChartViewBackground;
@property (strong, nonatomic) NSArray *chartPoints;
@property (strong, nonatomic) NSArray *selectedExerciseStatistics;
@property (strong, nonatomic) NSArray *exercisesWithStatistics;
@property (strong, nonatomic) StatisticsProvider *statisticProvider;
@property (weak, nonatomic) IBOutlet UILabel *selectedExerciseWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedExerciseRepetitionLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *ExercisePicker;
@property (assign, nonatomic) int selectedRow;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (assign, nonatomic) int minWeight;
@property (assign, nonatomic) int maxWeight;
@property (assign, nonatomic) int maxNumberOfReps;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UILabel *pinchHintLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pinchHint;
@property (weak, nonatomic) IBOutlet UILabel *kgOrLbsLabel;

@property (strong, nonatomic) NSString *kgOrLbls;

@end

@implementation StatisticsGraphViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.fitfuze"];
    self.kgOrLbls = [[sharedDefaults objectForKey:kilogrammChoosenKey] boolValue] ? NSLocalizedString(@"kg", nil) : NSLocalizedString(@"lbs", nil);
    [self setYAxisHintWithRepsIfNeeded:NO];
    
    self.pinchHintLabel.text = NSLocalizedString(@"PinchHint_Text", nil);
    self.title = NSLocalizedString(@"Statistics_NavBar_Title", nil);
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"dd.MM.yyyy"];
    self.hintLabel.text = NSLocalizedString(@"StatisticsHint_Text", nil);

    [self setupChart];
    
    if(self.exercisesWithStatistics.count == 0) {
        self.hintLabel.text = @"";
        self.kgOrLbsLabel.hidden = YES;
    }
    
    self.lineChartViewBackground.backgroundColor = [UIColor whiteColor];
    
    self.statisticProvider = [[StatisticsProvider alloc] init];
    self.exercisesWithStatistics = [self.statisticProvider getHistoryExercises];
    self.exercisesWithStatistics = [self.exercisesWithStatistics sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *o1 = obj1;
        NSString *o2 = obj2;
        NSString *first = NSLocalizedString(o1, nil);
        NSString *second = NSLocalizedString(o2, nil);
        return [first compare:second];
    }];
    
    
    [self setDefaultHighlightedValues];
}

- (void)setYAxisHintWithRepsIfNeeded:(BOOL)repsNeeded
{
    if (repsNeeded) {
        self.kgOrLbsLabel.text = NSLocalizedString(@"PickerView_Repetions_Label_Text", nil);
    } else {
        self.kgOrLbsLabel.text = self.kgOrLbls;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.exercisesWithStatistics.count >= 1)
    {
        [self showPinchHint];
        [self loadHistoryForExercise:self.exercisesWithStatistics[self.selectedRow] animated:NO];
        [self reloadBarChart];
    }
}

#pragma mark - Internal

- (UIColor *)getColorNumber:(int)number fromSetWithNumberOfColors:(int)numberOfColors
{
    UIColor *redColor = [UIColor colorWithRed:0xe7/255.0 green:0x4c/255.0 blue:0x3c/255.0 alpha:1.0]; // red
    UIColor *orangeColor = [UIColor colorWithRed:0xe6/255.0 green:0x7e/255.0 blue:0x22/255.0 alpha:1.0]; // orange
    UIColor *yellowColor = [UIColor colorWithRed:0xf1/255.0 green:0xc4/255.0 blue:0x0f/255.0 alpha:1.0]; // yellow
    UIColor *darkGreenColor = [UIColor colorWithRed:0x1a/255.0 green:0xbc/255.0 blue:0x9c/255.0 alpha:1.0]; // turquoise
    UIColor *lightGreenColor = [UIColor colorWithRed:0x2e/255.0 green:0xcc/255.0 blue:0x71/255.0 alpha:1.0]; // green
    UIColor *blueColor = [UIColor colorWithRed:0x34/255.0 green:0x98/255.0 blue:0xdb/255.0 alpha:1.0]; // blue
    UIColor *purpleColor = [UIColor colorWithRed:0x9b/255.0 green:0x59/255.0 blue:0xb6/255.0 alpha:1.0]; // amethyst
    UIColor *grayColor = [UIColor colorWithRed:0x95/255.0 green:0xa5/255.0 blue:0xa6/255.0 alpha:1.0]; // wet asphalt

    NSArray *one_Color = @[redColor];
    NSArray *two_Color = @[redColor, blueColor];
    NSArray *three_Color = @[redColor, yellowColor, blueColor];
    NSArray *four_Color = @[redColor, yellowColor, lightGreenColor, blueColor];
    NSArray *five_Color = @[redColor, yellowColor, lightGreenColor, blueColor, purpleColor];
    NSArray *six_Color = @[redColor, orangeColor, yellowColor, lightGreenColor, blueColor, purpleColor];
    NSArray *seven_Color = @[redColor, orangeColor, yellowColor, lightGreenColor, blueColor, purpleColor, grayColor];
    NSArray *eight_Color = @[redColor, orangeColor, yellowColor, lightGreenColor, darkGreenColor, blueColor, purpleColor, grayColor];

    NSArray *arrayOfColorful = @[one_Color, two_Color, three_Color, four_Color, five_Color, six_Color, seven_Color, eight_Color];
    
    return arrayOfColorful[numberOfColors][number];
}

- (void)showPinchHint
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSDate *date = [defs objectForKey:@"lastHintShowDate"];
    if (!date || [[NSDate date] timeIntervalSinceDate:date] > 60*60*24*7) {
        [UIView animateWithDuration:0.3 animations:^{
            self.pinchHint.alpha = 1.0;
            self.pinchHintLabel.alpha = 1.0;
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.3 animations:^{
                    self.pinchHint.alpha = 0.0;
                    self.pinchHintLabel.alpha = 0.0;
                }];
            });
        }];
        
        [defs setObject:[NSDate date] forKey:@"lastHintShowDate"];
        [defs synchronize];
    } else {
        self.pinchHint.alpha = 0.0;
        self.pinchHintLabel.alpha = 0.0;
    }
}

- (void)setupChart
{
    _barChart.delegate = self;
    
    _barChart.descriptionText = @"";
    _barChart.noDataText = NSLocalizedString(@"NoStatistics_Label_Text", nil);
    _barChart.scaleYEnabled = NO;
    
    _barChart.drawBarShadowEnabled = NO;
    _barChart.drawValueAboveBarEnabled = YES;
    _barChart.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.75];
    
    _barChart.maxVisibleCount = 15;
    _barChart.pinchZoomEnabled = NO;
    _barChart.drawGridBackgroundEnabled = NO;
    
    ChartXAxis *xAxis = _barChart.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont systemFontOfSize:10.f];
    xAxis.drawGridLinesEnabled = NO;
    //xAxis.spaceBetweenLabels = 2.0;
    
    ChartYAxis *leftAxis = _barChart.leftAxis;
    leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
    leftAxis.labelCount = 8;
   // leftAxis.valueFormatter = [[DefaultAxisValueFormatter alloc] initWithDecimals:.];
   // leftAxis.valueFormatter = 0;
   // leftAxis.valueFormatter.negativeSuffix = @"";
   // leftAxis.valueFormatter.positiveSuffix = @"";
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    leftAxis.spaceTop = 0.15;
    
    ChartYAxis *rightAxis = _barChart.rightAxis;
    rightAxis.drawGridLinesEnabled = NO;
    rightAxis.labelFont = [UIFont systemFontOfSize:10.f];
    rightAxis.labelCount = 8;
    rightAxis.valueFormatter = leftAxis.valueFormatter;
    rightAxis.spaceTop = 0.15;
    
    _barChart.legend.position = ChartLegendPositionBelowChartLeft;
    _barChart.legend.form = ChartLegendFormCircle;
    _barChart.legend.formSize = 10.0;
    _barChart.legend.font = [UIFont systemFontOfSize:10.f];
    _barChart.legend.xEntrySpace = 2.0;
}

-(NSDate*)normalizedDateWithDate:(NSDate*)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate: date];
    return [calendar dateFromComponents:components];
}

- (void)loadHistoryForExercise:(NSString *)exercise animated:(BOOL)animated
{
    self.maxNumberOfReps = 0;
    self.selectedExerciseStatistics = [self.statisticProvider getHistoryWithExercise:exercise];
    NSNumber *min = @1000;
    NSNumber *max = @0;
    
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
    
    for (History *history in self.selectedExerciseStatistics)
    {
        if(history.convertedWeight.intValue > max.intValue) {
            max = history.convertedWeight;
        }
        if(history.convertedWeight.intValue < min.intValue) {
            min = history.convertedWeight;
        }
        
        NSDate *normalizedDateOfTheHistoryPoint = [self normalizedDateWithDate:history.date];
        NSMutableArray *arrayOfHistoriesForSelectedDate = [mutableDict objectForKey:normalizedDateOfTheHistoryPoint];
        
        if(!arrayOfHistoriesForSelectedDate) {
            arrayOfHistoriesForSelectedDate = [[NSMutableArray alloc] init];
        }
        
        [arrayOfHistoriesForSelectedDate addObject:history];
        
        self.maxNumberOfReps = arrayOfHistoriesForSelectedDate.count > self.maxNumberOfReps ? (int)arrayOfHistoriesForSelectedDate.count : self.maxNumberOfReps;
        
        [mutableDict setObject:arrayOfHistoriesForSelectedDate forKey:normalizedDateOfTheHistoryPoint];
    }
    
    for (NSMutableArray *unsortedValues in mutableDict.allValues) {
        [unsortedValues sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            History *h1 = obj1;
            History *h2 = obj2;
            
            if ([h1.date compare:h2.date] == NSOrderedAscending)
                return (NSComparisonResult)NSOrderedAscending;
            if ([h1.date compare:h2.date] == NSOrderedDescending)
                return (NSComparisonResult)NSOrderedDescending;
            return (NSComparisonResult)NSOrderedSame;
        }];
    }

    NSArray *sortedKeys = [mutableDict.allKeys sortedArrayUsingComparator: ^(id obj1, id obj2) {
        //get the key value.
        NSDate *d1 = obj1;
        NSDate *d2 = obj2;
        
        if ([d1 compare:d2] == NSOrderedAscending)
            return (NSComparisonResult)NSOrderedAscending;
        if ([d1 compare:d2] == NSOrderedDescending)
            return (NSComparisonResult)NSOrderedDescending;
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    NSMutableArray *arrayOfSortedByDateHistoriesArrays = [[NSMutableArray alloc] initWithCapacity:sortedKeys.count];
    
    for (id key in sortedKeys) {
        [arrayOfSortedByDateHistoriesArrays addObject:[mutableDict objectForKey:key]];
    }
    
    self.chartPoints = [arrayOfSortedByDateHistoriesArrays copy];
    //each object = array of histories with the same date
    
    self.minWeight = [min intValue];
    self.maxWeight = [max intValue];
}

- (void)setDefaultHighlightedValues
{
    self.selectedExerciseWeightLabel.text = [NSString stringWithFormat:@"- %@", self.kgOrLbls];
    self.selectedExerciseRepetitionLabel.text = NSLocalizedString(@"StatisticsRepetionsCountDefault_Label_Text", nil);
}

- (void)reloadBarChart {
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.chartPoints.count; i++)
    {
        NSArray *arrayOfHistoriesForSelectedDate = self.chartPoints[i];
        History *h0 = arrayOfHistoriesForSelectedDate[0];
        if(!h0) {
            return;
        }
        NSDate *normalizedDateOfTheHistoryPoint = [self normalizedDateWithDate:h0.date];
        NSString *dateString = [NSDateFormatter localizedStringFromDate:normalizedDateOfTheHistoryPoint
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterNoStyle];
        [xVals addObject:dateString];
    }
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    
    for(int i = 0; i<self.maxNumberOfReps; i++) {
        NSMutableArray *yVals = [[NSMutableArray alloc] init];
        for (int j = 0; j < self.chartPoints.count; j++)
        {
            NSArray *arrayOfHistoriesForSelectedDate = self.chartPoints[j];
            if (arrayOfHistoriesForSelectedDate.count <= i) {
                [yVals addObject:[[BarChartDataEntry alloc] initWithX:j y:0 data:@0]];
                //[yVals addObject:[[BarChartDataEntry alloc] initWithValue:0 xIndex:j data:@0]];
            } else {
                History *h = arrayOfHistoriesForSelectedDate[i];
                
                double valueToShow = self.maxWeight == 0 ? [h.repetitions doubleValue] : [h.weight doubleValue];
                
                if (self.maxWeight == 0) {
                    [self setYAxisHintWithRepsIfNeeded:YES];
                } else {
                    [self setYAxisHintWithRepsIfNeeded:NO];
                }
                BarChartDataEntry *newValue = [[BarChartDataEntry alloc] initWithX:i y:valueToShow data:h.repetitions];
                [yVals addObject: newValue];
               // [yVals addObject:[[BarChartDataEntry alloc] initWithValue:valueToShow xIndex:j data:h.repetitions]];
            }
        }
        
        NSString *chartLabel = [NSString stringWithFormat: @"%@ %d ", NSLocalizedString(@"Set_Text", nil), i+1];
        BarChartDataSet *set = [[BarChartDataSet alloc] initWithValues:yVals label:chartLabel];
        //[[BarChartDataSet alloc] initWithYVals:yVals label:[NSString stringWithFormat: @"%@ %d ", NSLocalizedString(@"Set_Text", nil), i+1]];
        //set.barSpace = 0.15;
        
        if (self.maxNumberOfReps > 8) {
            set.colors = @[[UIColor colorWithHue:(double)i/(double)self.maxNumberOfReps saturation:1.0 brightness:0.95 alpha:1.0]];
        } else {
            set.colors = @[[self getColorNumber:i fromSetWithNumberOfColors:self.maxNumberOfReps - 1]];
        }

        [dataSets addObject:set];
    }
    
    BarChartData *data = [[BarChartData alloc] initWithDataSets:dataSets];
        
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
    
    _barChart.data = data;
    _barChart.xAxis.valueFormatter = self;
    [_barChart highlightValue:nil];
    [self setDefaultHighlightedValues];
}

#pragma AxisValueFormatter

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis {
    return @"";
}

#pragma DropdownMenu - DataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.exercisesWithStatistics.count == 0 ? 1 : self.exercisesWithStatistics.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

    if (self.exercisesWithStatistics.count == 0)
    {
        return NSLocalizedString(@"NoStatistics_Label_Text", nil);
    }
    
    NSString *string = [NSString stringWithFormat:@"%@",NSLocalizedString(self.exercisesWithStatistics[row], nil)];
    return string;
} 

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedRow = (int)row;
    if (self.exercisesWithStatistics.count > 0) {
        [self loadHistoryForExercise:self.exercisesWithStatistics[row] animated:YES];
        [self reloadBarChart];
    }
    
    self.hintLabel.hidden = NO;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0,0,300,45);
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightLight];
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    
    if (self.exercisesWithStatistics.count < 1)
    {
        label.text = NSLocalizedString(@"NoStatistics_Label_Text", nil);
    } else {
        label.text = [NSString stringWithFormat:@"%@",NSLocalizedString(self.exercisesWithStatistics[row], nil)];
    }
    
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 45;
}

#pragma mark - ChartBar delegate
- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    self.hintLabel.hidden = YES;
   
    self.selectedExerciseWeightLabel.text = [NSString stringWithFormat:@"%.1f %@", self.maxWeight == 0 ? 0.0 : entry.y, self.kgOrLbls];
        
    self.selectedExerciseRepetitionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"StatisticsRepetionsCount_Label_Text", nil), entry.data];

}

- (void)chartValueSelected:(ChartViewBase *)chartView entry:(ChartDataEntry *)entry highlight:(ChartHighlight *)highlight {
    self.hintLabel.hidden = YES;
    
    self.selectedExerciseWeightLabel.text = [NSString stringWithFormat:@"%.1f %@", self.maxWeight == 0 ? 0.0 : entry.y, self.kgOrLbls];
    
    self.selectedExerciseRepetitionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"StatisticsRepetionsCount_Label_Text", nil), entry.data];
}

@end
