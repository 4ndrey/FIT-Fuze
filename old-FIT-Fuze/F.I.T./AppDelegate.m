//
//  AppDelegate.m
//  F.I.T.
//
//  Created by Felix Belau on 17.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "CurrentFitManager.h"
#import "UIColor+FIT.h"
#import "FIT-Swift.h"
#import <Instabug/Instabug.h>
#import "UAAppReviewManager.h"
#import "NSManagedObjectContext+FetchedObjectFromURI.h"
#import "SettingsViewController.h"
#import "iLink.h"
#import "InitialLoadingViewController.h"

#import <HealthKit/HealthKit.h>

@import MagicalRecord;

@interface AppDelegate ()
@property (strong, nonatomic) CurrentFitManager *fitManager;
@end

@implementation AppDelegate

-(void)applicationShouldRequestHealthAuthorization:(UIApplication *)application{
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];

    [healthStore handleAuthorizationForExtensionWithCompletion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"phone recieved health kit request");
        }
    }];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Fabric with:@[[Crashlytics class]]];
    [MagicalRecord setupAutoMigratingCoreDataStack];
    self.fitManager = [CurrentFitManager sharedManager];

    [iLink sharedInstance].applicationBundleID = @"com.FITFuze";
    [iLink sharedInstance].onlyPromptIfLatestVersion = NO;

    [UAAppReviewManager setAppID:@"982750436"];
    [UAAppReviewManager setDaysUntilPrompt:14];
    [UAAppReviewManager setUsesUntilPrompt:3];
    [UAAppReviewManager setDaysBeforeReminding:3];
    [UAAppReviewManager setAppName:@"FIT Fuze"];
    
    //appearance for navigation bar - just for debug :)
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName : [UIColor mainColor],
                                                           NSFontAttributeName: [UIFont systemFontOfSize:20 weight:UIFontWeightLight],
                                                           }];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    NSDictionary *barButtonAppearanceDict = @{NSFontAttributeName : [UIFont systemFontOfSize:16 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor mainColor]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
    [UINavigationBar appearance].tintColor = [UIColor mainColor];

    [[UITableViewCell appearance] setTintColor:[UIColor colorWithRed:90/255.0 green:223/255.0 blue:130/255.0 alpha:1.0]];
    
    [Instabug startWithToken:@"5bd72277c92046d8e46887cb2a2e0eb0" invocationEvent:IBGInvocationEventShake];
    [Instabug setEmailFieldRequired:NO];
    
    [self setInstabugColorScheme];
    return YES;
}

//Исправленные сеты не записываются в историю! Записываются старые, неисправленные!

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shouldStartCurrentWorkout"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InitialLoadingViewController *ivc = [sb instantiateInitialViewController];
    self.window.rootViewController = ivc;
    completionHandler(YES);
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *replyInfo))reply
{
    NSArray *keys = [userInfo allKeys];
    
    if ([keys containsObject:@"workoutIndexToSave"]) {
        NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];
        TrainingProgram *currentTrainingProgram = (TrainingProgram *)[moc objectWithURI:[[NSUserDefaults standardUserDefaults] URLForKey:@"currentTrainingplan"]];
        NSInteger finishedWorkoutIndex = [[userInfo objectForKey:@"workoutIndexToSave"] integerValue];
        Training *workout = currentTrainingProgram.trainings[finishedWorkoutIndex];
        workout.repetitionCounter = @([workout.repetitionCounter integerValue] + 1);
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    /*else if ([keys containsObject:@"exerciseIsToSave"]) {
        StatisticsProvider *statisticProvider = [[StatisticsProvider alloc] init];
        NSDictionary *exerciseDict = [userInfo objectForKey:@"exerciseIsToSave"];
        //save all statistics to core data
        for(NSString *exerciseKey in [exerciseDict allKeys])
        {
            NSArray *statisticArrayForExercise = exerciseDict[exerciseKey];
            
            for (NSArray *arrayOfStats in statisticArrayForExercise) {
                //let's save all data!
                //if (![arrayOfStats[2] boolValue])//if set is NOT failed
                //{
                NSInteger currentReps = [arrayOfStats[0] integerValue];
                NSInteger currentWeight = [arrayOfStats[1] integerValue];
                
                Exercise *currentExercise = [[Exercise MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", exerciseKey]] firstObject];
                [statisticProvider createHistoryEntry:currentExercise reps:currentReps weight:currentWeight date:[NSDate date]];
                //}
            }
        }
    }*/
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self.fitManager tryToGetTransfers];
}

- (void)setInstabugColorScheme
{
    [Instabug setColorTheme:IBGColorThemeLight];
    /* [Instabug setButtonsFontColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0]];
    [Instabug setButtonsColor:[UIColor colorWithRed:(27/255.0) green:(40/255.0) blue:(52/255.0) alpha:1.0]];
    [Instabug setHeaderFontColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0]];
    [Instabug setHeaderColor:[UIColor colorWithRed:(44/255.0) green:(62/255.0) blue:(80/255.0) alpha:1.0]];
    [Instabug setTextFontColor:[UIColor colorWithRed:(82/255.0) green:(83/255.0) blue:(83/255.0) alpha:1.0]];
    [Instabug setTextBackgroundColor:[UIColor colorWithRed:(249/255.0) green:(249/255.0) blue:(249/255.0) alpha:1.0]]; */
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"createModeON"];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
