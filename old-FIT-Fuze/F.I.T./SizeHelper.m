//
//  SizeHelper.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 05/06/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import "SizeHelper.h"

@implementation SizeHelper

+ (CGSize)workoutCollectionViewCellSizeIsOnlyOne:(BOOL)isOnlyOne {
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    if (height == 480) {
        return CGSizeMake(140, isOnlyOne ? width : 150);
    } else if (height == 736) {
        return CGSizeMake(240, isOnlyOne ? width : 250);
    } else if (height == 667) {
        return CGSizeMake(190, isOnlyOne ? width : 200);
    } else {
        return CGSizeMake(150, isOnlyOne ? width : 160);
    }
}

+ (CGFloat)workoutCollectionViewHeight {
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    if (height == 480)
    {
        return 150;
    }
    else if (height == 736)
    {
        return 250;
    }
    else if (height == 667) {
        return 200;
    }
    else
    {
        return 160;
    }
}

+ (CGFloat)workoutOneImageHeight {
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    if (height == 480)
    {
        return 138;
    }
    else if (height == 736)
    {
        return 230;
    }
    else if (height == 667)
    {
        return 180;
    }
    else
    {
        return 140;
    }
}

+ (CGFloat)topContainerLeadingConstantForTwo {
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    if (height == 480)
    {
        return 20;
    }
    else if (height == 736)
    {
        return 0;
    }
    else if (height == 667)
    {
        return -2;
    }
    else
    {
        return 10;
    }
}

@end
