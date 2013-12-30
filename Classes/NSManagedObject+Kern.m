//
//  NSManagedObject+Kern.m
//  Kern
//
//  Created by Dustin Steele on 12/23/13.
//  Copyright (c) 2013 Varsity Tutors. All rights reserved.
//

#import "NSManagedObject+Kern.h"

@implementation NSManagedObject (Kern)

+ (NSString*)kern_entityName {
    return NSStringFromClass([self class]);
}

@end
