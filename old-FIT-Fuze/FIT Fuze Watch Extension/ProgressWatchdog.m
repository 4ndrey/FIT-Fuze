//
//  ProgressWatchdog.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 30/06/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import "ProgressWatchdog.h"
#import "ConnectivityManager.h"

@interface ProgressWatchdog() <HKWorkoutSessionDelegate>

@property (strong, nonatomic) NSMutableOrderedSet *exerciseNamesOrderedSet;
@property (strong, nonatomic) NSMutableDictionary *exerciseSetsDictionary;

@property (strong, nonatomic) ConnectivityManager *connectivityManager;
@property (strong, nonatomic) HKWorkoutSession* wos;
@property (strong, nonatomic) NSDate *workoutStartDate;
@property (strong, nonatomic) NSMutableArray *workoutEvents;
@property (assign, nonatomic) int workoutSaveTries;

//let workoutEvents: [HKWorkoutEvent] = [
//HKWorkoutEvent(type: .Pause, date: startDate.dateByAddingTimeInterval(300)),
//HKWorkoutEvent(type: .Resume, date: startDate.dateByAddingTimeInterval(600))
//

@end

@implementation ProgressWatchdog

+ (instancetype)sharedWatchdog
{
    static ProgressWatchdog *_sharedWatchdog = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWatchdog = [[self alloc] init];
    });
    
    return _sharedWatchdog;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.exerciseNamesOrderedSet = [NSMutableOrderedSet new];
        self.exerciseStatuses = [NSMutableDictionary new];
        self.exerciseResults = [NSMutableDictionary new];
        self.exerciseSetsDictionary = [NSMutableDictionary new];
        self.connectivityManager = [ConnectivityManager sharedManager];
        self.healthStore = [[HKHealthStore alloc] init];
        self.workoutEvents = [NSMutableArray new];

        self.connectivityManager.ignoreUpdates = YES;
        [self fillExerciseSetsDictionary];
        
        self.nextToDoExerciseObject = [self.connectivityManager.currentWorkout[@"workoutObjectsSet"] firstObject];
        self.nextToDoExerciseName = [self.nextToDoExerciseObject[@"exerciseNamesSet"] firstObject];
        self.nextToDoExerciseSet = @0;
        self.activeExerciseObjectIndex = @0;
        
        self.connectivityManager.ignoreUpdates = NO;
        
        HKQuantityType *hrType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
        HKWorkoutType *workoutType = [HKWorkoutType workoutType];
        HKQuantityType *aeType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
        
        [self.healthStore requestAuthorizationToShareTypes:[NSSet setWithObjects:hrType, workoutType, aeType, nil] readTypes:[NSSet setWithObjects:hrType, workoutType, aeType, nil] completion:^(BOOL success, NSError * _Nullable error) {
            [[NSUserDefaults standardUserDefaults] setBool:success forKey:@"heartRateAllowed"];
        }];
    }
    
    return self;
}

- (BOOL)isInProgress {
    BOOL isInProgress = NO;
    for (NSNumber *status in self.exerciseStatuses.allValues)
    {
        if(status.integerValue != ExerciseExecutionStatusNotDone) {
            isInProgress = YES;
        }
    }
    
    if (!isInProgress) {
        if(self.exerciseResults.allValues.count > 0) {
            isInProgress = YES;
        }
    }
    
    return isInProgress;
}

- (void)startWorkoutSession {    
    if(!self.healthStore) {
        self.healthStore = [[HKHealthStore alloc] init];
    }
    self.wos = [[HKWorkoutSession alloc] initWithActivityType:HKWorkoutActivityTypeTraditionalStrengthTraining locationType:HKWorkoutSessionLocationTypeIndoor];
    self.wos.delegate = self;
    [self.healthStore startWorkoutSession:self.wos];
    
    if(self.workoutStartDate == nil) {
        self.workoutStartDate = [NSDate date];
    }
}

- (void)workoutSession:(HKWorkoutSession *)workoutSession
      didChangeToState:(HKWorkoutSessionState)toState
             fromState:(HKWorkoutSessionState)fromState
                  date:(NSDate *)date {
    //NSLog(@"/n/n/n%d %d %@/n/n/n", toState, fromState, date);

}

- (void)workoutSession:(HKWorkoutSession *)workoutSession didFailWithError:(NSError *)error {
    //NSLog(@"/n/n/n%@/n/n/n", error);
}


- (void)endWorkoutSession {
    [self.healthStore endWorkoutSession:self.wos];
}

- (void)fillExerciseSetsDictionary {
    if(!self.connectivityManager.currentWorkout) {
        [self.connectivityManager tryToGetInfoFromPhoneForced:YES];
    }
    
    for(NSDictionary *exerciseObject in self.connectivityManager.currentWorkout[@"workoutObjectsSet"]) {
        for(NSString *exerciseName in exerciseObject[@"exerciseNamesSet"]) {
            [self.exerciseNamesOrderedSet addObject:exerciseName];
            NSDictionary *exerciseSets = @{@"weights" : exerciseObject[@"setWeightsDictionary"][exerciseName],
                                           @"reps" : exerciseObject[@"setRepetitionsDictionary"][exerciseName]};
            [self.exerciseSetsDictionary setObject:exerciseSets forKey:exerciseName];
            [self setStatus:ExerciseExecutionStatusNotDone forExerciseWithName:exerciseName];
        }
    }
}

- (void)setActiveExerciseObjectIndex:(NSNumber *)activeExerciseObjectIndex {
    _activeExerciseObjectIndex = activeExerciseObjectIndex;
}

- (void)reload
{
    [self saveStatusesFromAppContext:self.connectivityManager.session.applicationContext];
    [self saveResultsFromAppContext:self.connectivityManager.session.applicationContext];
}

- (void)saveStatusesFromAppContext:(NSDictionary *)appContext
{
    NSDictionary *remoteStates = appContext[@"statesDictionary"];
    if(remoteStates) {
        
        NSArray *exerciseNames = [remoteStates allKeys];
        for(NSString *exerciseName in exerciseNames) {
            ExerciseExecutionStatusType currentStatus = [[self.exerciseStatuses objectForKey:exerciseName] integerValue];
            if(currentStatus != ExerciseExecutionStatusFinished) {
                [self.exerciseStatuses setObject:remoteStates[exerciseName] forKey:exerciseName];
            }
        }
    }
}

- (void)saveResultsFromAppContext:(NSDictionary *)appContext
{
    if(![[appContext valueForKey:@"fromPhone"] isEqual: @YES]) {
        return;
    }
    
    BOOL wasFinished = [[appContext allKeys] containsObject:@"finishedWorkoutIndex"];
    if(wasFinished) {
        return;
    }
    
    NSDictionary *remoteResults = appContext[@"resultsDictionary"];
    if(remoteResults) {
        NSArray *exerciseNames = [remoteResults allKeys];
        for(NSString *exerciseName in exerciseNames) {
            NSArray *localExerciseResults = self.exerciseResults[exerciseName];
            NSArray *remoteExerciseResults = remoteResults[exerciseName];
            if(!localExerciseResults || localExerciseResults.count == 0) {
                [self.exerciseResults setObject:remoteExerciseResults forKey:exerciseName];
            } else {
                for(NSDictionary *remoteExerciseResult in remoteExerciseResults) {
                    NSDate *remoteExerciseResultDate = remoteExerciseResult[@"date"];
                    BOOL isPresented = NO;
                    for(NSDictionary *localExerciseResult in localExerciseResults) {
                        NSDate *localExerciseResultDate = localExerciseResult[@"date"];
                        if(fabs([localExerciseResultDate timeIntervalSinceDate:remoteExerciseResultDate]) < 1) {
                            isPresented = YES;
                        }
                    }
                    
                    if(!isPresented) {
                        localExerciseResults = [localExerciseResults arrayByAddingObject:remoteExerciseResult];
                    }
                }
                
                [self.exerciseResults setObject:localExerciseResults forKey:exerciseName];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FITResultsReceivedNotification" object:nil userInfo:nil];
    }
}

- (void)setStatus:(ExerciseExecutionStatusType)status forExerciseWithName:(NSString *)exerciseName {
    
    ExerciseExecutionStatusType currentStatus = [[self.exerciseStatuses objectForKey:exerciseName] integerValue];
    if(currentStatus != ExerciseExecutionStatusFinished) {
        [self.exerciseStatuses setObject:@(status) forKey:exerciseName];
    }
    [self.connectivityManager updateStatuses:self.exerciseStatuses];
}

- (ExerciseExecutionStatusType)statusForExercise:(NSString *)exerciseName {
    if([[self.exerciseStatuses allKeys] containsObject:exerciseName]) {
        return [[self.exerciseStatuses objectForKey:exerciseName] integerValue];
    } else {
        [self setStatus:ExerciseExecutionStatusNotDone forExerciseWithName:exerciseName];
        return ExerciseExecutionStatusNotDone;
    }
}

- (NSDictionary *)getExerciseObjectWithIndex:(NSNumber *)indexNumber {
    return [self.connectivityManager.currentWorkout[@"workoutObjectsSet"] objectAtIndex:[indexNumber integerValue]];
}

- (void)saveResultForExerciseWithName:(NSString *)exerciseName withWeight:(NSInteger)weight andReps:(NSInteger)reps {
    NSDictionary *resultToSave = @{@"date" : [NSDate date], @"weight" : @(weight), @"reps" : @(reps)};
    NSArray *resultsForThisExercise = [self.exerciseResults objectForKey:exerciseName];
    if(!resultsForThisExercise) {
        resultsForThisExercise = [NSArray arrayWithObject:resultToSave];
    } else {
        resultsForThisExercise = [resultsForThisExercise arrayByAddingObject:resultToSave];
    }
    [self.exerciseResults setObject:resultsForThisExercise forKey:exerciseName];
    
    NSMutableArray *arrayOfAllResults = [[[NSUserDefaults standardUserDefaults] objectForKey:@"allResults"] mutableCopy];
    if(!arrayOfAllResults) {arrayOfAllResults = [NSMutableArray new];}
    [arrayOfAllResults addObject:@{exerciseName : resultsForThisExercise, @"date" : [NSDate date]}];
    
    [[NSUserDefaults standardUserDefaults] setObject:[arrayOfAllResults copy] forKey:@"allResults"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.connectivityManager updateResults:self.exerciseResults];
}

- (NSArray *)getResultForExerciseWithName:(NSString *)exerciseName {
    return self.exerciseResults[exerciseName];
}

- (BOOL)refreshNextToDos {
    BOOL needToBeUpdated = NO;
    
    NSDictionary *nextToDoExerciseObject = self.nextToDoExerciseObject;
    NSString *nextToDoExerciseName = self.nextToDoExerciseName;
    NSNumber *nextToDoExerciseSet = self.nextToDoExerciseSet;
    
    NSArray *exerciseObjects = self.connectivityManager.currentWorkout[@"workoutObjectsSet"];

    BOOL thereIsInProgressObject = NO;
    for(NSDictionary *exerciseObject in exerciseObjects) {
        NSString *exerciseName = exerciseObject[@"exerciseNamesSet"][0];
        if([self statusForExercise:exerciseName] == ExerciseExecutionStatusInProgress) {
            thereIsInProgressObject = YES;
            self.activeExerciseObjectIndex = @([exerciseObjects indexOfObject:exerciseObject]);
        }
    }
    
    if(self.activeExerciseObjectIndex < 0) {
        self.activeExerciseObjectIndex = 0;
        self.nextToDoExerciseObject = exerciseObjects[[self.activeExerciseObjectIndex integerValue]];
        self.nextToDoExerciseName = self.nextToDoExerciseObject[@"exerciseNamesSet"][0];
        self.nextToDoExerciseSet = @([[self getResultForExerciseWithName: self.nextToDoExerciseName] count]);
    }
    
    self.nextToDoExerciseObject = [self.connectivityManager.currentWorkout[@"workoutObjectsSet"] objectAtIndex:[self.activeExerciseObjectIndex integerValue]];
    self.nextToDoExerciseName = [self.nextToDoExerciseObject[@"exerciseNamesSet"] firstObject];
    self.nextToDoExerciseSet = @0;
    
    int nexIndex = -1;
    if(!thereIsInProgressObject) {
        for(int i = [self.activeExerciseObjectIndex integerValue]; i<exerciseObjects.count; i++) {
            NSDictionary *exerciseObject = exerciseObjects[i];
            NSString *exerciseName = exerciseObject[@"exerciseNamesSet"][0];
            if([self statusForExercise:exerciseName] == ExerciseExecutionStatusNotDone && nexIndex == -1) {
                thereIsInProgressObject = YES;
                for(NSString *exerciseName in exerciseObject[@"exerciseNamesSet"]) {
                    [self setStatus:ExerciseExecutionStatusInProgress forExerciseWithName:exerciseName];
                    nexIndex = nexIndex == -1 ? i : nexIndex;
                }
            }
        }
        
        if(!thereIsInProgressObject) {
            for(int i = 0; i<[self.activeExerciseObjectIndex integerValue]; i++) {
                NSDictionary *exerciseObject = exerciseObjects[i];
                NSString *exerciseName = exerciseObject[@"exerciseNamesSet"][0];
                if([self statusForExercise:exerciseName] == ExerciseExecutionStatusNotDone && nexIndex == -1) {
                    thereIsInProgressObject = YES;
                    for(NSString *exerciseName in exerciseObject[@"exerciseNamesSet"]) {
                        [self setStatus:ExerciseExecutionStatusInProgress forExerciseWithName:exerciseName];
                        nexIndex = nexIndex == -1 ? i : nexIndex;
                    }
                }
            }
        }
        
        
        if(!thereIsInProgressObject) {
            self.activeExerciseObjectIndex = @(-1); //workout finished
            return YES;
        } else {
            self.activeExerciseObjectIndex = @(nexIndex);
        }
    }
    
    self.nextToDoExerciseObject = exerciseObjects[[self.activeExerciseObjectIndex integerValue]];
    self.nextToDoExerciseName = self.nextToDoExerciseObject[@"exerciseNamesSet"][0];
    self.nextToDoExerciseSet = @([[self getResultForExerciseWithName: self.nextToDoExerciseName] count]);
    
    needToBeUpdated = (![nextToDoExerciseObject isEqualToDictionary:self.nextToDoExerciseObject]) || (![nextToDoExerciseName isEqualToString: self.nextToDoExerciseName]);
    if (!needToBeUpdated) {
        int new = self.nextToDoExerciseSet.intValue;
        int old = nextToDoExerciseSet.intValue;
        needToBeUpdated = !((new == old) || (new == old + 1));
    }
    
    return needToBeUpdated;
}

- (int)nextSetForExercise:(NSString *)exerciseName {
    int nextSetIndex = -1; //-1 = all sets are done already
    
    if(!self.exerciseSetsDictionary  || [[self.exerciseSetsDictionary allKeys] count] == 0) {
        [self fillExerciseSetsDictionary];
    }
    
    NSDictionary *exerciseSets = self.exerciseSetsDictionary[exerciseName];
    NSArray *exerciseReps = exerciseSets[@"reps"];
    NSArray *exerciseResults = [self getResultForExerciseWithName:exerciseName];
    if(exerciseReps.count > exerciseResults.count) { //we're still didn't do the last repetition
        nextSetIndex = exerciseResults.count;
    }
        
    return nextSetIndex;
}

- (void)startPause {
    if(self.workoutStartDate) {
        [self.workoutEvents addObject:[HKWorkoutEvent workoutEventWithType:HKWorkoutEventTypePause date:[NSDate date]]];
    }
}

- (void)finishPause {
    if(self.workoutStartDate) {
        [self.workoutEvents addObject:[HKWorkoutEvent workoutEventWithType:HKWorkoutEventTypeResume date:[NSDate date]]];
    }
}

- (void)finishWorkout {
    if(self.workoutSaveTries > 10) {
        self.workoutStartDate = nil;
        self.workoutSaveTries = 0;
        self.workoutEvents = [NSMutableArray new];
        return;
    }
    
    __block NSDate *endWorkoutDate = [NSDate date];
    __block NSDate *startWorkoutDate = self.workoutStartDate;

    HKQuantityType *activeEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKDevice *device = [HKDevice localDevice];
    
    NSPredicate *datePredicate = [HKQuery predicateForSamplesWithStartDate:self.workoutStartDate endDate:endWorkoutDate options:HKQueryOptionNone];
    NSPredicate *devicePredicate = [HKQuery predicateForObjectsFromDevices:[NSSet setWithObject:device]];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[datePredicate, devicePredicate]];
    
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierStartDate ascending:YES];
    HKHealthStore *healthStore = self.healthStore;
    
    HKSampleQuery *query =
    [[HKSampleQuery alloc]
     initWithSampleType:activeEnergyType
     predicate:predicate
     limit:HKObjectQueryNoLimit
     sortDescriptors:@[sortByDate]
     resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {

         if (results == nil) {
             // Add proper error handling here...
             NSLog(@"*** an error occureed: %@ ***", error.localizedDescription);
             return;
         }
         
         HKUnit *energyUnit = [HKUnit kilocalorieUnit];
         double totalActiveEnergy = 0.0;
         
         for (HKQuantitySample *sample in results) {
             totalActiveEnergy += [sample.quantity doubleValueForUnit:energyUnit];
         }
         
         HKQuantity *totalActiveEnergyQuantity = [HKQuantity quantityWithUnit:energyUnit doubleValue:totalActiveEnergy];
         
         HKWorkout *workout = [HKWorkout workoutWithActivityType:HKWorkoutActivityTypeTraditionalStrengthTraining
                                                       startDate:startWorkoutDate
                                                         endDate:endWorkoutDate
                                                   workoutEvents:self.workoutEvents
                                               totalEnergyBurned:totalActiveEnergyQuantity
                                                   totalDistance:nil
                                                          device:device
                                                        metadata:@{HKMetadataKeyIndoorWorkout : [NSNumber numberWithBool:YES]}];
         
         
         if ([healthStore authorizationStatusForType:[HKObjectType workoutType]] != HKAuthorizationStatusSharingAuthorized) {
             NSLog(@"*** the app does not have permission to save workout samples ***");
             return;
         }
         
         [healthStore saveObject:workout withCompletion:^(BOOL success, NSError * _Nullable error) {
             
             if (!success) {
                 self.workoutSaveTries++;
                 [self performSelector:@selector(finishWorkout) withObject:nil afterDelay:100];
                 NSLog(@"*** an error occureed: %@ ***", error.localizedDescription);
                 return;
             }
             
             self.workoutStartDate = nil;
             self.workoutSaveTries = 0;
             self.workoutEvents = [NSMutableArray new];
             
             if ([healthStore authorizationStatusForType:[HKObjectType workoutType]] != HKAuthorizationStatusSharingAuthorized) {
                 NSLog(@"*** the app does not have permission to save active energy burned samples ***");
                 return;
             }
             
             [healthStore addSamples:results toWorkout:workout completion:^(BOOL success, NSError * _Nullable error) {
                 if (!success) {
                     // Add proper error handling here...
                     NSLog(@"*** an error occureed: %@ ***", error.localizedDescription);
                     return;
                 }
                 
                 // Provide clear feedback that the workout saved successfully here…
                 
             }];
             
         }];
         
     }];
    
    [healthStore executeQuery:query];
}

- (void)reset {
    self.workoutEvents = [NSMutableArray new];
    self.exerciseNamesOrderedSet = [NSMutableOrderedSet new];
    self.exerciseStatuses = [NSMutableDictionary new];
    self.exerciseResults = [NSMutableDictionary new];
    self.exerciseSetsDictionary = [NSMutableDictionary new];
    self.connectivityManager = [ConnectivityManager sharedManager];
    
    for(NSDictionary *exerciseObject in self.connectivityManager.currentWorkout[@"workoutObjectsSet"]) {
        for(NSString *exerciseName in exerciseObject[@"exerciseNamesSet"]) {
            [self.exerciseNamesOrderedSet addObject:exerciseName];
            NSDictionary *exerciseSets = @{@"weights" : exerciseObject[@"setWeightsDictionary"][exerciseName],
                                           @"reps" : exerciseObject[@"setRepetitionsDictionary"][exerciseName]};
            [self.exerciseSetsDictionary setObject:exerciseSets forKey:exerciseName];
            [self setStatus:ExerciseExecutionStatusNotDone forExerciseWithName:exerciseName];
        }
    }
    
    self.nextToDoExerciseObject = [self.connectivityManager.currentWorkout[@"workoutObjectsSet"] firstObject];
    self.nextToDoExerciseName = [self.nextToDoExerciseObject[@"exerciseNamesSet"] firstObject];
    self.nextToDoExerciseSet = @0;
    self.activeExerciseObjectIndex = @0;
    self.workoutStartDate = nil;
}

- (void)setLastSyncDate:(NSDate *)date {
    NSArray *arrayOfAllResults = [[NSUserDefaults standardUserDefaults] objectForKey:@"allResults"];
    if(!arrayOfAllResults) { return; }
    
    NSMutableArray *correctResults = [NSMutableArray new];
    
    for(NSDictionary *resultDict in arrayOfAllResults) {
        NSDate *resultDate = resultDict[@"date"];
        if([date timeIntervalSinceDate:resultDate] < 0) {
            [correctResults addObject:resultDict];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[correctResults copy] forKey:@"allResults"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
