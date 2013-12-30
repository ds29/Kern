//
//  NSManagedObject+Aggregates.h
//  Kern
//
//  Created by Dustin Steele on 12/30/13.
//  Copyright (c) 2013 Varsity Tutors. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Aggregates)

+ (NSUInteger)countAll;

+ (NSUInteger)countAllWhere:(id)condition, ...;

@end
