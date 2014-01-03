
#import <CoreData/CoreData.h>

@interface NSManagedObject (Aggregates)

+ (NSUInteger)countAll;

+ (NSUInteger)countAllWhere:(id)condition, ...;

@end
