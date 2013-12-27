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

+(void)setupSharedInstance;
+ (NSURL*)modelURL;
+ (NSString *)baseName;
+ (NSURL *)applicationDocumentsDirectory;
+ (void)createApplicationSupportDirIfNeeded;
+ (void)addAutoMigratingSqliteStoreToCoordinator:(NSPersistentStoreCoordinator*)coordinator;
+ (void)addInMemoryStoreToCoordinator:(NSPersistentStoreCoordinator*)coordinator;

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

@end
