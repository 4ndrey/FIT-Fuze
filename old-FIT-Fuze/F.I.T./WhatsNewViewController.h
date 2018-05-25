//
//  WhatsNewViewController.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 27/09/15.
//  Copyright © 2015 FIT-Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WhatsNewViewControllerDelegate <NSObject>

- (void)userHasSeenWhatsNew;

@end

@interface WhatsNewViewController : UIViewController

@property (weak, nonatomic) id<WhatsNewViewControllerDelegate> delegate;

@end
