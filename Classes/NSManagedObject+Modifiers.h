
#import <CoreData/CoreData.h>

@interface NSManagedObject (Modifiers)

+ (instancetype)createEntity;

+ (instancetype)createEntity:(NSDictionary*)aDictionary;

+ (BOOL)truncateAll;

- (void)deleteEntity;

+ (BOOL)deleteAllWhere:(id)condition, ...;

- (void)updateEntity:(NSDictionary*)aDictionary;

- (BOOL)saveEntity;


@end
