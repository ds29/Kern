
#import "Kern.h"
#import "NSURL+DoNotBackup.h"

NSString * const kKernDefaultStoreFileName = @"KernDataStore.sqlite";
NSString * const kKernDefaultBaseName = @"Kern";
static NSPersistentStore *_persistentStore;
static NSManagedObjectContext *_privateQueueContext;
static NSManagedObjectContext *_mainQueueContext;

# pragma mark - Private Declarations
@interface Kern()

+ (NSString *)baseName;
+ (NSURL *)applicationDocumentsDirectory;
+ (void)createApplicationSupportDirIfNeeded;
+ (void)setupAutoMigratingCoreDataStack:(BOOL)shouldAddDoNotBackupAttribute;

+ (void)kern_didSaveContext:(NSNotification*)notification;
+ (NSUInteger)kern_countForFetchRequest:(NSFetchRequest*)fetchRequest;
+ (NSArray*)kern_executeFetchRequest:(NSFetchRequest*)fetchRequest;

@end

# pragma mark - Kern Implementation
@implementation Kern

#pragma mark - Accessors

// the shared context
+ (NSManagedObjectContext*)sharedContext {
    if (!_mainQueueContext) {
        [self setupInMemoryStoreCoreDataStack];  // if nothing was setup, we'll use an in memory store
    }
    return _mainQueueContext;
}

#pragma mark - Path Helpers

+ (NSString *)baseName {
    NSString *defaultName = [[[NSBundle bundleForClass:[self class]] infoDictionary] valueForKey:(id)kCFBundleNameKey];

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

// Return the full path to the data store
+ (NSURL*)storeURL {
   return [[[self applicationDocumentsDirectory] URLByAppendingPathComponent:[self baseName]] URLByAppendingPathExtension:@"sqlite"];
}

#pragma mark - Core Data Setup

+ (void)setupAutoMigratingCoreDataStack:(BOOL)shouldAddDoNotBackupAttribute {
    // setup our object model and persistent store
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    
    // create the folder if we need it
    [self createApplicationSupportDirIfNeeded];
    
    // define the auto migration features
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES,
                              NSSQLitePragmasOption: @{@"journal_mode": @"WAL"}
                              };
    
    NSURL *storeURL = [self storeURL];
    
    if (shouldAddDoNotBackupAttribute) {
        // add do not backup flag
        [storeURL addSkipBackupAttribute];
    }

    // attempt to create the store
    NSError *error = nil;
    _persistentStore = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
    
    if (!_persistentStore || error) {
        NSLog(@"Unable to create persistent store! %@, %@", error, [error userInfo]);
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kern_didSaveContext:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    _privateQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_privateQueueContext setPersistentStoreCoordinator:coordinator];
    
    _mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_mainQueueContext setParentContext:_privateQueueContext];
}

+ (void)setupAutoMigratingCoreDataStackWithDoNotBackupAttribute {
    [self setupAutoMigratingCoreDataStack:YES];
}

+ (void)setupAutoMigratingCoreDataStack {
    [self setupAutoMigratingCoreDataStack:NO];
}

+ (void)setupInMemoryStoreCoreDataStack {
    // setup our object model and persistent store
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    
    // create the folder if we need it
    [self createApplicationSupportDirIfNeeded];
    
    // define the auto migration features
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES,
                              NSSQLitePragmasOption: @{@"journal_mode": @"WAL"}
                              };
    
    // attempt to create the store
    NSError *error = nil;
    _persistentStore = [coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:options error:&error];
    
    if (!_persistentStore || error) {
        NSLog(@"Unable to create persistent store! %@, %@", error, [error userInfo]);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kern_didSaveContext:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    _privateQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_privateQueueContext setPersistentStoreCoordinator:coordinator];
    
    _mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_mainQueueContext setParentContext:_privateQueueContext];
}

+ (void)cleanUp {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
    _persistentStore = nil;
    _privateQueueContext = nil;
    _mainQueueContext = nil;
    
}

#pragma mark - Core Data Save

+ (void)kern_didSaveContext:(NSNotification*)notification {
    NSManagedObjectContext *mainContext = _mainQueueContext;
    if ([notification object] == mainContext) {
        NSManagedObjectContext *parentContext = [mainContext parentContext];
        [parentContext performBlock:^{
            [parentContext save:nil];
        }];
    }
}

+ (BOOL)saveContext {
    NSManagedObjectContext *context = _mainQueueContext;
    if (context == nil) return NO;
    if (![context hasChanges]) return NO;
    
    NSError *error = nil;
    
    if (![context save:&error]) {
        NSLog(@"Unable to save context! %@, %@", error, [error userInfo]);
        return NO;
    }

    return YES;
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
