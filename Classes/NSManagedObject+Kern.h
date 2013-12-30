//
//  NSManagedObject+Kern.h
//  Kern
//
//  Created by Dustin Steele on 12/23/13.
//  Copyright (c) 2013 Varsity Tutors. All rights reserved.
//

#import <CoreData/CoreData.h>

#define kKernDefaultBatchSize 20

typedef void (^KernCoreDataRelationshipBlock)(id model, NSDictionary *objDictionary, NSString *attributeName, NSString *attributeKey);

extern NSString* const KernIsPrimaryKey;
extern NSString* const KernDataTypeString;
extern NSString* const KernDataTypeNumber;
extern NSString* const KernDataTypeBoolean;
extern NSString* const KernDataTypeRelationshipBlock;
extern NSString* const KernDataTypeDate;
extern NSString* const KernDataTypeTime;

@interface NSManagedObject (Kern)

+ (NSDictionary*)kern_mappedAttributes;

+ (instancetype)findByPrimaryKey:(id)aPrimaryKeyValue;
+ (instancetype)findOrCreateByPrimaryKey:(id)aPrimaryKeyValue;

+ (NSArray*)findAll;

+ (NSArray*)findAllSortedBy:(id)sort;

+ (NSArray*)findAllSortedBy:(id)sort where:(id)condition, ...;

+ (NSArray*)findAllSortedBy:(id)sort withLimit:(NSUInteger)limit;

+ (NSArray*)findAllSortedBy:(id)sort withLimit:(NSUInteger)limit where:(id)condition, ...;

+ (NSArray*)findAllWhere:(id)condition, ...;

+ (NSArray*)findAllWithLimit:(NSUInteger)limit where:(id)condition, ...;

+ (NSFetchedResultsController*)fetchAll;

+ (NSFetchedResultsController*)fetchAllGroupedBy:(NSString*)group;

+ (NSFetchedResultsController*)fetchAllGroupedBy:(NSString*)group where:(id)condition, ...;

+ (NSFetchedResultsController*)fetchAllGroupedBy:(NSString*)group withLimit:(NSUInteger)limit;

+ (NSFetchedResultsController*)fetchAllGroupedBy:(NSString*)group withLimit:(NSUInteger)limit where:(id)condition, ...;

+ (NSFetchedResultsController*)fetchAllSortedBy:(id)sort;

+ (NSFetchedResultsController*)fetchAllSortedBy:(id)sort groupedBy:(NSString*)group;

+ (NSFetchedResultsController*)fetchAllSortedBy:(id)sort groupedBy:(NSString*)group where:(id)condition, ...;

+ (NSFetchedResultsController*)fetchAllSortedBy:(id)sort groupedBy:(NSString*)group withLimit:(NSUInteger)limit;

+ (NSFetchedResultsController*)fetchAllSortedBy:(id)sort groupedBy:(NSString*)group withLimit:(NSUInteger)limit where:(id)condition, ...;

+ (NSFetchedResultsController*)fetchAllSortedBy:(id)sort where:(id)condition, ...;

+ (NSFetchedResultsController*)fetchAllSortedBy:(id)sort withLimit:(NSUInteger)limit;

+ (NSFetchedResultsController*)fetchAllSortedBy:(id)sort withLimit:(NSUInteger)limit where:(id)condition, ...;

+ (NSFetchedResultsController*)fetchAllWhere:(id)condition, ...;

+ (NSFetchedResultsController*)fetchAllWithLimit:(NSUInteger)limit where:(id)condition, ...;

+ (NSUInteger)countAll;

+ (NSUInteger)countAllWhere:(id)condition, ...;

# pragma mark - Create, Update, Delete, Save

+ (instancetype)createEntity;

+ (BOOL)truncateAll;

- (void)deleteEntity;

+ (BOOL)deleteAllWhere:(id)condition, ...;

- (BOOL)save;

# pragma mark - Mappings




@end
