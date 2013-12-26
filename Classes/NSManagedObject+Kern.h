//
//  NSManagedObject+Kern.h
//  Kern
//
//  Created by Dustin Steele on 12/23/13.
//  Copyright (c) 2013 Varsity Tutors. All rights reserved.
//

#import <CoreData/CoreData.h>

#define kKernDefaultBatchSize 20

@interface NSManagedObject (Kern)

+ (NSArray *)findAll;
+ (NSArray *)findAllWhere:(id)condition, ...;
+ (NSArray *)findAllSortedBy:(NSString*)sort where:(id)condition, ...;

+ (NSFetchedResultsController *)requestAll;
+ (NSFetchedResultsController *)requestAllWhere:(id)condition, ...;
+ (NSFetchedResultsController *)requestAllSortedBy:(NSString*)sort where:(id)condition, ...;
+ (NSFetchedResultsController *)requestAllSortedBy:(NSString *)sort groupedBy:(NSString*)group where:(id)condition, ...;

@end
