
#import "NSManagedObject+Kern.h"

@implementation NSManagedObject (Kern)

+ (NSString*)kern_entityName {
    return NSStringFromClass([self class]);
}

@end
