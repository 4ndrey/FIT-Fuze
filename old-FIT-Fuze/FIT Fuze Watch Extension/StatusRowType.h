//
//  StatusRowType.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 10/07/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//
#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface StatusRowType : NSObject

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceImage *heart_rate_icon;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *setXofYLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceTimer *setTimer;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *timerGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *statisticGroup;

@end
