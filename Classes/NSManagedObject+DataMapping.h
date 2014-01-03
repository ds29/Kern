
#import <CoreData/CoreData.h>

typedef void (^KernCoreDataRelationshipBlock)(id model, NSDictionary *objDictionary, NSString *attributeName, NSString *attributeKey);

extern NSString* const KernIsPrimaryKey;
extern NSString* const KernDataTypeString;
extern NSString* const KernDataTypeNumber;
extern NSString* const KernDataTypeBoolean;
extern NSString* const KernDataTypeRelationshipBlock;
extern NSString* const KernDataTypeDate;
extern NSString* const KernDataTypeTime;

@interface NSManagedObject (DataMapping)

+ (NSDictionary*)kern_mappedAttributes;

+ (instancetype)findByPrimaryKey:(id)aPrimaryKeyValue;

+ (instancetype)findOrCreateByPrimaryKey:(id)aPrimaryKeyValue;

+ (instancetype)updateOrCreateEntityUsingRemoteDictionary:(NSDictionary *)aDictionary;

+ (NSUInteger)updateOrCreateEntitiesUsingRemoteArray:(NSArray*)anArray;

@end
