//
//  NSManagedObject+Clone.h
//  SLMB4iPhone
//
//  Created by Felix Belau on 09.03.15.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Clone)

- (NSManagedObject *)cloneInContext:(NSManagedObjectContext *)context exludeEntities:(NSArray *)namesOfEntitiesToExclude;

@end
