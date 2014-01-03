
#import <CoreData/CoreData.h>
#import "NSManagedObject+Kern.h"

@interface NSManagedObject (Finders)

+ (NSArray*)findAll;

+ (NSArray*)findAllSortedBy:(id)sort;

+ (NSArray*)findAllSortedBy:(id)sort where:(id)condition, ...;

+ (NSArray*)findAllSortedBy:(id)sort withLimit:(NSUInteger)limit;

+ (NSArray*)findAllSortedBy:(id)sort withLimit:(NSUInteger)limit where:(id)condition, ...;

+ (NSArray*)findAllWhere:(id)condition, ...;

+ (NSArray*)findAllWithLimit:(NSUInteger)limit where:(id)condition, ...;

@end
