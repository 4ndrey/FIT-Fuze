//
//  NSManagedObjectContext+FetchedObjectFromURI.m
//  SLMB4iPhone
//
//  Created by Felix Belau on 04.03.15.
//
//

#import "NSManagedObjectContext+FetchedObjectFromURI.h"
@import MagicalRecord;

@implementation NSManagedObjectContext (FetchedObjectFromURI)

- (NSManagedObject *)objectWithURI:(NSURL *)uri
{
    NSManagedObjectID *objectID =
    [[NSPersistentStoreCoordinator MR_defaultStoreCoordinator]
     managedObjectIDForURIRepresentation:uri];
    
    if (!objectID)
    {
        return nil;
    }
    
    NSManagedObject *objectForID = [self objectWithID:objectID];
    if (![objectForID isFault])
    {
        return objectForID;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
    [request setEntity:[objectID entity]];
    
     NSPredicate  *predicate = [NSPredicate predicateWithFormat:@"SELF = %@", objectForID];
    [request setPredicate:predicate];
    
    NSArray *results = [self executeFetchRequest:request error:nil];
    if ([results count] > 0 )
    {
        return [results objectAtIndex:0];
    }
    
    return nil;
}

@end
