
#import "NSManagedObject+Finders.h"
#import "NSManagedObject+Modifiers.h"
#import "NSManagedObject+DataMapping.h"

#import "Kern.h"

NSString * const KernIsPrimaryKey = @"__KernIsPrimaryKey";
NSString * const KernDataTypeString = @"__KernDataTypeString";
NSString * const KernDataTypeNumber = @"__KernDataTypeNumber";
NSString * const KernDataTypeBoolean = @"__KernDataTypeBoolean";
NSString * const KernDataTypeDate = @"__KernDataTypeDate";
NSString * const KernDataTypeTime = @"__KernDataTypeTime";
NSString * const KernDataTypeRelationshipBlock = @"__KernDataTypeRelationshipBlock";

NSString * const KernPrimaryKeyAttribute = @"__KernPrimaryKeyAttribute";
NSString * const KernPrimaryKeyDataType = @"__KernPrimaryKeyDataType";
NSString * const KernPrimaryKeyRemoteKey = @"__KernPrimaryKeyRemoteKey";

NSString * const KernCollectionKeyResultsArray = @"__KernCollectionKeyResultsArray";
NSString * const KernCollectionKeyResultsTotal = @"__KernCollectionKeyResultsTotal";

NSUInteger kKernArrayIndexRemoteKey = 0;
NSUInteger kKernArrayIndexDataType = 1;
NSUInteger kKernArrayIndexPrimaryKeyIndicator = 2;
NSUInteger kKernArrayIndexRelationshipBlock = 2;

@implementation NSManagedObject (DataMapping)

+ (NSDictionary*)kern_mappedAttributes {
    return nil;
}

+(NSMutableDictionary*)kernPrimaryKeyStore {
	static NSMutableDictionary *sKernPrimaryKeyStore;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sKernPrimaryKeyStore = [[NSMutableDictionary alloc] init];
	});
	return sKernPrimaryKeyStore;
}

+(NSDateFormatter*)cachedDateFormatter {
	static NSDateFormatter *sCachedDateFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sCachedDateFormatter = [[NSDateFormatter alloc] init];
		[sCachedDateFormatter setDateFormat:@"yyyy-MM-dd"];
	});
	return sCachedDateFormatter;
}

+(NSDateFormatter*)cachedTimeFormatter {
	static NSDateFormatter *sCachedTimeFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        sCachedTimeFormatter = [[NSDateFormatter alloc] init];
		[sCachedTimeFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]; // set to utc
		[sCachedTimeFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	});
	return sCachedTimeFormatter;
}

+(NSNumberFormatter*)cachedNumberFormatter {
    static NSNumberFormatter *sCachedNumberFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sCachedNumberFormatter = [[NSNumberFormatter alloc] init];
    });
    return sCachedNumberFormatter;
}

+ (NSMutableDictionary*)kern_primaryKeyStore {
	
	@synchronized(self.kernPrimaryKeyStore)
	{
		// create a dictionary if there's not one for this class yet
		if (self.kernPrimaryKeyStore[self.class] == nil) {
			
			// get down to just the attributes
			NSDictionary *mappedAttributes = [[[self kern_mappedAttributes] allValues] lastObject];
			for (NSString *k in mappedAttributes) {
				NSArray *obj = [mappedAttributes objectForKey:k];
				
                // Primary key is not allowed to be nested
                if([obj isKindOfClass:[NSArray class]])
                {
                    NSString *dataType = [obj objectAtIndex:kKernArrayIndexDataType];

                    if (![dataType isEqualToString:KernDataTypeRelationshipBlock] && [obj count] > 2 && [[obj objectAtIndex:kKernArrayIndexPrimaryKeyIndicator] isEqualToString:KernIsPrimaryKey]) {
                        NSString *attributeName = [[mappedAttributes allKeysForObject:obj] lastObject];
                        NSString *attributeKey = [obj objectAtIndex:kKernArrayIndexRemoteKey];
                        
                        [self.kernPrimaryKeyStore setObject:@{KernPrimaryKeyAttribute: attributeName, KernPrimaryKeyDataType: dataType, KernPrimaryKeyRemoteKey: attributeKey} forKey:[self kern_entityName]];
                    }
                }
			}
			
		}
    
		return self.kernPrimaryKeyStore;
	}
}

+ (NSString*)kern_primaryKeyAttribute {
    return [self kern_primaryKeyStore][self.kern_entityName][KernPrimaryKeyAttribute];
}

+ (NSString*)kern_primaryKeyDataType {
    return [self kern_primaryKeyStore][self.kern_entityName][KernPrimaryKeyDataType];
}

+ (NSString*)kern_primaryKeyRemoteKey {
    return [self kern_primaryKeyStore][self.kern_entityName][KernPrimaryKeyRemoteKey];
}

+ (instancetype)findByPrimaryKey:(id)aPrimaryKeyValue {
    
    NSString *pk = [self kern_primaryKeyAttribute];
    if (pk) {
        return [[self findAllWithLimit:1 where:@"%K == %@", [self kern_primaryKeyAttribute], aPrimaryKeyValue] lastObject];
    }
    else {
        @throw [NSException exceptionWithName:@"Cannot find record" reason:@"No primary key defined" userInfo:nil];
    }
}

+ (instancetype)findOrCreateByPrimaryKey:(id)aPrimaryKeyValue {
    id obj = [self findByPrimaryKey:aPrimaryKeyValue];
    if (!obj) {
        obj = [self createEntity];
        
        [obj setValue:aPrimaryKeyValue forKey:[self kern_primaryKeyAttribute]];
    }
    return obj;
}

+ (instancetype)updateOrCreateEntityUsingRemoteDictionary:(NSDictionary *)aDictionary {
    return [self updateOrCreateEntityUsingRemoteDictionary:aDictionary andPerformBlockOnEntity:nil];
}

+ (instancetype)updateOrCreateEntityUsingRemoteDictionary:(NSDictionary *)aDictionary andPerformBlockOnEntity:(void (^)(id))entityBlock {
    
    NSString *modelName = [[[self kern_mappedAttributes] allKeys] firstObject]; // mapped attributes must include model name
    BOOL hasRootEntityName = [self hasRootEntityNameForDictionary:aDictionary modelName:modelName];
    NSDictionary *objAttributes = hasRootEntityName ? [[aDictionary allValues] lastObject] : aDictionary;
    
    id pkValue = [objAttributes valueForKey:[self kern_primaryKeyRemoteKey]];
    pkValue = [self ensurePrimaryKeyValueType:pkValue];

    // need to have a primary key to create or update
    if (![[objAttributes allKeys] containsObject:[self kern_primaryKeyRemoteKey]]) {
        @throw [NSException exceptionWithName:@"Can't locate primary key" reason:@"Primary key not provided in remote dictionary" userInfo:nil];
    }

    NSManagedObject *obj = [self findOrCreateByPrimaryKey:pkValue];
    
    NSDictionary *mappedAttributes = [[[self kern_mappedAttributes] allValues] lastObject];
    NSMutableDictionary *convertedAttributes = [NSMutableDictionary dictionary];

    for (NSString *attributeName in [mappedAttributes allKeys]) {
        NSArray *item = [mappedAttributes objectForKey:attributeName];
        
        if([item isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *mappedAttributesNested = (NSDictionary *)item;
            
            for (NSString *attributeNameNested in [mappedAttributesNested allKeys]) {
                NSArray *itemNested = [mappedAttributesNested objectForKey:attributeNameNested];
                [self parseAttributes:attributeNameNested mappedItemAttributes:itemNested objAttributes:objAttributes[attributeName] obj:obj convertedAttributes:convertedAttributes];
            }
        }
        else {
            [self parseAttributes:attributeName mappedItemAttributes:item objAttributes:objAttributes obj:obj convertedAttributes:convertedAttributes];
        }
    }
    
    // set using converted attributes
    [obj updateEntity:convertedAttributes];
    
    if (entityBlock) {
        entityBlock(obj);
    }
    
    return obj;
}

+ (NSArray*)updateOrCreateEntitiesUsingRemoteArray:(NSArray *)anArray {
    return [self updateOrCreateEntitiesUsingRemoteArray:anArray andPerformBlockOnEntities:nil];
}

+ (NSArray*)updateOrCreateEntitiesUsingRemoteArray:(NSArray*)anArray andPerformBlockOnEntities:(void (^)(id))entityBlock {
    NSMutableArray *results = [NSMutableArray array];
    if([anArray count] == 0)
    {
        return results;
    }
    
    for (NSDictionary *aDictionary in anArray) {
        id object = [self updateOrCreateEntityUsingRemoteDictionary:aDictionary andPerformBlockOnEntity:entityBlock];
        [results addObject:object];
    }
    return results;
}


+ (NSArray*)updateOrCreateEntitiesUsingRemoteArrayMT:(NSArray *)anArray {
	return [self updateOrCreateEntitiesUsingRemoteArrayMT:anArray andPerformBlockOnEntities:nil];
}


+ (NSArray*)updateOrCreateEntitiesUsingRemoteArrayMT:(NSArray*)anArray andPerformBlockOnEntities:(void (^)(id))entityBlock
{
	NSMutableArray *results = [NSMutableArray array];
	if([anArray count] == 0)
	{
		return results;
	}
	
	NSString *modelName = [[[self kern_mappedAttributes] allKeys] firstObject]; // mapped attributes must include model name
	NSString *pkAttribute = [self kern_primaryKeyAttribute]; // get the primary key's attribute
	NSString *pkKey = [self kern_primaryKeyRemoteKey]; // get the remote key name for the primary key
    
    BOOL hasRootEntityName = [self hasRootEntityNameForArray:anArray modelName:modelName];
    NSString *keyPath = hasRootEntityName ? [NSString stringWithFormat:@"@unionOfObjects.%@.%@", modelName, pkKey] : [NSString stringWithFormat:@"@unionOfObjects.%@", pkKey];
    
	NSArray *allIDs = [anArray valueForKeyPath:keyPath];
	
	__block NSMutableDictionary* allExistingEntitiesByPK = nil;
	// Execute on other thread if possible
	[[Kern sharedContext].parentContext performBlockAndWait:^{
		
		NSArray* allExistingEntities = [self findAllWhere:@"%K IN %@", pkAttribute, allIDs];
	
		allExistingEntitiesByPK = [NSMutableDictionary dictionaryWithCapacity:[allExistingEntities count]];
	
		for (NSManagedObject *obj in allExistingEntities)
		{
			id pkValue = [obj valueForKey:pkAttribute];
			[allExistingEntitiesByPK setObject:obj forKey:pkValue];
		}
	}];
	
	for (NSDictionary *aDictionary in anArray)
	{
        NSDictionary *objAttributes = hasRootEntityName ? [[aDictionary allValues] lastObject] : aDictionary;
		id pkValue = [objAttributes valueForKey:[self kern_primaryKeyRemoteKey]];
        pkValue = [self ensurePrimaryKeyValueType:pkValue];
	
		__block NSManagedObject* obj = [allExistingEntitiesByPK objectForKey:pkValue];
		if(obj == nil)
		{
			// Execute on other thread if possible
			[[Kern sharedContext].parentContext performBlockAndWait:^{
				obj = [self createEntity];
	
				[obj setValue:pkValue forKey:[self kern_primaryKeyAttribute]];
			}];
		}
		
		NSManagedObject* objForMainQueue = [self updateOrCreateEntityUsingRemoteDictionaryMT:aDictionary forObject:obj andPerformBlockOnEntity:entityBlock];
		
		[results addObject:objForMainQueue];

	}
	
	return results;
}


+ (instancetype)updateOrCreateEntityUsingRemoteDictionaryMT:(NSDictionary *)aDictionary forObject:(NSManagedObject*)obj andPerformBlockOnEntity:(void (^)(id))entityBlock {
	
    NSString *modelName = [[[self kern_mappedAttributes] allKeys] firstObject]; // mapped attributes must include model name
    BOOL hasRootEntityName = [self hasRootEntityNameForDictionary:aDictionary modelName:modelName];
    NSDictionary *objAttributes = hasRootEntityName ? [[aDictionary allValues] lastObject] : aDictionary;
	
	NSDictionary *mappedAttributes = [[[self kern_mappedAttributes] allValues] lastObject];
	NSMutableDictionary *convertedAttributes = [NSMutableDictionary dictionary];
	
	for (NSString *attributeName in [mappedAttributes allKeys]) {
		NSArray *item = [mappedAttributes objectForKey:attributeName];
        
        if([item isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *mappedAttributesNested = (NSDictionary *)item;
            
            for (NSString *attributeNameNested in [mappedAttributesNested allKeys]) {
                NSArray *itemNested = [mappedAttributesNested objectForKey:attributeNameNested];
                [self parseAttributes:attributeNameNested mappedItemAttributes:itemNested objAttributes:objAttributes[attributeName] obj:obj convertedAttributes:convertedAttributes];
            }
        }
        else {
            [self parseAttributes:attributeName mappedItemAttributes:item objAttributes:objAttributes obj:obj convertedAttributes:convertedAttributes];
        }
	}
	
	// Execute on other thread if possible
	[[Kern sharedContext].parentContext performBlockAndWait:^{
		// set using converted attributes
		[obj updateEntity:convertedAttributes];
	}];
	
	// Switch to the main queue
	__block NSManagedObject* objForMainQueue = obj;
	[[Kern sharedContext] performBlockAndWait:^{
		
		if(objForMainQueue.managedObjectContext != [Kern sharedContext])
		{
			objForMainQueue = [[Kern sharedContext] objectWithID:obj.objectID];
		}
		
		if (entityBlock) {
			entityBlock(objForMainQueue);
		}
	
	}];
	
	return objForMainQueue;
}


+ (NSDictionary*)processCollectionOfEntitiesAccordingToStatusIndicator:(NSArray*)remoteArray {
    return [self processCollectionOfEntitiesAccordingToStatusIndicator:remoteArray andPerformBlockOnEntities:nil];
}

+ (NSDictionary*)processCollectionOfEntitiesAccordingToStatusIndicator:(NSArray*)remoteArray andPerformBlockOnEntities:(void(^)(id item))entityBlock {
    
    if([remoteArray count] == 0) {
        return @{ KernCollectionKeyResultsArray: @[], KernCollectionKeyResultsTotal:@(0) };
    }
    
    NSString *modelName = [[[self kern_mappedAttributes] allKeys] firstObject]; // mapped attributes must include model name
    NSString *pkAttribute = [self kern_primaryKeyAttribute]; // get the primary key's attribute
    NSString *pkKey = [self kern_primaryKeyRemoteKey]; // get the remote key name for the primary key
    
    BOOL hasRootEntityName = [self hasRootEntityNameForArray:remoteArray modelName:modelName];
    NSArray *allItems;
    NSArray *deletedItems;
    NSString *keyPath;
    
    if (hasRootEntityName) {
        allItems = [remoteArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K.status != 'D'", modelName]];
        deletedItems = [remoteArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K.status == 'D'", modelName]];
        keyPath = [NSString stringWithFormat:@"@unionOfObjects.%@.%@", modelName, pkKey];
    }
    else {
        allItems = [remoteArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status != 'D'"]];
        deletedItems = [remoteArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status == 'D'"]];
        keyPath = [NSString stringWithFormat:@"@unionOfObjects.%@", pkKey];
    }
    
    
    NSArray *deletedIDs = [deletedItems valueForKeyPath:keyPath];
    
    if ([deletedIDs count] > 0) {
        // Execute on other thread if possible
        [[Kern sharedContext].parentContext performBlockAndWait:^{
            [self deleteAllWhere:@"%K IN %@", pkAttribute, deletedIDs];
        }];
    }
    
    NSArray* results = [self updateOrCreateEntitiesUsingRemoteArrayMT:allItems andPerformBlockOnEntities:entityBlock];
    
    NSInteger recordsAffected = [results count];
    recordsAffected += [deletedItems count];
    
    return @{ KernCollectionKeyResultsArray: results, KernCollectionKeyResultsTotal: [NSNumber numberWithInteger:recordsAffected] };
}


// Helpers

+ (void) parseAttributes:(NSString*)attributeName mappedItemAttributes:(NSArray*)mappedItemAttributes objAttributes:(NSDictionary*)objAttributes
                     obj:(NSManagedObject*)obj convertedAttributes:(NSMutableDictionary*)convertedAttributes
{
    // Only process the key if it's in the remote dictionary, or if it's null (to persist null to the DB).
    NSString *remoteKey = [mappedItemAttributes objectAtIndex:kKernArrayIndexRemoteKey];
    if ([objAttributes isEqual:[NSNull null]] || ([objAttributes isKindOfClass:[NSDictionary class]] && [[objAttributes allKeys] containsObject:remoteKey])) {
        NSString *dataType = [mappedItemAttributes objectAtIndex:kKernArrayIndexDataType];
        
        id aValue = [objAttributes isKindOfClass:[NSDictionary class]] ? [objAttributes valueForKey:remoteKey] : nil;
        
        if ([dataType isEqualToString:KernDataTypeRelationshipBlock]) {
            [[Kern sharedContext].parentContext performBlockAndWait:^{
                KernCoreDataRelationshipBlock blk = (KernCoreDataRelationshipBlock)[mappedItemAttributes objectAtIndex:kKernArrayIndexRelationshipBlock];
                blk(obj, aValue, attributeName, remoteKey);
            }];
        }
        else
        {
            if (aValue != nil && aValue != [NSNull null]) {
                if ([dataType isEqualToString:KernDataTypeString] || [dataType isEqualToString:KernDataTypeBoolean]) {
                    convertedAttributes[attributeName] = aValue;
                }
                else if ([dataType isEqualToString: KernDataTypeNumber]) {
                    if([aValue isKindOfClass:[NSString class]]) {
                        convertedAttributes[attributeName] = [[self cachedNumberFormatter] numberFromString:aValue];
                    }
                    else {
                        convertedAttributes[attributeName] = aValue;
                    }
                }
                else if ([dataType isEqualToString:KernDataTypeDate]) {
                    NSDate *dateValue = [[self cachedDateFormatter] dateFromString:aValue];
                    if (dateValue && ![dateValue isKindOfClass:[NSNull class]]) {
                        convertedAttributes[attributeName] = dateValue;
                    }
                }
                else if ([dataType isEqualToString:KernDataTypeTime]) {
                    NSDate *dateValue = [[self cachedTimeFormatter] dateFromString:aValue];
                    if (dateValue && ![dateValue isKindOfClass:[NSNull class]]) {
                        convertedAttributes[attributeName] = dateValue;
                    }
                }
            }
            else {
                
                // If a default exists, set it. Otherwise, enforce null.
                NSAttributeDescription *description = [obj.entity.attributesByName objectForKey:attributeName];
                if (description.defaultValue) {
                    convertedAttributes[attributeName] = description.defaultValue;
                } else {
                    convertedAttributes[attributeName] = [NSNull null];
                }
            }
        }
    }
}

+ (id) ensurePrimaryKeyValueType:(id)pkValue
{
    NSString* dataType = [self kern_primaryKeyDataType];
    
    if ([dataType isEqualToString: KernDataTypeNumber]) {
        if([pkValue isKindOfClass:[NSString class]]) {
            pkValue = [[self cachedNumberFormatter] numberFromString:pkValue];
        }
    }
    
    return pkValue;
}



// Check if this is API ver1 collection style
+ (BOOL) hasRootEntityNameForArray:(NSArray*)array modelName:(NSString*)modelName
{
    NSDictionary* firstElem = array[0];
    return [self hasRootEntityNameForDictionary:firstElem modelName:modelName];
}

+ (BOOL) hasRootEntityNameForDictionary:(NSDictionary*)dictionary modelName:(NSString*)modelName
{
    if([dictionary count] != 1) {
        return NO;
    }
    
    NSDictionary* value = [dictionary objectForKey:modelName];
    if([value isKindOfClass:[NSDictionary class]] == NO) {
        return NO;
    }
    
    return YES;
}

@end
