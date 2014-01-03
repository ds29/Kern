
#import "Kern.h"
#import "NSManagedObject+Kern.h"
#import "NSManagedObject+Aggregates.h"

@implementation NSManagedObject (Aggregates)

+ (NSUInteger)countAll {
    return [self countAllWhere:nil];
}

+ (NSUInteger)countAllWhere:(id)condition, ... {
    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
        return [self countAllWhere:predicate];
    }
    return [self kern_countAllWhere:condition];
}

#pragma mark - Private

+ (NSUInteger)kern_countAllWhere:(id)condition {
    
    return [Kern kern_countForFetchRequest:[Kern kern_fetchRequestForEntityName:[self kern_entityName] condition:condition sort:nil limit:0]];
}

@end
