//
//  FResult.h
//  F.I.T.
//
//  Created by IVAN CHERNOV on 01/07/16.
//  Copyright © 2016 FIT-Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FResult : NSObject
@property (strong, nonatomic) NSNumber *weightUsed;
@property (strong, nonatomic) NSNumber *repsDone;

- (id)initWithWeight:(NSInteger)weight andReps:(NSInteger)reps;
- (id)initWithWeightNumber:(NSNumber *)weight andRepsNumber:(NSNumber *)reps;
- (void)setWeight:(NSInteger)weight;
- (void)setReps:(NSInteger)reps;

@end
