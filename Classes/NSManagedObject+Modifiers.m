
#import "Kern.h"
#import "NSManagedObject+Kern.h"
#import "NSManagedObject+Finders.h"
#import "NSManagedObject+Modifiers.h"

@implementation NSManagedObject (Modifiers)

+ (instancetype)createEntity {
    return [NSEntityDescription insertNewObjectForEntityForName:[self kern_entityName] inManagedObjectContext:[Kern sharedContext]];
}

+ (instancetype)createEntity:(NSDictionary *)aDictionary {
    id obj = [self createEntity];
    [obj updateEntity:aDictionary];
    return obj;
}

+ (BOOL)deleteAllWhere:(id)condition, ... {
    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
        return [self deleteAllWhere:predicate];
    }
    
    for (NSManagedObject *entity in [self findAllWhere:condition]) {
        [entity deleteEntity];
    }
    return YES;
}

+ (BOOL)truncateAll {
    return [self deleteAllWhere:nil];
}

- (void)updateEntity:(NSDictionary*)aDictionary {
    [self setValuesForKeysWithDictionary:aDictionary];
}

- (void)deleteEntity {
    [[Kern sharedContext] deleteObject:self];
}

- (BOOL)saveEntity {
    return [Kern saveContext];
}


@end
