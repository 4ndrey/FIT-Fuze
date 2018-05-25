//
//  HowToInterfaceController.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 29/04/15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "HowToInterfaceController.h"


@interface HowToInterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceImage *exerciseWImage;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *exerciseNameLabel;
@property (strong, nonatomic) NSString *exerciseName;
@end


@implementation HowToInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.exerciseName = [context objectForKey:@"exerciseName"];
    [self getInfoFromSharedContainer];
    // Configure interface objects here.
}

- (void)getInfoFromSharedContainer
{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 7; i++) {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@ %d", self.exerciseName, i]];
        if(img) {
            [images addObject:img];
        }
    }
    
    if([self.exerciseName containsString:@"Alternate"]) {
        for(int i = 8; i <= 14; i++) {
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@ %d", self.exerciseName, (15-i)]];
            if(img) {
                [images addObject:img];
            }
        }
    }
    
    if (images.count <= 7) //non-symmetric exercises should not be reverted
    {
        [images addObjectsFromArray:[[images reverseObjectEnumerator] allObjects]];
    }
    
    if(images.count == 0) {
        [self.exerciseWImage setHidden:true];
    } else {
        [self.exerciseWImage setHidden:false];
    }
    
    [self.exerciseWImage setImage:[UIImage animatedImageWithImages:images duration:4.0]];
    
    [self.exerciseNameLabel setText:NSLocalizedString(self.exerciseName, nil)];
}

- (IBAction)goToSettings:(id)sender
{
    [self pushControllerWithName:@"settingsSceneID" context:nil];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self.exerciseWImage startAnimating];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    [self.exerciseWImage stopAnimating];

}

@end



