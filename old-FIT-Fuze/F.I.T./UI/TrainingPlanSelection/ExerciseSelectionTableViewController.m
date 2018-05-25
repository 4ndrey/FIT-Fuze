//
//  ExerciseSelectionTableViewController.m
//  F.I.T.
//
//  Created by Felix Belau on 15.03.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "ExerciseSelectionTableViewController.h"
#import "ExerciseSelectionTableViewCell.h"
#import "UIColor+FIT.h"
#import "AppDelegate.h"
#import "UIViewController+RESideMenu.h"
#import "ExerciseDescriptionViewController.h"
#import "ExerciseCreationViewController.h"
#import "FIT-Swift.h"
#import <UIKit/UIKit.h>

@import MagicalRecord;

@interface ExerciseSelectionTableViewController ()  <UISearchResultsUpdating, UISearchBarDelegate>
{
    BOOL _footerNeeded;
}

@property (strong, nonatomic) UIView *bottomView;
@property (nonatomic) BOOL isInEditingMode;
@property (nonatomic) BOOL isInSearchMode;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *remainingExercises;

@property (nonatomic, strong) Exercise *selectedExercise;
@property (nonatomic, strong) NSMutableArray *selectedExercises;
@property (nonatomic, strong) UIButton *addButton;

@property (nonatomic, strong) NSDictionary *dictionaryOfExercisesToShow;
@property (nonatomic, strong) NSArray *sortedExerciseKeys;

@end

@implementation ExerciseSelectionTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Exercises_Label_Text", nil);
    self.navigationItem.title = NSLocalizedString(@"Exercises_Label_Text", nil);

    
    //initialize selectedExercise Array - needed for adding exercises to current workout
    self.selectedExercises = [[NSMutableArray alloc] init];
    self.isInSearchMode = NO;
    
    //setip searchcontroller
    [self initializeSearchController];
    _footerNeeded = YES;
    
    // if viewcontroller is pushed via side menu -> replace leftbarbuttonitem with menu button
    
    self.navigationItem.leftBarButtonItem = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exerciseListShouldBeRenewed) name:@"exerciseWasCreated" object:nil];
}

- (void)exerciseListShouldBeRenewed {
    [self getListOfExercisesToShow];
    [self fillDictionaryOfExercisesToShowWithExercises:self.remainingExercises];
    
    if (self.exercisesAreSelectable)
    {
        //TODO: just a fix for a statitc footer - normaly take UIViewcontroller add tableview and add a static bottomview
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 64, [[UIScreen mainScreen] bounds].size.width, 64)];
        self.bottomView.backgroundColor = [UIColor clearColor];
        [[appDelegate window] addSubview:self.bottomView];
        
        UIVisualEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
        effectView.frame = self.bottomView.bounds;
        [self.bottomView addSubview:effectView];
        
        self.addButton = [[UIButton alloc]initWithFrame:CGRectMake(8 , 4, self.bottomView.frame.size.width-16, 56)];
        self.addButton.layer.cornerRadius = 8.0;
        [self.addButton addTarget:self action:@selector(addExercises) forControlEvents:UIControlEventTouchUpInside];
        self.addButton.backgroundColor = [UIColor editColor];
        [self.addButton setImage:[UIImage imageNamed:@"Plus_extended"] forState:UIControlStateNormal];
        [self.addButton setTitle:NSLocalizedString(@"AddSelectedExercises_Button_Title", nil) forState:UIControlStateNormal];
        [self.addButton.titleLabel setFont:[UIFont systemFontOfSize:17.5 weight:UIFontWeightLight]];
        self.addButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        self.addButton.titleLabel.numberOfLines = 2;
        self.addButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.addButton.titleLabel.minimumScaleFactor = 0.5;
        [effectView.contentView addSubview:self.addButton];
        self.addButton.enabled = NO;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    
    [self.tableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getListOfExercisesToShow {
    NSArray *unsortedExerciseArray;
    
    //get exercises by type - if type is nil get all exercisees
    if (!self.exerciseType || [self.exerciseType isEqualToString:@"all"])
    {
        unsortedExerciseArray = [Exercise MR_findAll];
    }
    else
    {
        ContentProvider *contentProvider = [[ContentProvider alloc] init];
        unsortedExerciseArray = [contentProvider getExercisesWithType:self.exerciseType];
    }
    
    self.remainingExercises = [[unsortedExerciseArray sortedArrayUsingComparator:^NSComparisonResult(Exercise *obj1, Exercise *obj2) {
        return [(NSString *)NSLocalizedString(obj1.name, nil) compare:(NSString *)NSLocalizedString(obj2.name, nil) options:NSNumericSearch];
    }] mutableCopy];
    
    //see which exercise was already added to workout - remove from remaininExercise Array
    for (ExerciseMetaMapping *exerciseMetaMapping in self.workout.exerciseMetaMappings)
    {
        [self.remainingExercises removeObject:exerciseMetaMapping.exercise];
    }
}

- (void)fillDictionaryOfExercisesToShowWithExercises:(NSArray *)arrayOfExercises {
    NSMutableDictionary *mutableDictionaryOfExercises = [NSMutableDictionary new];
    NSMutableArray *keys = [NSMutableArray new];
    for (Exercise *exercise in arrayOfExercises) {
        NSString *name = NSLocalizedString(exercise.name, nil);
        NSString *sectionName = [name substringWithRange:NSMakeRange(0, 1)];
        NSMutableArray *arrOfExercisesForThisLetter = [mutableDictionaryOfExercises objectForKey:sectionName];
        if (!arrOfExercisesForThisLetter) {
            arrOfExercisesForThisLetter = [NSMutableArray new];
            [keys addObject:sectionName];
        }
        [arrOfExercisesForThisLetter addObject:exercise];
        [mutableDictionaryOfExercises setObject:arrOfExercisesForThisLetter forKey:sectionName];
    }
    self.sortedExerciseKeys = [[keys sortedArrayUsingComparator:^NSComparisonResult(NSString *name1, NSString *name2) {
        return [name1 compare:name2 options:NSCaseInsensitiveSearch];
    }] copy];
    self.dictionaryOfExercisesToShow = [mutableDictionaryOfExercises copy];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self exerciseListShouldBeRenewed];
    
    if (self.exercisesAreSelectable)
    {
        self.tableView.allowsMultipleSelectionDuringEditing = YES;
        self.isInEditingMode = YES;
        self.tableView.editing = YES;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
                                                                                               action:@selector(createExerciseModally)];
        
    }
    else
    {
        _footerNeeded = NO;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
                                                                                               action:@selector(createExercise)];
    }
    [self.tableView setEditing:self.exercisesAreSelectable animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.bottomView)
    {
        [self.bottomView removeFromSuperview];
        self.bottomView = nil;
    }
    [super viewWillDisappear:animated];
}

#pragma mark - IBActions

- (IBAction)toggleMultipleSelection:(UIButton *)sender
{
    self.isInEditingMode = !self.isInEditingMode;
    [self.tableView setEditing:self.isInEditingMode animated:YES];
    [((UITableViewController *)self.searchController.searchResultsController).tableView setEditing:self.isInEditingMode animated:YES];
    
    if (self.isInEditingMode)
    {
        self.bottomView.hidden = NO;
        if (self.selectedExercises.count != 0) {
            self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"ExerciseSelectionExercisesAdded_Navbar_Title", nil), (unsigned long)self.selectedExercises.count];
        }
        [sender setImage:[UIImage imageNamed:@"eye"] forState:UIControlStateNormal];
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"ExerciseSelectionDefault_Navbar_Title", nil);
        self.bottomView.hidden = YES;
        [sender setImage:[UIImage imageNamed:@"multiple-selection-nonactive"] forState:UIControlStateNormal];
    }
}

#pragma mark - Internal

- (void)addExercises
{
    if(self.workout) {
        for (Exercise *exercise in self.selectedExercises)
        {
            //create metaMapping
            ExerciseMetaMapping *newExerciseMetaMapping = [NSEntityDescription insertNewObjectForEntityForName:@"ExerciseMetaMapping" inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
            newExerciseMetaMapping.exercise = exercise;
            
            if(exercise != self.selectedExercises.lastObject && self.isSuperset) {
                newExerciseMetaMapping.withNext = self.isSuperset;
            }
            
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
            WorkoutSet *newSet = [NSEntityDescription insertNewObjectForEntityForName:@"WorkoutSet" inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
            newSet.weights = @(10);
            newSet.repetitions = @(10);
            
            [exerciseSets addObject:newSet];
            [newExerciseMeta setSets:[[NSOrderedSet alloc] initWithArray:exerciseSets]];
            
            //add to workout
            NSMutableArray *exerciseMetaMappings = [[[self.workout exerciseMetaMappings] array] mutableCopy];
            if (!exerciseMetaMappings)
            {
                exerciseMetaMappings = [[NSMutableArray alloc] init];
            }
            [exerciseMetaMappings addObject:newExerciseMetaMapping];
            [self.workout setExerciseMetaMappings:[[NSOrderedSet alloc] initWithArray:exerciseMetaMappings]];
        }
        
        //save to core data
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    } else {
        [self.delegate exerciseSelected:self.selectedExercises];
    }
    
    
    //pop to workout modifcation controller
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddExerciseModalViewControllerDismissed" object:nil];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    [self.selectedExercises removeAllObjects];
}

- (void)initializeSearchController
{
    //instantiate a search results controller for presenting the search/filter results (will be presented on top of the parent table view)
    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;
    searchResultsController.tableView.allowsMultipleSelectionDuringEditing = YES;
    searchResultsController.tableView.editing = YES;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    //self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.definesPresentationContext = YES;

    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    self.searchController.searchBar.barTintColor = self.navigationController.navigationBar.barTintColor;

    [self.tableView setTintColor:[UIColor mainColor]];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.contentOffset = CGPointMake(0, 44.0);
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    
    for(UIView *subView in [self.searchController.searchBar subviews]) {
        if([subView conformsToProtocol:@protocol(UITextInputTraits)]) {
            [(UITextField *)subView setReturnKeyType: UIReturnKeyDone];
        } else {
            for(UIView *subSubView in [subView subviews]) {
                if([subSubView conformsToProtocol:@protocol(UITextInputTraits)]) {
                    [(UITextField *)subSubView setReturnKeyType: UIReturnKeyDone];
                }
            }      
        }
    }
}

#pragma mark Content Filtering

-(void)filterContentForSearchText:(NSString*)searchText
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Exercise *evaluatedObject, NSDictionary *bindings) {
        NSString *localizedText = NSLocalizedString(evaluatedObject.name,nil);
        BOOL perfectMatch = [localizedText.lowercaseString isEqualToString:searchText.lowercaseString];
        
        NSArray *searchSubstring = [searchText.lowercaseString componentsSeparatedByString:@" "];
        NSString *lowerCaseLocalizedString = localizedText.lowercaseString;
        BOOL containsString = YES;
        for (NSString *searchComponent in searchSubstring) {
            if (searchComponent.length > 0) {
                containsString = containsString && ([lowerCaseLocalizedString rangeOfString:searchComponent].location != NSNotFound);
            }
        }
        
        return (perfectMatch || containsString);
    }];
    [self fillDictionaryOfExercisesToShowWithExercises:[self.remainingExercises filteredArrayUsingPredicate:predicate]];
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_footerNeeded && self.isInEditingMode) {
        int height = 65;
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
        
        tableView.tableFooterView = footerView;
    }
    
    return self.sortedExerciseKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionKey = [self.sortedExerciseKeys objectAtIndex:section];
    NSArray *exercisesForSectionKey = [self.dictionaryOfExercisesToShow objectForKey:sectionKey];
    return exercisesForSectionKey.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sortedExerciseKeys objectAtIndex:section];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionKey = [self.sortedExerciseKeys objectAtIndex:indexPath.section];
    NSArray *exercisesForSectionKey = [self.dictionaryOfExercisesToShow objectForKey:sectionKey];
    Exercise *exercise = exercisesForSectionKey[indexPath.row];
    if ([self.selectedExercises containsObject:exercise])
    {
        cell.highlighted = YES;
    }
    else
    {
        cell.highlighted = NO;
        cell.selected = NO;
    }
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sortedExerciseKeys;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellReuseId = @"ExerciseCell";
    ExerciseSelectionTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellReuseId];
    if(cell == nil)
    {
        cell = (ExerciseSelectionTableViewCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellReuseId];
    }
    
    NSString *sectionKey = [self.sortedExerciseKeys objectAtIndex:indexPath.section];
    NSArray *exercisesForSectionKey = [self.dictionaryOfExercisesToShow objectForKey:sectionKey];
    Exercise *exercise = exercisesForSectionKey[indexPath.row];
    cell.titleLabel.text = NSLocalizedString(exercise.name,nil);
    cell.exerciseImageView.animationImages = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    if(exercise.images.count > 6) {
        //setup image animation stuff
        NSMutableArray *mutableImageArray = [[NSMutableArray alloc] init];
        NSMutableArray *mutableImageArray2 = [[NSMutableArray alloc] init];
        
        [mutableImageArray addObjectsFromArray:[exercise.images array]];
        
        if (mutableImageArray.count <= 7)
        {
            [mutableImageArray addObjectsFromArray:[[[exercise.images array] reverseObjectEnumerator] allObjects]];
        }
        
        for (Images *image in mutableImageArray)
        {
            UIImage *exerciseImage = [UIImage imageWithData:image.image];
            [mutableImageArray2 addObject:exerciseImage];
        }
        
        cell.exerciseImageView.animationImages = [NSArray arrayWithArray:[[mutableImageArray2 objectEnumerator] allObjects]];
        cell.exerciseImageView.animationRepeatCount = 1;
        cell.exerciseImageView.animationDuration = 0.3*cell.exerciseImageView.animationImages.count;
        cell.exerciseImageView.image = cell.exerciseImageView.animationImages[0];
    }
    else if(exercise.images.count > 0)
    {
        cell.exerciseImageView.image = [UIImage imageWithData:((Images *)[exercise.images objectAtIndex:0]).image];
    }
    else
    {
        cell.exerciseImageView.image = [UIImage imageNamed:@"abs-icon"];
    }
    

    
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.exercisesAreSelectable;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.editing) {
        return UITableViewCellEditingStyleNone;
    } else {
        NSString *sectionKey = [self.sortedExerciseKeys objectAtIndex:indexPath.section];
        NSArray *exercisesForSectionKey = [self.dictionaryOfExercisesToShow objectForKey:sectionKey];
        Exercise *exercise = exercisesForSectionKey[indexPath.row];
        if ([exercise.type isEqualToString:@"own"]) {
            return UITableViewCellEditingStyleDelete;
        } else {
            return UITableViewCellEditingStyleNone;
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionKey = [self.sortedExerciseKeys objectAtIndex:indexPath.section];
    NSArray *exercisesForSectionKey = [self.dictionaryOfExercisesToShow objectForKey:sectionKey];
    Exercise *exercise = exercisesForSectionKey[indexPath.row];
    [self.remainingExercises removeObject:exercise];
    [self fillDictionaryOfExercisesToShowWithExercises:self.remainingExercises];
    
    NSArray *trainings = [Training MR_findAll];
    for (Training *training in trainings) {
        for (ExerciseMetaMapping *mapping in training.exerciseMetaMappings) {
            if (mapping.exercise == exercise) {
                NSMutableOrderedSet *tempSet = [[NSMutableOrderedSet alloc] initWithOrderedSet:training.exerciseMetaMappings];
                [tempSet removeObject:mapping];
                training.exerciseMetaMappings = [tempSet copy];
            }
        }
    }
    
    [[NSManagedObjectContext MR_defaultContext] deleteObject:exercise];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [self.tableView reloadData];
}

#pragma mark - TableViewDelegate Methods

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.exercisesAreSelectable)
    {
        return YES;
    } else {
        NSString *sectionKey = [self.sortedExerciseKeys objectAtIndex:indexPath.section];
        NSArray *exercisesForSectionKey = [self.dictionaryOfExercisesToShow objectForKey:sectionKey];
        Exercise *exercise = exercisesForSectionKey[indexPath.row];
        return [exercise.type isEqualToString:@"own"];
    }
}

- (void)createExercise
{
    [self.bottomView removeFromSuperview];
    [self performSegueWithIdentifier:@"showExerciseCreation" sender:self];
}

- (void)createExerciseModally
{
    [self.bottomView removeFromSuperview];
    [self performSegueWithIdentifier:@"showExerciseCreationModally" sender:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionKey = [self.sortedExerciseKeys objectAtIndex:indexPath.section];
    NSArray *exercisesForSectionKey = [self.dictionaryOfExercisesToShow objectForKey:sectionKey];
    Exercise *exercise = exercisesForSectionKey[indexPath.row];;
    if (!self.exercisesAreSelectable || !self.isInEditingMode)
    {
        self.selectedExercise = exercise;
        [self performSegueWithIdentifier:@"showExerciseDetails" sender:nil];
    }
    else if ([self.selectedExercises containsObject:exercise])
    {
        [self.selectedExercises removeObject:exercise];
        [tableView cellForRowAtIndexPath:indexPath].highlighted = NO;
        [tableView cellForRowAtIndexPath:indexPath].selected = NO;
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"ExerciseSelectionExercisesAdded_Navbar_Title", nil), (unsigned long)self.selectedExercises.count];
    }
    else
    {
        [self.selectedExercises addObject:exercise];
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"ExerciseSelectionExercisesAdded_Navbar_Title", nil), (unsigned long)self.selectedExercises.count];
    }
    self.addButton.enabled = self.selectedExercises.count > 0;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionKey = [self.sortedExerciseKeys objectAtIndex:indexPath.section];
    NSArray *exercisesForSectionKey = [self.dictionaryOfExercisesToShow objectForKey:sectionKey];
    Exercise *exercise = exercisesForSectionKey[indexPath.row];
    [self.selectedExercises removeObject:exercise];
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"ExerciseSelectionExercisesAdded_Navbar_Title", nil), (unsigned long)self.selectedExercises.count];
    self.addButton.enabled = self.selectedExercises.count > 0;
}

#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    //get search text from user input
    NSString *searchText = [self.searchController.searchBar text];
    
    //exit if there is no search text (i.e. user tapped on the search bar and did not enter text yet)
    if(![searchText length] > 0) {
        
        return;
    }
    //handle when there is search text entered by the user
    else {
        
        [self filterContentForSearchText:searchText];
        //now that the tableSections and tableSectionsAndItems properties are updated, reload the UISearchController's tableview
        [((UITableViewController *)self.searchController.searchResultsController).tableView reloadData];
    }
}

#pragma mark - UISearchBarDelegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.isInSearchMode = YES;
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.isInSearchMode = NO;
    [self fillDictionaryOfExercisesToShowWithExercises:self.remainingExercises];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.isInSearchMode = NO;
    [self.searchController setActive:NO];
    [self fillDictionaryOfExercisesToShowWithExercises:self.remainingExercises];
    [self.tableView reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showExerciseDetails"])
    {
        ExerciseDescriptionViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.exercise = self.selectedExercise;
    }
    
    if ([segue.identifier isEqualToString:@"showExerciseCreationModally"])
    {
        [self.bottomView removeFromSuperview];
        self.bottomView = nil;
        
        UINavigationController *destinationViewController = [segue destinationViewController];
        UIViewController *root = destinationViewController.viewControllers[0];
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
        [closeButton setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [closeButton addTarget:self action:@selector(closeModalView) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setImage:[UIImage imageNamed:@"close_green"] forState:UIControlStateNormal];
        UIBarButtonItem *random = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
        root.navigationItem.leftBarButtonItem = random;
    }
}

- (void)closeModalView {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self exerciseListShouldBeRenewed];
}

@end
