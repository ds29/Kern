
#import "Kern.h"
#import "NSManagedObject+Kern.h"
#import "NSManagedObject+Finders.h"
#import "NSManagedObject+Modifiers.h"

@implementation NSManagedObject (Modifiers)

+ (instancetype)createEntity {
    id entity = [NSEntityDescription insertNewObjectForEntityForName:[self kern_entityName] inManagedObjectContext:[Kern sharedThreadedContext]]; // [BK]
	return entity;
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
    BOOL result = [self deleteAllWhere:nil];
	return result;
}

- (void)updateEntity:(NSDictionary*)aDictionary {
    [self setValuesForKeysWithDictionary:aDictionary];
}

- (void)deleteEntity {
    [self.managedObjectContext deleteObject:self]; // [BK]
}

- (BOOL)saveEntity {
    return [Kern saveContext];
}


@end
