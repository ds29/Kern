//
//  Problem.m
//  
//
//  Created by Nick Morgan on 11/6/15.
//
//

#import "Problem.h"
#import <Kern.h>

@implementation Problem

@dynamic problemID;
@dynamic name;
@dynamic status;

+ (NSDictionary*)kern_mappedAttributes {
    return @{@"problem": @{
                     @"problemID": @[@"id", KernDataTypeNumber, KernIsPrimaryKey],
                     @"name": @[@"display_name", KernDataTypeString],
                     @"status": @[@"status", KernDataTypeString] }
             };
}

@end
