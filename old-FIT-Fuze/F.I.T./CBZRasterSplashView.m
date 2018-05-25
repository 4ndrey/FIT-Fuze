//
//  CBZRasterSplashView.m
//  Telly
//
//  Created by Mazyad Alabduljaleel on 8/7/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "CBZRasterSplashView.h"

@interface CBZRasterSplashView ()

@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation CBZRasterSplashView

- (instancetype)initWithIconImage:(UIImage *)icon backgroundColor:(UIColor *)color offset:(CGPoint)pointOffset
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.backgroundColor = color;
        
        UIImageView *iconImageView = [UIImageView new];
        iconImageView.image = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        iconImageView.tintColor = self.iconColor;
        iconImageView.frame = CGRectMake(0, 0, self.iconStartSize.width, self.iconStartSize.height);
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        iconImageView.center = CGPointMake(self.center.x + pointOffset.x, self.center.y + pointOffset.y);
        
        [self addSubview:iconImageView];
        
        _iconImageView = iconImageView;
    }
    return self;
}

- (void)startAnimationWithCompletionHandler:(void (^)())completionHandler
{
    __block __weak typeof(self) weakSelf = self;
    
    if (!self.animationDuration) {
        return;
    }
    
    CGFloat shrinkDuration = self.animationDuration * 0.3;
    CGFloat growDuration = self.animationDuration * 0.7;
    
    [UIView animateWithDuration:shrinkDuration delay:0 usingSpringWithDamping:0.7f initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.75, 0.75);
        weakSelf.iconImageView.transform = scaleTransform;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:growDuration animations:^{
            CGAffineTransform scaleTransform = CGAffineTransformMakeScale(120, 120);
            weakSelf.iconImageView.transform = scaleTransform;
            
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.alpha = 0;
            } completion:^(BOOL finished) {
                [weakSelf removeFromSuperview];
                if (completionHandler) {
                    completionHandler();
                }
            }];
        }];
    }];
}

@end
