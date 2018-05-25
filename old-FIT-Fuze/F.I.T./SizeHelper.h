//
//  SizeHelper.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 05/06/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SizeHelper : NSObject

+ (CGSize)workoutCollectionViewCellSizeIsOnlyOne:(BOOL)isOnlyOne;
+ (CGFloat)workoutCollectionViewHeight;
+ (CGFloat)workoutOneImageHeight;
+ (CGFloat)topContainerLeadingConstantForTwo;

@end
