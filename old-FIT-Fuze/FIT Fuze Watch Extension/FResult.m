//
//  FResult.m
//  F.I.T.
//
//  Created by IVAN CHERNOV on 01/07/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import "FResult.h"

@implementation FResult

- (id)initWithWeight:(NSInteger)weight andReps:(NSInteger)reps
{
    self = [super init];
    if(self) {
        self.weightUsed = @(weight);
        self.repsDone = @(reps);
    }
    return self;
}

- (id)initWithWeightNumber:(NSNumber *)weight andRepsNumber:(NSNumber *)reps
{
    self = [super init];
    if(self) {
        self.weightUsed = weight;
        self.repsDone = reps;
    }
    return self;
}

- (void)setWeight:(NSInteger)weight {
    self.weightUsed = @(weight);
}

- (void)setReps:(NSInteger)reps {
    self.repsDone = @(reps);
}


@end
