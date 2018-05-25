//
//  MainMenuViewController.h
//  F.I.T.
//
//  Created by Felix Belau on 17.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"

@interface MainMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (void)updateUserInterface;

@end
