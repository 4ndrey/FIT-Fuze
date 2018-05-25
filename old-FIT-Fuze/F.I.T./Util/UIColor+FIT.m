//
//  UIColor+FIT.m
//  F.I.T.
//
//  Created by Felix Belau on 21.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "UIColor+FIT.h"

@implementation UIColor (FIT)

+ (UIColor *)mainColor
{
    return [UIColor colorWithRed:54/255.0 green:170/255.0 blue:220/255.0 alpha:1.0];
}

+ (UIColor *)supersetColor
{
    return [UIColor colorWithRed:54/255.0 green:170/255.0 blue:220/255.0 alpha:0.2];
}

+ (UIColor *)editColor
{
    return [UIColor colorWithRed:0/255.0 green:213/255.0 blue:127/255.0 alpha:1.0];
}

+ (UIColor *)mainColorTransparent
{
    return [UIColor colorWithRed:54/255.0 green:170/255.0 blue:220/255.0 alpha:0.5f];
}

+ (UIColor *)failureColor
{
    return [UIColor colorWithRed:192/255.0 green:57/255.0 blue:43/255.0 alpha:1.0];
}

+ (NSArray *)arrayOfWorkoutColors
{
    UIColor *zeroColors = [UIColor colorWithRed:84.0/255.0 green:194.0/255.0 blue:1.0 alpha:1];
    UIColor *firstColors = [UIColor colorWithRed:216.0/255.0 green:0 blue:1 alpha:1];
    UIColor *secondColors = [UIColor colorWithRed:1.0 green:90.0/255.0 blue:0 alpha:1];
    UIColor *thirdColors = [UIColor colorWithRed:1.0 green:245.0/255.0 blue:0 alpha:1];
    UIColor *forthColors = [UIColor colorWithRed:0 green:1.0 blue:55.0/255.0 alpha:1];
    UIColor *fifthColors = [UIColor colorWithRed:0 green:1.0 blue:235.0/255.0 alpha:1];
    return @[zeroColors, firstColors, secondColors, thirdColors, forthColors, fifthColors];
}


@end
