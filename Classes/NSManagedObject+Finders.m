
#import "Kern.h"
#import "NSManagedObject+Kern.h"
#import "NSManagedObject+Finders.h"

@implementation NSManagedObject (Finders)

+ (NSArray*)findAll {
    return [self findAllSortedBy:nil withLimit:0 where:nil];
}

+ (NSArray*)findAllSortedBy:(id)sort {
    return [self findAllSortedBy:sort withLimit:0 where:nil];
}

+ (NSArray*)findAllSortedBy:(id)sort where:(id)condition, ... {
    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
        return [self findAllSortedBy:sort withLimit:0 where:predicate];
    }
    return [self findAllSortedBy:sort withLimit:0 where:condition];
}

+ (NSArray*)findAllSortedBy:(id)sort withLimit:(NSUInteger)limit {
    return [self findAllSortedBy:sort withLimit:limit where:nil];
}

+ (NSArray*)findAllWhere:(id)condition, ... {
    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
        return [self findAllSortedBy:nil withLimit:0 where:predicate];
    }
    return [self findAllSortedBy:nil withLimit:0 where:condition];
}

+ (NSArray*)findAllWithLimit:(NSUInteger)limit where:(id)condition, ... {
    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
        return [self findAllSortedBy:nil withLimit:limit where:predicate];
    }
    return [self findAllSortedBy:nil withLimit:limit where:condition];
}

+ (NSArray*)findAllSortedBy:(id)sort withLimit:(NSUInteger)limit where:(id)condition, ... {
    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
        return [self findAllSortedBy:sort withLimit:limit where:predicate];
    }
    return [self kern_findAllSortedBy:sort withLimit:limit where:condition];
}

# pragma mark - Private

+ (NSArray*)kern_findAllSortedBy:(id)sort withLimit:(NSUInteger)limit where:(id)condition {
    
    return [Kern kern_executeFetchRequest:[Kern kern_fetchRequestForEntityName:[self kern_entityName] condition:condition sort:sort limit:limit]];
}

@end
