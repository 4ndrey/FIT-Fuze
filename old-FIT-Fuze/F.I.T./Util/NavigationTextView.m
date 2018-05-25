//
//  NavigationTextView.m
//  F.I.T.
//
//  Created by Felix Belau on 04.04.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "NavigationTextView.h"
#import "UIColor+FIT.h"

@implementation NavigationTextView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 55)];
        self.titleTextField.backgroundColor = [UIColor clearColor];
        self.titleTextField.textAlignment = NSTextAlignmentCenter;
        self.titleTextField.font = [UIFont systemFontOfSize:19 weight:UIFontWeightLight];
        self.titleTextField.textColor = [UIColor mainColor];
        self.titleTextField.text = @"Trainingplan1";
        self.titleTextField.clearButtonMode = UITextFieldViewModeAlways;
        
        [self addSubview:self.titleTextField];
        
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 38, frame.size.width, 15)];
        self.descriptionLabel.backgroundColor = [UIColor clearColor];
        self.descriptionLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
        self.descriptionLabel.text = @"tap to change the name of the plan";
        self.descriptionLabel.textColor = [UIColor mainColor];
        self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.descriptionLabel];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
