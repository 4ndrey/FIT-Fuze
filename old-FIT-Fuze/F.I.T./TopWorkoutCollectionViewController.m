//
//  TopWorkoutCollectionViewController.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 02/06/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import "TopWorkoutCollectionViewController.h"
#import "TopWorkoutCollectionViewCell.h"
#import "FIT-Swift.h"
#import "UIColor+FIT.h"
#import "SizeHelper.h"

@interface TopWorkoutCollectionViewController ()

@property (strong, nonatomic) NSArray *arrayOfColors;

@end

@implementation TopWorkoutCollectionViewController

static NSString * const reuseIdentifier = @"topWorkoutCollectionViewCellID";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrayOfColors = [UIColor arrayOfWorkoutColors];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    // Do any additional setup after loading the view.
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.exerciseMetaMappings.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TopWorkoutCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [cell setupWithExerciseMetaMapping:self.exerciseMetaMappings[indexPath.row] color:self.arrayOfColors[indexPath.row]];
    cell.detailsDelegate = self.detailsDelegate;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [SizeHelper workoutCollectionViewCellSizeIsOnlyOne:(self.exerciseMetaMappings.count == 1)];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [(TopWorkoutCollectionViewCell *)cell dismissBlur];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.delegate disableScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.delegate enableScrolling];
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
