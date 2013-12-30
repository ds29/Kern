//
//  NSManagedObject+Fetching.m
//  Kern
//
//  Created by Dustin Steele on 12/30/13.
//  Copyright (c) 2013 Varsity Tutors. All rights reserved.
//

#import "NSManagedObject+Fetching.h"
#import "NSManagedObject+Kern.h"
#import "Kern.h"

@implementation NSManagedObject (Fetching)

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

# pragma mark - Private

+ (NSFetchedResultsController*)kern_fetchAllSortedBy:(id)sort groupedBy:(NSString *)group withLimit:(NSUInteger)limit where:(id)condition {
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:[Kern kern_fetchRequestForEntityName:[self kern_entityName] condition:condition sort:sort limit:limit] managedObjectContext:[Kern sharedContext] sectionNameKeyPath:group cacheName:nil];
}

@end
