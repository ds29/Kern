//
//  Kern.m
//  Kern
//
//  Created by Dustin Steele on 12/20/13.
//  Copyright (c) 2013 Varsity Tutors. All rights reserved.

#import "Kern.h"

NSString * const kKernDefaultStoreFileName = @"KernDataStore.sqlite";
NSString * const kKernDefaultModelFileName = @"KernModel.sqlite";
NSString * const kKernDefaultBaseName = @"Kern";
static Kern *_sharedInstance = nil;

# pragma mark - Private Declarations
@interface Kern()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (void)setupSharedInstance;
+ (NSURL*)modelURL;
+ (NSString *)baseName;
+ (NSURL *)applicationDocumentsDirectory;
+ (void)createApplicationSupportDirIfNeeded;
+ (void)addAutoMigratingSqliteStoreToCoordinator:(NSPersistentStoreCoordinator*)coordinator;
+ (void)addInMemoryStoreToCoordinator:(NSPersistentStoreCoordinator*)coordinator;

+ (NSUInteger)kern_countForFetchRequest:(NSFetchRequest*)fetchRequest;
+ (NSArray*)kern_executeFetchRequest:(NSFetchRequest*)fetchRequest;

@end

# pragma mark - Kern Implementation
@implementation Kern

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Initializers / Accessors

// the singleton instance of Kern
+ (instancetype)sharedInstance {
    if (!_sharedInstance) {
        [NSException raise:@"Attempt to access uninitialized instance." format:nil];
    }
    return _sharedInstance;
}

// the shared context
+ (NSManagedObjectContext*)sharedContext {
    if (!_sharedInstance) {
        [NSException raise:@"Attempt to access uninitialized context." format:nil];
    }
    return _sharedInstance.managedObjectContext;
}

// setup a shared instance
+ (void)setupSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [self new];
    });
}

#pragma mark - Path Helpers

+ (NSString *)baseName {
    NSString *defaultName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(id)kCFBundleNameKey];

    return (defaultName != nil) ? defaultName : kKernDefaultBaseName;
}

// Returns the URL to the application's Documents directory.
+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

// Create the folder structure for the data store if it doesn't exist
+ (void)createApplicationSupportDirIfNeeded {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[self storeURL] absoluteString]]) return;
    
    [[NSFileManager defaultManager] createDirectoryAtURL:[[self storeURL] URLByDeletingLastPathComponent]
                             withIntermediateDirectories:YES attributes:nil error:nil];
}

// Return the full path to the model
+ (NSURL*)modelURL {
    return [[NSBundle mainBundle] URLForResource:[self baseName] withExtension:@"momd"];
}

// Return the full path to the data store
+ (NSURL*)storeURL {
   return [[[self applicationDocumentsDirectory] URLByAppendingPathComponent:[self baseName]] URLByAppendingPathExtension:@"sqlite"];
}

#pragma mark - Core Data Setup

+(void)addAutoMigratingSqliteStoreToCoordinator:(NSPersistentStoreCoordinator*)coordinator {

    // make sure our path exists
    [self createApplicationSupportDirIfNeeded];

    // define the auto migration features
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES,
                              NSSQLitePragmasOption: @{@"journal_mode": @"WAL"}
                              };

    // attempt to create the store
    NSError *error = nil;
    NSPersistentStore *store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:options error:&error];
    
    if (!store || error) {
        NSLog(@"FAILED TO CREATE STORE: %@", error);
    }
}

+ (void)addInMemoryStoreToCoordinator:(NSPersistentStoreCoordinator*)coordinator {

    // attempt to create the store
    NSError *error = nil;
    NSPersistentStore *store = [coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error];
    
    if (!store || error) {
        NSLog(@"FAILED TO CREATE STORE: %@", error);
    }
}

+ (void)setupAutoMigratingCoreDataStack {

    // setup our object model and persistent store
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[self modelURL]];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    // add the auto migrating store to the coordinator
    [self addAutoMigratingSqliteStoreToCoordinator:coordinator];
    
    //HACK: lame solution to fix automigration error "Migration failed after first pass"
    if ([[coordinator persistentStores] count] == 0)
    {
        [self addAutoMigratingSqliteStoreToCoordinator:coordinator];
    }
   
    // setup the managed object context
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [context setPersistentStoreCoordinator:coordinator];
    
    
    // setup our instance
    [self setupSharedInstance];
    
    // populate the instance
    _sharedInstance.managedObjectModel = model;
    _sharedInstance.persistentStoreCoordinator = coordinator;
    _sharedInstance.managedObjectContext = context;
}

+ (void)setupInMemoryStoreCoreDataStack {

    // setup our object model and persistent store
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[self modelURL]];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    // add the auto migrating store to the coordinator
    [self addInMemoryStoreToCoordinator:coordinator];
    
    // setup the managed object context
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [context setPersistentStoreCoordinator:coordinator];
    
    // setup our instance
    [self setupSharedInstance];
    
    // populate the instance
    _sharedInstance.managedObjectModel = model;
    _sharedInstance.persistentStoreCoordinator = coordinator;
    _sharedInstance.managedObjectContext = context;
}

+ (void)cleanUp {
    _sharedInstance = nil;
}

#pragma mark - Core Data Save

+ (BOOL)saveContext {
    if (_sharedInstance) {
        NSManagedObjectContext *context = _sharedInstance.managedObjectContext;
        if (context == nil) return NO;
        if (![context hasChanges]) return NO;
        
        NSError *error = nil;
        
        if (![context save:&error]) {
            NSLog(@"Unable to save context! %@, %@", error, [error userInfo]);
            return NO;
        }

        return YES;
    }
    return NO;
}
   
#pragma mark - Library Helpers

+ (NSFetchRequest*)kern_fetchRequestForEntityName:(NSString*)entityName condition:(id)condition sort:(id)sort limit:(NSUInteger)limit {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
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
   
+ (NSUInteger)kern_countForFetchRequest:(NSFetchRequest*)fetchRequest {
   NSError *error = nil;
   NSUInteger count = [[self sharedContext] countForFetchRequest:fetchRequest error:&error];
   
   if (error) {
       [NSException raise:@"Unable to count for fetch request." format:@"Error: %@", error];
   }
   
   return count;
}

+ (NSArray*)kern_executeFetchRequest:(NSFetchRequest*)fetchRequest {
   NSError *error = nil;
   NSArray *results = [[self sharedContext] executeFetchRequest:fetchRequest error:&error];
   
   if (error) {
       [NSException raise:@"Unable to execute fetch request." format:@"Error: %@", error];
   }
   
   return ([results count] > 0) ? results : nil;
}

#pragma mark - Private

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

@end
