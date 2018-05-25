//
//  ConnectivityManager.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 30/06/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import "ConnectivityManager.h"
#import "ProgressWatchdog.h"

@interface ConnectivityManager() <WCSessionDelegate>

@property (strong, nonatomic) NSMutableDictionary *toSyncDictionary;
@property (assign, nonatomic) WCSessionActivationState activationState;
@property (assign, nonatomic) BOOL getInfoRequestSent;

@property (strong, nonatomic) NSMutableDictionary *dictToSync;

@end


@implementation ConnectivityManager

+ (instancetype)sharedManager
{
    static ConnectivityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        if ([WCSession isSupported]) {
            self.session = [WCSession defaultSession];
            self.session.delegate = self;
            self.finishedWorkoutIndex = -1;
            [self.session activateSession];
            [self saveTrainingPlan];
            self.getInfoRequestSent = NO;
            self.ignoreUpdates = NO;
            self.dictToSync = [NSMutableDictionary new];
        }
        self.toSyncDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"DictToSync"];
        if(self.toSyncDictionary) {
            if(self.session.isReachable) {
                [self.session transferUserInfo:self.toSyncDictionary];
                self.toSyncDictionary = [NSMutableDictionary new];
            }
        } else {
            self.toSyncDictionary = [NSMutableDictionary new];
        }
    }
    
    return self;
}

- (void)dealloc {
    if([self.toSyncDictionary count] != 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.toSyncDictionary forKey:@"DictToSync"];
    }
}

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {
    self.activationState = activationState;
}

- (void)addUUIDToContext:(NSMutableDictionary *)mutableAppContext {
    [mutableAppContext setObject:[[NSUUID UUID] UUIDString] forKey: [NSString stringWithFormat:@"REMOVE-%@", [[NSUUID UUID] UUIDString]]];
}

- (void)removeOldUUIDsFromContext:(NSMutableDictionary *)mutableAppContext {
    NSArray *allKeys = [mutableAppContext allKeys];
    NSPredicate *REMOVEPredicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] 'REMOVE-'"];
    NSArray *beginWithREMOVEKeys = [allKeys filteredArrayUsingPredicate:REMOVEPredicate];
    for(NSString *key in beginWithREMOVEKeys) {
        [mutableAppContext removeObjectForKey:key];
    }
}

- (BOOL)tryToGetInfoFromPhoneForced:(BOOL)forced {
    if(self.getInfoRequestSent && !forced) {
        return YES;
    }
    
    
    if (self.activationState != WCSessionActivationStateActivated) {
        return NO;
    }
    
    if(!forced) {
        if([self.session.applicationContext objectForKey:@"trainingPlanInfo"]) {
            [self saveTrainingPlan];
            return YES;
        }
    }
    
    self.getInfoRequestSent = YES;
    
    NSMutableDictionary *appContext = [NSMutableDictionary new];
    
    [self removeOldUUIDsFromContext:appContext];
    [self addUUIDToContext:appContext];

    [appContext setValue:@YES forKey:@"trainingPlanRequested"];
    [appContext setValue:@YES forKey:@"fromWatch"];
    [appContext setValue:@NO forKey:@"fromPhone"];

    
    if(self.finishedWorkoutIndex != -1) {
        self.finishedWorkoutIndex = -1;
    }
    
    NSError *error;
    [self.session updateApplicationContext:appContext error:&error];
    
    if(error != nil) {
        return NO;
    } else {
        return YES;
    }
}

- (void)saveTrainingPlan {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *trainingPlanInfo = [defaults objectForKey:@"trainingPlanInfo"];
    self.trainingPlanDictionary = trainingPlanInfo;
    if(trainingPlanInfo) {
        NSArray *workouts = trainingPlanInfo[@"workouts"];
        NSInteger currentWorkoutIndex = [trainingPlanInfo[@"currentWorkoutIndex"] integerValue];
        self.currentWorkout = workouts[currentWorkoutIndex];
    }
}

- (void)setCurrentWorkout:(NSDictionary *)workout {
    _currentWorkout = workout;
    
    NSArray *workouts = self.trainingPlanDictionary[@"workouts"];
    NSInteger indexOfCurrentWorkout = [workouts indexOfObject:workout];
    NSMutableDictionary *d = [self.trainingPlanDictionary mutableCopy];
    d[@"currentWorkoutIndex"] = @(indexOfCurrentWorkout);
    self.trainingPlanDictionary = [d copy];
    [[NSUserDefaults standardUserDefaults] setObject:self.trainingPlanDictionary forKey:@"trainingPlanInfo"];

    if(self.session.isReachable) {
        [self.session transferUserInfo:@{@"currentWorkoutIndex" : @(indexOfCurrentWorkout)}];
    } else {
        
    }
}

- (void)saveResultForExerciseWithName:(NSString *)exerciseName withWeight:(NSInteger)weight andReps:(NSInteger)reps {
    NSMutableDictionary *resultsDict = [self.dictToSync[@"resultsDictionary"] mutableCopy] ?: [NSMutableDictionary new];
    NSMutableArray *resultsArray = [resultsDict[exerciseName] mutableCopy];
    if(!resultsArray) {
        resultsArray = [NSMutableArray new];
    }
    [resultsArray addObject:@{@"date" : [NSDate date], @"weight" : @(weight), @"repetitions" : @(reps)}];
    [resultsDict setObject:[resultsArray copy] forKey:exerciseName];

    NSMutableDictionary *statesDict = self.dictToSync[@"statesDictionary"] ?: [NSMutableDictionary new];
    
    [self updateAppContextWithResults:[resultsDict copy] states:statesDict];
}

- (void)updateStatuses:(NSDictionary *)statesDictionary {
    NSMutableDictionary *resultsDict = self.dictToSync[@"resultsDictionary"] ?: [NSMutableDictionary new];
    [self updateAppContextWithResults:resultsDict states:statesDictionary];
}

- (void)updateResults:(NSDictionary *)resultsDictionary {
    NSMutableDictionary *statesDict = self.dictToSync[@"statesDictionary"] ?: [NSMutableDictionary new];
    [self.dictToSync setObject:resultsDictionary forKey:@"resultsDictionary"];

    [self updateAppContextWithResults:resultsDictionary states:statesDict];
}

- (void)finishWorkout {
    NSNumber *currentWorkoutIndex = [self.trainingPlanDictionary objectForKey:@"currentWorkoutIndex"];
    self.finishedWorkoutIndex = currentWorkoutIndex.intValue;

    [self updateAppContextWithResults:self.dictToSync[@"resultsDictionary"] states:self.dictToSync[@"statesDictionary"]];
    
    NSMutableDictionary *tpMutable = [self.trainingPlanDictionary mutableCopy];
    NSMutableArray *workoutsArray = [[tpMutable objectForKey:@"workouts"] mutableCopy];
    NSMutableDictionary *currentWorkoutMutable = [[workoutsArray objectAtIndex:[currentWorkoutIndex integerValue]] mutableCopy];

    NSNumber *doneNumber = [currentWorkoutMutable objectForKey:@"numberOfRepsDone"];
    doneNumber = @(doneNumber.intValue + 1);
    [currentWorkoutMutable setObject:doneNumber forKey:@"numberOfRepsDone"];
    [workoutsArray replaceObjectAtIndex:[currentWorkoutIndex integerValue] withObject:[currentWorkoutMutable copy]];
    [tpMutable setObject:[workoutsArray copy] forKey:@"workouts"];
    self.trainingPlanDictionary = [tpMutable copy];
}

- (void)updateAppContextWithResults:(NSDictionary *)resultsDictionary states:(NSDictionary *)statesDictionary
{
    if(self.ignoreUpdates) {
        return;
    }
    
    [self.dictToSync setObject:resultsDictionary ?: @{} forKey:@"resultsDictionary"];
    [self.dictToSync setObject:statesDictionary ?: @{} forKey:@"statesDictionary"];
    
    NSMutableDictionary *appContext = [NSMutableDictionary new];
    
    [self removeOldUUIDsFromContext:appContext];
    [self addUUIDToContext:appContext];
    
    [appContext setObject:[NSDate date] forKey: @"lastChangeTimestamp"];
    
    [appContext setObject:resultsDictionary ?: @{} forKey:@"resultsDictionary"];
    [appContext setObject:statesDictionary ?: @{} forKey:@"statesDictionary"];
    [appContext setObject:@(self.finishedWorkoutIndex) forKey:@"finishedWorkoutIndex"];
    [appContext setValue:@YES forKey:@"fromWatch"];
    [appContext setValue:@NO forKey:@"fromPhone"];
    
    if(self.finishedWorkoutIndex != -1) {
        self.finishedWorkoutIndex = -1;
        [appContext setValue:@YES forKey:@"trainingPlanRequested"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error;
        [self.session updateApplicationContext:appContext error:&error];
    });
}

// resultsDictionary
// isInProgress
// statesDictionary



- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *, id> *)applicationContext {
    if(![[applicationContext valueForKey:@"fromPhone"] isEqual: @YES]) {
        return;
    }

    NSDictionary *trainingPlan = [applicationContext objectForKey:@"trainingPlanInfo"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(trainingPlan != nil) {
        [defaults setObject:trainingPlan forKey:@"trainingPlanInfo"];
        [defaults synchronize];
        [self saveTrainingPlan];
    } else {
        if(![defaults objectForKey:@"trainingPlanInfo"]) {
            self.trainingPlanDictionary = nil;
        } else {
            [self saveTrainingPlan];
        }
    }
    
    [[ProgressWatchdog sharedWatchdog] saveStatusesFromAppContext:applicationContext];
    [[ProgressWatchdog sharedWatchdog] saveResultsFromAppContext:applicationContext];
    
    if(applicationContext[@"finishedWorkoutIndex"]) {
        self.finishedWorkoutIndex = [applicationContext[@"finishedWorkoutIndex"] intValue];
    }
    
    if(applicationContext[@"phoneDataUpdateRequested"]) {
        NSMutableArray *arrayOfAllResults = [[NSUserDefaults standardUserDefaults] objectForKey:@"allResults"];
        if(!arrayOfAllResults) { return; }
        
        NSMutableDictionary *appContext = [NSMutableDictionary new];
        
        [self removeOldUUIDsFromContext:appContext];
        [self addUUIDToContext:appContext];
        
        [appContext setObject:[NSDate date] forKey: @"lastChangeTimestamp"];
        [appContext setValue:@YES forKey:@"fromWatch"];
        [appContext setValue:@NO forKey:@"fromPhone"];
        [appContext setObject:arrayOfAllResults ?: @{} forKey:@"allResultsArray"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            [self.session updateApplicationContext:appContext error:&error];
        });
    }
    
    if(applicationContext[@"lastSyncDate"]) {
        NSDate *lastSyncDate = applicationContext[@"lastSyncDate"];
        if(lastSyncDate) {
            [[ProgressWatchdog sharedWatchdog] setLastSyncDate: lastSyncDate];
        }
    }
}

@end
