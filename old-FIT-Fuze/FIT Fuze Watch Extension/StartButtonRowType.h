//
//  StartButtonRowType.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 01/05/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface StartButtonRowType : NSObject
@property (weak, nonatomic) IBOutlet WKInterfaceLabel* startLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel* doneOfLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceImage* startIcon;
@property (weak, nonatomic) IBOutlet WKInterfaceImage* moreIcon;
@end
