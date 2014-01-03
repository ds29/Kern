
#import <CoreData/CoreData.h>

#import "NSManagedObject+Finders.h"
#import "NSManagedObject+Fetching.h"
#import "NSManagedObject+Aggregates.h"
#import "NSManagedObject+Modifiers.h"
#import "NSManagedObject+DataMapping.h"

@interface NSManagedObject (Kern)

+ (NSString*)kern_entityName;

@end
