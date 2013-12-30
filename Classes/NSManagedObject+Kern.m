//
//  NSManagedObject+Kern.m
//  Kern
//
//  Created by Dustin Steele on 12/23/13.
//  Copyright (c) 2013 Varsity Tutors. All rights reserved.
//

#import "NSManagedObject+Kern.h"
#import "Kern.h"

static NSDateFormatter *sCachedDateFormatter;
static NSDateFormatter *sCachedTimeFormatter;
static NSMutableDictionary *sKernPrimaryKeyStore;

NSString * const KernIsPrimaryKey = @"__KernIsPrimaryKey";
NSString * const KernDataTypeString = @"__KernDataTypeString";
NSString * const KernDataTypeNumber = @"__KernDataTypeNumber";
NSString * const KernDataTypeBoolean = @"__KernDataTypeBoolean";
NSString * const KernDataTypeDate = @"__KernDataTypeDate";
NSString * const KernDataTypeTime = @"__KernDataTypeTime";
NSString * const KernDataTypeRelationshipBlock = @"__KernDataTypeRelationshipBlock";

NSString * const KernPrimaryKeyAttribute = @"__KernPrimaryKeyAttribute";
NSString * const KernPrimaryKeyRemoteKey = @"__KernPrimaryKeyRemoteKey";


NSUInteger kKernArrayIndexRemoteKey = 0;
NSUInteger kKernArrayIndexDataType = 1;
NSUInteger kKernArrayIndexPrimaryKeyIndicator = 2;
NSUInteger kKernArrayIndexRelationshipBlock = 2;

@implementation NSManagedObject (Kern)

+ (NSDictionary*)kern_mappedAttributes {
    return nil;
}

+(NSDateFormatter*)cachedDateFormatter {
    if (sCachedDateFormatter == nil) {
        sCachedDateFormatter = [[NSDateFormatter alloc] init];
        [sCachedDateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    return sCachedDateFormatter;
}

+(NSDateFormatter*)cachedTimeFormatter {
    if (sCachedTimeFormatter == nil) {
        sCachedTimeFormatter = [[NSDateFormatter alloc] init];
        [sCachedTimeFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    }
    return sCachedTimeFormatter;
}

+ (NSMutableDictionary*)kern_primaryKeyStore {
    
    if (sKernPrimaryKeyStore == nil) {
        sKernPrimaryKeyStore = @{}.mutableCopy;
        
        // create a dictionary if there's not one for this class yet
        if (sKernPrimaryKeyStore[self.class] == nil) {
            
            // get down to just the attributes
            NSDictionary *mappedAttributes = [[[self kern_mappedAttributes] allValues] lastObject];
            for (NSString *k in mappedAttributes) {
                NSArray *obj = [mappedAttributes objectForKey:k];

                if ([obj count] > 2 && [[obj objectAtIndex:kKernArrayIndexPrimaryKeyIndicator] isEqualToString:KernIsPrimaryKey]) {
                    NSString *attributeName = [[mappedAttributes allKeysForObject:obj] lastObject];
                    NSString *attributeKey = [obj objectAtIndex:kKernArrayIndexRemoteKey];
                    
                    [sKernPrimaryKeyStore setObject:@{KernPrimaryKeyAttribute: attributeName, KernPrimaryKeyRemoteKey: attributeKey} forKey:[self kern_entityName]];
                }
            }
            
        }
    }
    
    return sKernPrimaryKeyStore;
}

+ (NSString*)kern_primaryKeyAttribute {
    
    return [self kern_primaryKeyStore][self.kern_entityName][KernPrimaryKeyAttribute];
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

+ (NSFetchedResultsController*)fetchAll {
    return [self fetchAllSortedBy:nil groupedBy:nil withLimit:0 where:nil];
}

+ (NSFetchedResultsController*)fetchAllGroupedBy:(NSString*)group {
    return [self fetchAllSortedBy:nil groupedBy:group withLimit:0 where:nil];
}

+ (NSFetchedResultsController*)fetchAllGroupedBy:(NSString*)group where:(id)condition, ... {

    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
        return [self fetchAllSortedBy:nil groupedBy:group withLimit:0 where:predicate];
    }

    return [self fetchAllSortedBy:nil groupedBy:nil withLimit:0 where:condition];
}

+ (NSFetchedResultsController*)fetchAllGroupedBy:(NSString*)group withLimit:(NSUInteger)limit {
    return [self fetchAllSortedBy:nil groupedBy:group withLimit:limit where:nil];
}

+ (NSFetchedResultsController*)fetchAllGroupedBy:(NSString*)group withLimit:(NSUInteger)limit where:(id)condition, ... {
    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
        return [self fetchAllSortedBy:nil groupedBy:group withLimit:limit where:predicate];
    }

    return [self fetchAllSortedBy:nil groupedBy:group withLimit:limit where:condition];
}

+ (NSFetchedResultsController*)fetchAllSortedBy:(id)sort {
    return [self fetchAllSortedBy:sort groupedBy:nil withLimit:0 where:nil];
}

+ (NSFetchedResultsController*)fetchAllSortedBy:(id)sort groupedBy:(NSString*)group {
    return [self fetchAllSortedBy:sort groupedBy:group withLimit:0 where:nil];
}

+ (NSFetchedResultsController*)fetchAllSortedBy:(id)sort groupedBy:(NSString*)group where:(id)condition, ... {
    
    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
        return [self fetchAllSortedBy:sort groupedBy:group withLimit:0 where:predicate];
    }
    
    return [self fetchAllSortedBy:sort groupedBy:group withLimit:0 where:condition];

}

+ (NSFetchedResultsController*)fetchAllSortedBy:(id)sort groupedBy:(NSString*)group withLimit:(NSUInteger)limit {
    return [self fetchAllSortedBy:sort groupedBy:group withLimit:limit where:nil];
}

+ (NSFetchedResultsController*)fetchAllSortedBy:(id)sort where:(id)condition, ... {
    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
        return [self fetchAllSortedBy:sort groupedBy:nil withLimit:0 where:predicate];
    }

    return [self fetchAllSortedBy:sort groupedBy:nil withLimit:0 where:condition];
}

+ (NSFetchedResultsController*)fetchAllSortedBy:(id)sort withLimit:(NSUInteger)limit {
    return [self fetchAllSortedBy:sort groupedBy:nil withLimit:limit where:nil];
}

+ (NSFetchedResultsController*)fetchAllSortedBy:(id)sort withLimit:(NSUInteger)limit where:(id)condition, ... {
    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
        return [self fetchAllSortedBy:sort groupedBy:nil withLimit:limit where:predicate];
    }

    return [self fetchAllSortedBy:sort groupedBy:nil withLimit:limit where:condition];
}

+ (NSFetchedResultsController*)fetchAllWhere:(id)condition, ... {
    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
        return [self fetchAllSortedBy:nil groupedBy:nil withLimit:0 where:predicate];
    }

    return [self fetchAllSortedBy:nil groupedBy:nil withLimit:0 where:condition];
}

+ (NSFetchedResultsController*)fetchAllWithLimit:(NSUInteger)limit where:(id)condition, ... {
    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
        return [self fetchAllSortedBy:nil groupedBy:nil withLimit:limit where:predicate];
    }

    return [self fetchAllSortedBy:nil groupedBy:nil withLimit:limit where:condition];
}

+ (NSFetchedResultsController*)fetchAllSortedBy:(id)sort groupedBy:(NSString *)group withLimit:(NSUInteger)limit where:(id)condition, ... {
    
    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
        return [self fetchAllSortedBy:sort groupedBy:group withLimit:limit where:predicate];
    }
    return [self kern_fetchAllSortedBy:sort groupedBy:group withLimit:limit where:condition];
}

/*
 #pragma mark - Creation / Deletion
 + (id)create:(NSDictionary *)attributes {
 return [self create:attributes inContext:[NSManagedObjectContext defaultContext]];
 }
 
 + (id)createInContext:(NSManagedObjectContext *)context {
 return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
 inManagedObjectContext:context];
 }
 
 - (void)update:(NSDictionary *)attributes {
 unless([attributes exists]) return;
 
 [attributes each:^(id key, id value) {
 id remoteKey = [self.class keyForRemoteKey:key];
 
 if ([remoteKey isKindOfClass:[NSString class]])
 [self setSafeValue:value forKey:remoteKey];
 else
 [self hydrateObject:value ofClass:remoteKey[@"class"] forKey:remoteKey[@"key"] ?: key];
 }];
 }

*/

#pragma mark - Finders

#pragma mark - Aggregates

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

#pragma mark - Create, Update, Delete

+ (instancetype)createEntity {
    return [NSEntityDescription insertNewObjectForEntityForName:[self kern_entityName] inManagedObjectContext:[Kern sharedContext]];
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

- (void)deleteEntity {
    [[Kern sharedContext] deleteObject:self];
}

- (BOOL)save {
    return [Kern saveContext];
}

#pragma mark - Private

+ (NSString*)kern_entityName {
    return NSStringFromClass([self class]);
}

+ (NSArray*)kern_findAllSortedBy:(id)sort withLimit:(NSUInteger)limit where:(id)condition {
    
    return [self kern_executeFetchRequest:[self kern_fetchRequestWithCondition:condition sort:sort limit:limit]];
}

+ (NSFetchedResultsController*)kern_fetchAllSortedBy:(id)sort groupedBy:(NSString *)group withLimit:(NSUInteger)limit where:(id)condition {
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:[self kern_fetchRequestWithCondition:condition sort:sort limit:limit] managedObjectContext:[Kern sharedContext] sectionNameKeyPath:group cacheName:nil];
}

+ (NSUInteger)kern_countAllWhere:(id)condition {
    return [self kern_countForFetchRequest:[self kern_fetchRequestWithCondition:condition sort:nil limit:0]];
}


+ (NSFetchRequest*)kern_fetchRequestWithCondition:(id)condition sort:(id)sort limit:(NSUInteger)limit {

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[self kern_entityName]];
    request.fetchBatchSize = kKernDefaultBatchSize;
    
    if (condition) {
        request.predicate = [self kern_predicateFromConditional:condition];
    }
    
    if (sort) {
        [request setSortDescriptors:[self kern_sortDescriptorsFromObject:sort]];
    }
    
    if (limit > 0) {
        request.fetchLimit = limit;
    }
    
    return request;

}

+ (NSArray*)kern_sortDescriptorsFromString:(NSString*)sort {
    
    if (!sort || [sort isEmpty]) { return @[]; }

    NSString *trimmedSort = [sort stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters];
    
    NSMutableArray *sortDescriptors = [NSMutableArray array];
    NSArray *sortPhrases = [trimmedSort componentsSeparatedByString:@","];

    for (NSString *phrase in sortPhrases) {
        NSArray *parts = [[phrase stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters] componentsSeparatedByString:@" "];

        NSString *sortKey = [(NSString*)[parts firstObject] stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters];

        BOOL sortDescending = false;

        if ([parts count] == 2) {
            NSString *sortDirection = [[[parts lastObject] stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters] lowercaseString];

            sortDescending = [sortDirection isEqualToString:@"desc"];
        }

        [sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:!sortDescending]];
    }
    return sortDescriptors;
}

+ (NSSortDescriptor *)kern_sortDescriptorFromDictionary:(NSDictionary *)dict {
    NSString *value = [[dict.allValues objectAtIndex:0] uppercaseString];
    NSString *key = [dict.allKeys objectAtIndex:0];
    BOOL isAscending = ![value isEqualToString:@"DESC"];
    return [NSSortDescriptor sortDescriptorWithKey:key ascending:isAscending];
}

+ (NSSortDescriptor *)kern_sortDescriptorFromObject:(id)order {
    if ([order isKindOfClass:[NSSortDescriptor class]])
        return order;
    
    else if ([order isKindOfClass:[NSString class]])
        return [NSSortDescriptor sortDescriptorWithKey:order ascending:YES];
    
    else if ([order isKindOfClass:[NSDictionary class]])
        return [self kern_sortDescriptorFromDictionary:order];
    
    return nil;
}

+ (NSArray *)kern_sortDescriptorsFromObject:(id)order {
    // if it's a comma separated string, use our method to parse it
    if ([order isKindOfClass:[NSString class]] && ([order containsString:@","] || [order containsString:@" "])) {
        return [self kern_sortDescriptorsFromString:order];
    }
    else if ([order isKindOfClass:[NSArray class]]) {
        NSMutableArray *results = [NSMutableArray array];
        for (id object in order) {
            [results addObject:[self kern_sortDescriptorFromObject:object]];
        }
        return results;
    }
    else
        return @[[self kern_sortDescriptorFromObject:order]];
}

+ (NSPredicate*)kern_predicateFromConditional:(id)condition {

    if (condition) {
        if ([condition isKindOfClass:[NSPredicate class]]) { //any kind of predicate?
            return condition;
        }
        else if ([condition isKindOfClass:[NSString class]]) {
            return [NSPredicate predicateWithFormat:condition];
        }
        else if ([condition isKindOfClass:[NSDictionary class]]) {
            // if it's empty or not provided return nil
            if (!condition || [condition count] == 0) { return nil; }
            
            
            NSMutableArray *subpredicates = [NSMutableArray array];
            for (id key in [condition allKeys]) {
                id value = [condition valueForKey:key];
                [subpredicates addObject:[NSPredicate predicateWithFormat:@"%K == %@", key, value]];
            }
            
            return [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];        }

        [NSException raise:@"Invalid conditional." format:nil];
    }

    return nil;
}

+ (NSUInteger)kern_countForFetchRequest:(NSFetchRequest*)fetchRequest {
    NSError *error = nil;
    NSUInteger count = [[Kern sharedContext] countForFetchRequest:fetchRequest error:&error];
    
    if (error) {
        [NSException raise:@"Unable to count for fetch request." format:@"Error: %@", error];
    }
    
    return count;
}

+ (NSArray*)kern_executeFetchRequest:(NSFetchRequest*)fetchRequest {
    NSError *error = nil;
    NSArray *results = [[Kern sharedContext] executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        [NSException raise:@"Unable to execute fetch request." format:@"Error: %@", error];
    }
    
    return ([results count] > 0) ? results : nil;
}

@end
