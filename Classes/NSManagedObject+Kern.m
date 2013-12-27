//
//  NSManagedObject+Kern.m
//  Kern
//
//  Created by Dustin Steele on 12/23/13.
//  Copyright (c) 2013 Varsity Tutors. All rights reserved.
//

#import "NSManagedObject+Kern.h"
#import "Kern.h"

@implementation NSManagedObject (Kern)

+ (NSArray *)findAll {
    return [self findAllWhere:nil];
}

+ (NSArray *)findAllWhere:(id)condition, ... {
    // convert the string and arg list to a predicate (if it's a string with args)
    NSPredicate *predicate = nil;
    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
    }
    
    if (predicate) {
        return [self findAllSortedBy:nil where:predicate];
    }
    return [self findAllSortedBy:nil where:condition];
}

+ (NSArray *)findAllSortedBy:(NSString*)sort where:(id)condition, ... {
    // convert the string and arg list to a predicate (if it's a string with args)
    NSPredicate *predicate = nil;
    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
    }
    
    NSFetchRequest *fr = nil;
    if (predicate) {
        fr = [self fetchRequestWhere:predicate sort:sort];
    }
    else {
        fr = [self fetchRequestWhere:condition sort:sort];
    }
    
    return [self performFetchWithRequest:fr];
}

+ (NSFetchedResultsController *)requestAll {
    return [self requestAllSortedBy:nil groupedBy:nil where:nil];
}

+ (NSFetchedResultsController *)requestAllWhere:(id)condition, ... {
    // convert the string and arg list to a predicate (if it's a string with args)
    NSPredicate *predicate = nil;
    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
    }
    
    if (predicate) {
        return [self requestAllSortedBy:nil groupedBy:nil where:predicate];
    }
    return [self requestAllSortedBy:nil groupedBy:nil where:condition];
}

+ (NSFetchedResultsController *)requestAllSortedBy:(NSString*)sort where:(id)condition, ... {
    // convert the string and arg list to a predicate (if it's a string with args)
    NSPredicate *predicate = nil;
    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
    }
    
    if (predicate) {
        return [self requestAllSortedBy:sort groupedBy:nil where:predicate];
    }
    return [self requestAllSortedBy:sort groupedBy:nil where:condition];
}

+ (NSFetchedResultsController *)requestAllSortedBy:(NSString *)sort groupedBy:(NSString*)group where:(id)condition, ... {

    // convert the string and arg list to a predicate (if it's a string with args)
    NSPredicate *predicate = nil;
    if ([condition isKindOfClass:[NSString class]]) {
        va_list args;
        va_start(args, condition);
        predicate = [NSPredicate predicateWithFormat:condition arguments:args];
        va_end(args);
    }
    
    NSFetchRequest *fr = nil;
    if (predicate) {
        fr = [self fetchRequestWhere:predicate sort:sort];
    }
    else {
        fr = [self fetchRequestWhere:condition sort:sort];
    }
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fr managedObjectContext:[Kern sharedContext] sectionNameKeyPath:group cacheName:nil];
}

#pragma mark - Private

+ (NSString*)entityName {
    return NSStringFromClass([self class]);
}

// build a fetch request for the current model with conditions and sorting
+ (NSFetchRequest *)fetchRequestWhere:(id)condition sort:(NSString*)sort {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[self entityName]];
    request.fetchBatchSize = kKernDefaultBatchSize;
    
    request.predicate = [self predicateFromConditional:condition];
    [request setSortDescriptors:[self sortDescriptorsFromString:sort]];

    return request;
}

// expects sort descriptors as a string in the form of:
// @"field0, field1 ASC, field2 asc, field3 desc, field3 DESC"
// "asc" for ascending order (the default if not provided)
// "desc" for descending order

+ (NSArray*)sortDescriptorsFromString:(NSString*)sort {
    
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

// builds a predicate from the condition provided
// either a string, dictionary or predicate object
+ (NSPredicate*)predicateFromConditional:(id)condition {

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

+ (NSArray*)performFetchWithRequest:(NSFetchRequest*)fetchRequest {
    NSError *error = nil;
    NSArray *results = [[Kern sharedContext] executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        [NSException raise:@"Unable to execute fetch request." format:@"Error: %@", error];
    }

    return ([results count] > 0) ? results : nil;
}

@end
