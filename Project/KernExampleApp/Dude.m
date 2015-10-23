//
//  Dude.m
//  KernExampleApp
//
//  Created by Dustin Steele on 12/26/13.
//  Copyright (c) 2013 Varsity Tutors. All rights reserved.
//

#import "Dude.h"
#import <Kern.h>


@implementation Dude

@dynamic remoteID;
@dynamic firstName;
@dynamic lastName;
@dynamic luckyNumber;
@dynamic timeStamp;

+ (NSDictionary*)kern_mappedAttributes {
    return @{@"dude": @{
                     @"remoteID": @[@"id",KernDataTypeNumber,KernIsPrimaryKey],
                     @"name": @{
                         @"firstName": @[@"first",KernDataTypeString],
                         @"lastName": @[@"last",KernDataTypeString],
                     },
                     @"luckyNumber": @[@"lucky_number",KernDataTypeNumber],
                     @"timeStamp": @[@"timestamp",KernDataTypeTime] }
             };
}

@end
