//
//  KernExampleAppTests.m
//  KernExampleAppTests
//
//  Created by Dustin Steele on 12/26/13.
//  Copyright (c) 2013 Varsity Tutors. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreData/CoreData.h>
#import <Kern.h>

@interface KernExampleAppTests : XCTestCase

@end

@implementation KernExampleAppTests

+ (void)setUp {
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [Kern setupInMemoryStoreCoreDataStack];
    [User truncateAll];
}

+ (void)tearDown {
    [Kern cleanUp];
}

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testCreatesAnEntityWithRemoteDictionary {

    NSDictionary *json = @{@"user": @{
                                   @"first_name": @"Test",
                                   @"last_name": @"Guy",
                                   @"lucky_number": [NSNumber numberWithInt:1],
                                   @"timestamp": @"1970-01-01T00:00:00Z" // so we can use "since1970"
                                   }
                           };
    
    User *u = [User updateOrCreateEntityUsingRemoteDictionary:json];

    XCTAssertEqualObjects(u.firstName, @"Test", @"firstName must match supplied value in JSON");
    XCTAssertEqualObjects(u.lastName, @"Guy", @"lastName must match supplied value in JSON");
    XCTAssertEqualObjects(u.luckyNumber, @1, @"luckyNumber must match supplied value in JSON");
    XCTAssertEqualObjects(u.timeStamp, [NSDate dateWithTimeIntervalSince1970:0], @"timeStamp must match supplied value in JSON");
}

@end
