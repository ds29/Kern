//
//  NSManagedObject+Modifiers.h
//  Kern
//
//  Created by Dustin Steele on 12/30/13.
//  Copyright (c) 2013 Varsity Tutors. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Modifiers)

+ (instancetype)createEntity;

+ (instancetype)createEntity:(NSDictionary*)aDictionary;

+ (BOOL)truncateAll;

- (void)deleteEntity;

+ (BOOL)deleteAllWhere:(id)condition, ...;

- (void)updateEntity:(NSDictionary*)aDictionary;

- (BOOL)saveEntity;


@end
