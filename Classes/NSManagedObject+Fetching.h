//
//  NSManagedObject+Fetching.h
//  Kern
//
//  Created by Dustin Steele on 12/30/13.
//  Copyright (c) 2013 Varsity Tutors. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NSManagedObject+Kern.h"

@interface NSManagedObject (Fetching)

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

@end
