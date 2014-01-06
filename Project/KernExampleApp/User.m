//
//  User.m
//  KernExampleApp
//
//  Created by Dustin Steele on 12/26/13.
//  Copyright (c) 2013 Varsity Tutors. All rights reserved.
//

#import "User.h"
#import <Kern.h>


@implementation User

@dynamic remoteID;
@dynamic firstName;
@dynamic lastName;
@dynamic luckyNumber;
@dynamic timeStamp;

+ (NSDictionary*)kern_mappedAttributes {
    return @{@"user": @{
                     @"remoteID": @[@"id",KernDataTypeNumber,KernIsPrimaryKey],
                     @"firstName": @[@"first_name",KernDataTypeString],
                     @"lastName": @[@"last_name",KernDataTypeString],
                     @"luckyNumber": @[@"lucky_number",KernDataTypeNumber],
                     @"timeStamp": @[@"timestamp",KernDataTypeTime] }
             };
}

@end
