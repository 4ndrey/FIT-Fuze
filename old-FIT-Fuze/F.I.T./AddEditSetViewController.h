//
//  AddEditSetViewController.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 22/05/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddEditSetViewControllerDelegate <NSObject>

- (void)setEditingDone;

@end

@interface AddEditSetViewController : UITableViewController

@property (nonatomic, strong) NSOrderedSet *exerciseMetaMappings;
@property (nonatomic, assign) int editingSetIndex;
@property (weak, nonatomic) id<AddEditSetViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL needSaveResults;
@property (nonatomic, assign) BOOL disableDelete;
@property (nonatomic, assign) int exampleWeight;
@property (nonatomic, assign) int exampleReps;

@end
//save statistic of the failed and updated set