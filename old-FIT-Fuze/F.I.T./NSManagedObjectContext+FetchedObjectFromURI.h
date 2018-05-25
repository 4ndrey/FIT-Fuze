//
//  NSManagedObjectContext+FetchedObjectFromURI.h
//  SLMB4iPhone
//
//  Created by Felix Belau on 04.03.15.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (FetchedObjectFromURI)

- (NSManagedObject *)objectWithURI:(NSURL *)uri;

@end
