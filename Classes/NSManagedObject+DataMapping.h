
#import <CoreData/CoreData.h>

typedef void (^KernCoreDataRelationshipBlock)(id obj, id value, NSString *attributeName, NSString *attributeKey);

extern NSString* const KernIsPrimaryKey;
extern NSString* const KernDataTypeString;
extern NSString* const KernDataTypeNumber;
extern NSString* const KernDataTypeBoolean;
extern NSString* const KernDataTypeRelationshipBlock;
extern NSString* const KernDataTypeDate;
extern NSString* const KernDataTypeTime;

extern NSString* const KernCollectionKeyResultsArray;
extern NSString* const KernCollectionKeyResultsTotal;


@interface NSManagedObject (DataMapping)

+ (NSDictionary*)kern_mappedAttributes;

+ (NSString*)kern_primaryKeyAttribute;
+ (NSString*)kern_primaryKeyRemoteKey;

+ (instancetype)findByPrimaryKey:(id)aPrimaryKeyValue;

+ (instancetype)findOrCreateByPrimaryKey:(id)aPrimaryKeyValue;

+ (instancetype)updateOrCreateEntityUsingRemoteDictionary:(NSDictionary *)aDictionary;

+ (instancetype)updateOrCreateEntityUsingRemoteDictionary:(NSDictionary *)aDictionary andPerformBlockOnEntity:(void(^)(id item))entityBlock;

+ (NSArray*)updateOrCreateEntitiesUsingRemoteArray:(NSArray*)anArray;
+ (NSArray*)updateOrCreateEntitiesUsingRemoteArray:(NSArray *)anArray andPerformBlockOnEntities:(void(^)(id item))entityBlock;

+ (NSArray*)updateOrCreateEntitiesUsingRemoteArrayMT:(NSArray *)anArray;
+ (NSArray*)updateOrCreateEntitiesUsingRemoteArrayMT:(NSArray*)anArray andPerformBlockOnEntities:(void (^)(id))entityBlock;

+ (NSDictionary*)processCollectionOfEntitiesAccordingToStatusIndicator:(NSArray*)remoteArray;
+ (NSDictionary*)processCollectionOfEntitiesAccordingToStatusIndicator:(NSArray*)remoteArray andPerformBlockOnEntities:(void(^)(id item))entityBlock;

@end
