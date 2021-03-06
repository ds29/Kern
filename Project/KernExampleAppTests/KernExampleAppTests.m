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

#pragma mark - Test Helpers

+ (void)setUp {
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [Kern setupInMemoryStoreCoreDataStack];
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
    [User truncateAll]; //clear out the user table
    [super tearDown];
}

- (NSMutableDictionary*)baseRemoteDictionary {
    return @{
        @"id": @11,
        @"first_name": @"That",
        @"last_name": @"Guy",
        @"lucky_number": @3,
        @"timestamp": @"1970-01-01T00:00:00Z"
    }.mutableCopy;
}

- (NSMutableDictionary*)baseRemoteDictionaryWithRootEntity {
    return @{@"user": @{
                     @"id": @11,
                     @"first_name": @"That",
                     @"last_name": @"Guy",
                     @"lucky_number": @3,
                     @"timestamp": @"1970-01-01T00:00:00Z"
                     }.mutableCopy
             }.mutableCopy;
}

- (NSMutableDictionary*)baseRemoteDictionaryNested {
    return @{
             @"id": @"11",
             @"name": @{
                 @"first": @"That",
                 @"last": @"Guy",
             },
             @"lucky_number": @3,
             @"timestamp": @"1970-01-01T00:00:00Z"
             }.mutableCopy;
}

- (NSMutableDictionary*)problemDictionary
{
    return @{
             @"problemID": @1,
             @"name": @"Guy",
             @"status": @"N",
             }.mutableCopy;
}

- (NSMutableDictionary*)remoteProblemDictionaryWithRootEntity
{
    return @{@"problem": @{
                     @"id": @1,
                     @"display_name": @"Guy",
                     @"status": @"N",
                     }.mutableCopy
             }.mutableCopy;
}

- (NSMutableDictionary*)remoteProblemDictionary
{
    return  @{
              @"id": @1,
              @"display_name": @"Guy",
              @"status": @"N",
              }.mutableCopy;
}

- (User*)userFromRemoteDictionary {
    return [User updateOrCreateEntityUsingRemoteDictionary:[self baseRemoteDictionary]];
}

- (User*)userFromRemoteDictionaryWithRootEntity {
    return [User updateOrCreateEntityUsingRemoteDictionary:[self baseRemoteDictionaryWithRootEntity]];
}

- (Dude*)dudeFromRemoteDictionaryNested {
    return [Dude updateOrCreateEntityUsingRemoteDictionary:[self baseRemoteDictionaryNested]];
}

- (NSMutableDictionary*)baseUserDictionary {
    return @{
             @"remoteID": @1,
             @"firstName": @"That",
             @"lastName": @"Guy",
             @"luckyNumber": @3,
             @"timeStamp": [NSDate dateWithTimeIntervalSince1970:0]
             }.mutableCopy;
}

- (User*)userFromDictionary {
    return [User createEntity:[self baseUserDictionary]];
}

- (void)addSetOfUsers {
    NSMutableDictionary *userDictionary = [self baseUserDictionary];
    userDictionary[@"remoteID"] = @11;
    userDictionary[@"timeStamp"] = [NSDate dateWithTimeIntervalSince1970:11111];
    [User createEntity:userDictionary];  // create That Guy
    
    userDictionary[@"remoteID"] = @22;
    userDictionary[@"firstName"] = @"This";
    userDictionary[@"timeStamp"] = [NSDate dateWithTimeIntervalSince1970:22222];
    [User createEntity:userDictionary]; // create This Guy
    
    userDictionary[@"remoteID"] = @33;
    userDictionary[@"firstName"] = @"Another";
    userDictionary[@"timeStamp"] = [NSDate dateWithTimeIntervalSince1970:33333];
    [User createEntity:userDictionary]; // create Another Guy
}

#pragma mark - Finders

- (void)testFindAll {
    [self addSetOfUsers]; // add set of users
    
    NSArray *all = [User findAll];
    XCTAssert([all count] == 3, @"Expected a total of 3 entities.");
}

- (void)handleSortByAssertion:(NSArray*)items remoteID:(id)remoteID {
    User *user = [items lastObject];
    XCTAssertEqualObjects(user.remoteID, remoteID);
}

- (void)testFindAllSortedBy {
    [self addSetOfUsers]; // add set of users
    
    // find all using nil sorted by (e.g. kinda dumb, but it should work if you really want to do it)
    NSArray *all = [User findAllSortedBy:nil];
    
    XCTAssert([all count] == 3, @"Expected a total of 3 entities.");

    // find all sorted by timeStamp in ascending order (using a simple string)
    [self handleSortByAssertion:[User findAllSortedBy:@"timeStamp"] remoteID:@33]; //Another Guy
    
    // find all sorted by timeStamp in descending order (using a simple string)
    [self handleSortByAssertion:[User findAllSortedBy:@"timeStamp desc"] remoteID:@11]; //That Guy

    // find all sorted by timeStamp in ascending order (using a dictionary)
    [self handleSortByAssertion:[User findAllSortedBy:@{@"timeStamp": @"asc"}] remoteID:@33]; //Another Guy

    // find all sorted by timeStamp in descending order (using a dictionary)
    [self handleSortByAssertion:[User findAllSortedBy:@{@"timeStamp": @"desc"}] remoteID:@11]; //That Guy

    // find all sorted by lastName, then firstName descending (using a string)
    [self handleSortByAssertion:[User findAllSortedBy:@"lastName, firstName"] remoteID:@22]; //This Guy

    // find all sorted by lastName, then firstName descending (using a string)
    [self handleSortByAssertion:[User findAllSortedBy:@"lastName, firstName desc"] remoteID:@33]; //Another Guy

    // find all sorted by lastName, then firstName descending (using an array of dictionary params)
    [self handleSortByAssertion:[User findAllSortedBy:@[@{@"lastName": @"asc"}, @{@"firstName": @"desc"}]] remoteID:@33]; //Another Guy

    // find all sorted by timeStamp in descending order (using regular old NSSortDescriptor)
    [self handleSortByAssertion:[User findAllSortedBy:[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO]] remoteID:@11]; //That Guy

    // find all sorted by lastName, then firstName descending (using array of NSSortDescriptor)
    NSArray *descriptors = [NSArray arrayWithObjects:
                            [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES],
                            [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:NO],
                            nil];
    [self handleSortByAssertion:[User findAllSortedBy:descriptors] remoteID:@33]; //Another Guy
}

- (void)testFindAllWhere {
    [self addSetOfUsers]; // add set of users
    
    // find all using nil condition
    NSArray *all = [User findAllWhere:nil];
    XCTAssert([all count] == 3, @"Expected a total of 3 entities.");

    // find all using a simple string condition
    all = [User findAllWhere:@"lastName ==[cd] 'guy'"];
    XCTAssert([all count] == 3, @"Expected a total of 3 entities.");

    // find all using a predicate
    all = [User findAllWhere:[NSPredicate predicateWithFormat:@"lastName ==[cd] %@", @"guy"]];
    XCTAssert([all count] == 3, @"Expected a total of 3 entities.");

    // find all using a simple dictionary
    all = [User findAllWhere:@{@"lastName": @"Guy"}];
    XCTAssert([all count] == 3, @"Expected a total of 3 entities.");

    // find all using a complex dictionary
    all = [User findAllWhere:@{@"lastName": @"Guy", @"luckyNumber": @3, @"firstName": @"That"}];
    XCTAssert([all count] == 1, @"Expected one entity.");

    // find all using a complex string
    all = [User findAllWhere:@"lastName ==[cd] %@ AND luckyNumber == %@ AND firstName == %@", @"guy", @3, @"That"];
    XCTAssert([all count] == 1, @"Expected one entity.");

    // find all using a complex string (with an OR)
    all = [User findAllWhere:@"lastName ==[cd] %@ AND luckyNumber == %@ OR firstName == %@", @"guy", @3, @"That"];
    XCTAssert([all count] == 3, @"Expected a total of 3 entities.");
}

- (void)testFindAllSortedByWithLimitWhere {
    [self addSetOfUsers]; // add set of users
    
    NSArray *all = [User findAllSortedBy:@"lastName,firstName" withLimit:1 where:@"luckyNumber == %@", @3];
    [self handleSortByAssertion:all remoteID:@33]; // should find only Another Guy (33)
}

- (void)testFindAllSortedByWhere {
    [self addSetOfUsers]; // add set of users
    
    NSArray *all = [User findAllSortedBy:@"lastName,firstName" where:@"firstName == %@", @"Another"];
    [self handleSortByAssertion:all remoteID:@33]; // should find only Another Guy (33)
}

- (void)testFindAllSortedByWithLimit {
    [self addSetOfUsers]; // add set of users
    
    NSArray *all = [User findAllSortedBy:@"lastName,firstName" withLimit:1];
    [self handleSortByAssertion:all remoteID:@33]; // should find only Another Guy (33)
}

- (void)testFindAllWithLimitWhere {
    [self addSetOfUsers]; // add set of users
    
    NSArray *all = [User findAllWithLimit:1 where:@"firstName == %@", @"Another"];
    [self handleSortByAssertion:all remoteID:@33]; // should find only Another Guy (33)
}

#pragma mark - Fetching

- (void)testFetchAllSortedBy {
    [self addSetOfUsers]; // add set of users
    
    NSFetchedResultsController *frc = [User fetchAllSortedBy:@"lastName"];
    [frc performFetch:nil];

    XCTAssert([[frc fetchedObjects] count] == 3, @"Expected a total of 3 entities.");
}

- (void)testFetchAllSortedByGroupedBy {
    [self addSetOfUsers]; // add set of users
    
    NSFetchedResultsController *frc = [User fetchAllSortedBy:@"lastName, firstName" groupedBy:@"lastName"];
    [frc performFetch:nil];
    
    XCTAssert([[frc sections] count], @"Expected one section.");
    XCTAssert([[frc fetchedObjects] count] == 3, @"Expected a total of 3 entities.");
}

- (void)testFetchAllSortedByGroupedByWhere {
    [self addSetOfUsers]; // add set of users
    
    NSFetchedResultsController *frc = [User fetchAllSortedBy:@"lastName, firstName" groupedBy:@"lastName" where:@"luckyNumber == %@", @3];
    [frc performFetch:nil];
    
    XCTAssert([[frc sections] count], @"Expected one section.");
    XCTAssert([[frc fetchedObjects] count] == 3, @"Expected a total of 3 entities.");
}

- (void)testFetchAllSortedByGroupedByWithLimit {
    [self addSetOfUsers]; // add set of users
    
    NSFetchedResultsController *frc = [User fetchAllSortedBy:@"lastName, firstName" groupedBy:@"lastName" withLimit:1];
    [frc performFetch:nil];
    
    XCTAssert([[frc sections] count], @"Expected one section.");
    XCTAssert([[frc fetchedObjects] count] == 1, @"Expected one entity.");
    [self handleSortByAssertion:[frc fetchedObjects] remoteID:@33]; // should find only Another Guy (33)
}

- (void)testFetchAllSortedByGroupedByWithLimitWhere {
    [self addSetOfUsers]; // add set of users
    
    NSFetchedResultsController *frc = [User fetchAllSortedBy:@"lastName, firstName" groupedBy:@"lastName" withLimit:1 where:@"luckyNumber == %@", @3];
    [frc performFetch:nil];
    
    XCTAssert([[frc sections] count], @"Expected one section.");
    XCTAssert([[frc fetchedObjects] count] == 1, @"Expected one entity.");
    [self handleSortByAssertion:[frc fetchedObjects] remoteID:@33]; // should find only Another Guy (33)
}

- (void)testFetchAllSortedByWhere {
    [self addSetOfUsers]; // add set of users
    
    NSFetchedResultsController *frc = [User fetchAllSortedBy:@"lastName, firstName" where:@"firstName == %@", @"Another"];
    [frc performFetch:nil];
    
    XCTAssert([[frc fetchedObjects] count] == 1, @"Expected one entity.");
    [self handleSortByAssertion:[frc fetchedObjects] remoteID:@33]; // should find only Another Guy (33)
}

- (void)testFetchAllSortedByWithLimit {
    [self addSetOfUsers]; // add set of users
    
    NSFetchedResultsController *frc = [User fetchAllSortedBy:@"lastName, firstName" withLimit:1];
    [frc performFetch:nil];
    
    XCTAssert([[frc fetchedObjects] count] == 1, @"Expected one entity.");
    [self handleSortByAssertion:[frc fetchedObjects] remoteID:@33]; // should find only Another Guy (33)
}


- (void)testFetchAllSortedByWithLimitWhere {
    [self addSetOfUsers]; // add set of users
    
    NSFetchedResultsController *frc = [User fetchAllSortedBy:@"lastName, firstName" withLimit:1 where:@"luckyNumber == %@", @3];
    [frc performFetch:nil];
    
    XCTAssert([[frc fetchedObjects] count] == 1, @"Expected one entity.");
    [self handleSortByAssertion:[frc fetchedObjects] remoteID:@33]; // should find only Another Guy (33)
}

#pragma mark - Modifiers

- (void)testCreateEntity {
    [User createEntity];
    XCTAssert([User countAll] == 1, @"Expected one entity.");
}

- (void)testCreateEntityWithDictionary {
    User *u = [User createEntity:[self baseUserDictionary]];
    
    XCTAssert([User countAll] == 1, @"Expected one entity.");
    XCTAssertEqualObjects(u.remoteID, @1, @"remoteID must be same as dictionary value.");
}

- (void)testTruncateAll {
    [self addSetOfUsers]; // add set of users
    XCTAssert([User countAll] == 3, @"Expected total of 3 entities.");

    [User truncateAll];
    XCTAssert([User countAll] == 0, @"Expected total to be zero since we removed all entities.");
}

- (void)testDeleteEntity {
    User *u = [User createEntity];
    XCTAssert([User countAll] == 1, @"Expected one entity.");

    [u deleteEntity];
    XCTAssert([User countAll] == 0, @"Expected total to be zero since we removed the entity.");
}

- (void)testDeleteAllWhere {
    [self addSetOfUsers]; // add set of users
    XCTAssert([User countAll] == 3, @"Expected total of 3 entities.");

    [User deleteAllWhere:@"firstName == %@", @"Another"];
    XCTAssert([User countAll] == 2, @"Expected total of 2 entities after deleting one entity.");
}

- (void)testUpdateEntity {
    User *u = [User createEntity:[self baseUserDictionary]];
    XCTAssertEqualObjects(u.timeStamp, [NSDate dateWithTimeIntervalSince1970:0], @"Expected timeStamp to be epoch date.");
    
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:1000];
    [u updateEntity:@{@"timeStamp": updateDate}];
    XCTAssertEqualObjects(u.timeStamp, updateDate, @"Expected timeStamp to be same as updated date.");
}

- (void)testSaveEntity {
    User *u = [User createEntity:[self baseUserDictionary]];
    XCTAssert([u saveEntity] == YES, @"Expect saveEntity to return true when saving a record.");
}

#pragma mark - Aggregates

- (void)testEntityCountAll {
    [self userFromDictionary]; //create an entity
    
    NSUInteger total = [User countAll];
    XCTAssert(total == 1, @"Must have a count of one after creating an entity.");
}

- (void)testEntityCountWhere {
    [self userFromDictionary]; //create an entity
    
    NSUInteger total = [User countAllWhere:@"lastName ==[cd] %@", @"guy"];
    
    XCTAssert(total == 1, @"Must have a count of one after creating an entity with a matching lastName.");
}

#pragma mark - Data Mapping

- (void)testHandlesStringBasedNumbers {
    NSMutableDictionary *userDictionary = [self baseRemoteDictionary];
    userDictionary[@"lucky_number"] = @"1.5";
    
    User *u = [User updateOrCreateEntityUsingRemoteDictionary:userDictionary];
    XCTAssertEqual([u.luckyNumber integerValue], [[NSNumber numberWithFloat:1.5] integerValue]);
}

- (void)testCreatesAnEntityWithRemoteDictionary {

    User *u = [self userFromRemoteDictionary];

    XCTAssertEqualObjects(u.remoteID, @11, @"remoteID must match supplied value in JSON");
    XCTAssertEqualObjects(u.firstName, @"That", @"firstName must match supplied value in JSON");
    XCTAssertEqualObjects(u.lastName, @"Guy", @"lastName must match supplied value in JSON");
    XCTAssertEqualObjects(u.luckyNumber, @3, @"luckyNumber must match supplied value in JSON");
    XCTAssertEqualObjects(u.timeStamp, [NSDate dateWithTimeIntervalSince1970:0], @"timeStamp must match supplied value in JSON");
}

- (void)testCreatesAnEntityWithRemoteDictionaryWithRootEntity {
    
    User *u = [self userFromRemoteDictionaryWithRootEntity];
    
    XCTAssertEqualObjects(u.remoteID, @11, @"remoteID must match supplied value in JSON");
    XCTAssertEqualObjects(u.firstName, @"That", @"firstName must match supplied value in JSON");
    XCTAssertEqualObjects(u.lastName, @"Guy", @"lastName must match supplied value in JSON");
    XCTAssertEqualObjects(u.luckyNumber, @3, @"luckyNumber must match supplied value in JSON");
    XCTAssertEqualObjects(u.timeStamp, [NSDate dateWithTimeIntervalSince1970:0], @"timeStamp must match supplied value in JSON");
}

- (void)testCreatesAnEntityWithRemoteDictionaryNested {
    
    Dude *u = [self dudeFromRemoteDictionaryNested];
    
    XCTAssertEqualObjects(u.remoteID, @11, @"remoteID must match supplied value in JSON, even if provided as string");
    XCTAssertEqualObjects(u.firstName, @"That", @"name/first must match supplied value in JSON");
    XCTAssertEqualObjects(u.lastName, @"Guy", @"name/last must match supplied value in JSON");
    XCTAssertEqualObjects(u.luckyNumber, @3, @"luckyNumber must match supplied value in JSON");
    XCTAssertEqualObjects(u.timeStamp, [NSDate dateWithTimeIntervalSince1970:0], @"timeStamp must match supplied value in JSON");
}

- (void)testCreatesAnEntityWithRemoteDictionaryNestedNull {
    
    NSMutableDictionary *json = [self baseRemoteDictionaryNested];
    json[@"name"] = [NSNull null];
    
    Dude *aDude = [Dude updateOrCreateEntityUsingRemoteDictionary:json];
    
    XCTAssertNil(aDude.firstName, @"firstName must be NULL");
    XCTAssertNil(aDude.lastName, @"lastName must be NULL");
}

- (void)testUpdatesAnExistingEntityWithRemoteDictionaryNestedNull {
    
    Dude *dudeOne = [self dudeFromRemoteDictionaryNested];
    
    NSMutableDictionary *json = [self baseRemoteDictionaryNested];
    json[@"name"] = [NSNull null];
    
    [Dude updateOrCreateEntityUsingRemoteDictionary:json];
    
    XCTAssertNil(dudeOne.firstName, @"firstName must be NULL");
    XCTAssertNil(dudeOne.lastName, @"lastName must be NULL");
}

- (void)testUpdatesAnExistingEntityWithRemoteDictionary {
    User *u1 = [self userFromRemoteDictionary];
    
    NSString *firstName = @"Other";
    NSMutableDictionary *json = [self baseRemoteDictionary];
    json[@"first_name"] = firstName;
    
    User *u2 = [User updateOrCreateEntityUsingRemoteDictionary:json];
    
    XCTAssertEqualObjects(u2.firstName, firstName, @"firstName must match newly supplied value in JSON");
    XCTAssertEqualObjects(u1.remoteID, u2.remoteID, @"remoteID must match original value");
    XCTAssertEqualObjects(u1.lastName, u2.lastName, @"lastName must match original value");
    XCTAssertEqualObjects(u1.luckyNumber, u2.luckyNumber, @"luckyNumber must match original value");
    XCTAssertEqualObjects(u1.timeStamp, u2.timeStamp, @"timeStamp must match original value");
}

- (void)testUpdatesAnExistingEntityWithRemoteDictionaryWithRootEntity {
    User *u1 = [self userFromRemoteDictionaryWithRootEntity];
    
    NSString *firstName = @"Other";
    NSMutableDictionary *json = [self baseRemoteDictionaryWithRootEntity];
    json[@"user"][@"first_name"] = firstName;
    
    User *u2 = [User updateOrCreateEntityUsingRemoteDictionary:json];
    
    XCTAssertEqualObjects(u2.firstName, firstName, @"firstName must match newly supplied value in JSON");
    XCTAssertEqualObjects(u1.remoteID, u2.remoteID, @"remoteID must match original value");
    XCTAssertEqualObjects(u1.lastName, u2.lastName, @"lastName must match original value");
    XCTAssertEqualObjects(u1.luckyNumber, u2.luckyNumber, @"luckyNumber must match original value");
    XCTAssertEqualObjects(u1.timeStamp, u2.timeStamp, @"timeStamp must match original value");
}

- (void)testUpdatesAnExistingEntityWithNilWithRemoteDictionary {
    User *u1 = [self userFromRemoteDictionary];
    
    XCTAssertEqualObjects(u1.firstName, @"That", @"firstName must supplied value in JSON");
    
    NSMutableDictionary *json = [self baseRemoteDictionary];
    json[@"first_name"] = [NSNull null];
    json[@"lucky_number"] = [NSNull null];

    User *u2 = [User updateOrCreateEntityUsingRemoteDictionary:json];
    
    XCTAssertEqualObjects(u2.firstName, nil, @"firstName must be nil");
    XCTAssertEqualObjects(u2.luckyNumber, @0, @"luckyNumber must have a default value of 0");
}


// Can we create problems, then update some of them using a dictionary WITH a root entity.
- (void)testProcessCollectionOfEntitiesWithRemoteDictionaryContainingRootEntity
{
    NSInteger addedCount = 5;
    NSMutableDictionary *base = [self problemDictionary];
    for (int i = 1; i <= addedCount; i++) {
        base[@"problemID"] = @(i);
        base[@"name"] = [NSString stringWithFormat:@"Guy%@", @(i)];
        [Problem createEntity:base];
    }
    
    NSUInteger total = [Problem countAllWhere:@"name CONTAINS [cd] %@", @"guy"];
    XCTAssert(total == addedCount, @"Must have a count of %@ after creating records.", @(addedCount));
    
    // New record
    NSMutableDictionary *remoteOne = [self remoteProblemDictionaryWithRootEntity];
    remoteOne[@"problem"][@"id"] = @(10);
    remoteOne[@"problem"][@"display_name"] = @"Guy10";
    
    // Updated record
    NSMutableDictionary *remoteTwo = [self remoteProblemDictionaryWithRootEntity];
    remoteTwo[@"problem"][@"id"] = @(1);
    remoteTwo[@"problem"][@"display_name"] = @"That Guy";
    remoteTwo[@"problem"][@"status"] = @"U";

    // Deleted record
    NSMutableDictionary *remoteThree = [self remoteProblemDictionaryWithRootEntity];
    remoteThree[@"problem"][@"id"] = @(2);
    remoteThree[@"problem"][@"display_name"] = @"Guy2";
    remoteThree[@"problem"][@"status"] = @"D";
    
    [Problem processCollectionOfEntitiesAccordingToStatusIndicator:@[remoteOne, remoteTwo, remoteThree]];
    
    total = [Problem countAllWhere:@"name CONTAINS [cd] %@", @"guy"];
    NSUInteger subTotalOne = [Problem countAllWhere:@"name == [cd] %@", @"guy10"];
    NSUInteger subTotalTwo = [Problem countAllWhere:@"name == [cd] %@", @"that guy"];
    NSUInteger subTotalThree = [Problem countAllWhere:@"name == [cd] %@", @"guy2"];

    XCTAssert(total == addedCount, @"Must have a count of %@ after processing the remote dictionary.", @(addedCount));
    XCTAssert(subTotalOne == 1, @"Must have 1 record named Guy10 after processing the remote dictionary.");
    XCTAssert(subTotalTwo == 1, @"Must have 1 record named That guy after processing the remote dictionary.");
    XCTAssert(subTotalThree == 0, @"Must have 0 records named Guy2 after processing the remote dictionary.");
}

// Can we create problems, then update some of them using a dictionary WITHOUT a root entity.
- (void)testProcessCollectionOfEntitiesWithRemoteDictionary
{
    NSInteger addedCount = 5;
    NSMutableDictionary *base = [self problemDictionary];
    for (int i = 101; i <= 100 + addedCount; i++) {
        base[@"problemID"] = @(i);
        base[@"name"] = [NSString stringWithFormat:@"Girl%@", @(i)];
        [Problem createEntity:base];
    }
    
    NSUInteger total = [Problem countAllWhere:@"name CONTAINS [cd] %@", @"girl"];
    XCTAssert(total == addedCount, @"Must have a count of %@ after creating records.", @(addedCount));
    
    // New record
    NSMutableDictionary *remoteOne = [self remoteProblemDictionary];
    remoteOne[@"id"] = @(200);
    remoteOne[@"display_name"] = @"Girl200";
    
    // Updated record
    NSMutableDictionary *remoteTwo = [self remoteProblemDictionary];
    remoteTwo[@"id"] = @(101);
    remoteTwo[@"display_name"] = @"That Girl";
    remoteTwo[@"status"] = @"U";
    
    // Deleted record
    NSMutableDictionary *remoteThree = [self remoteProblemDictionary];
    remoteThree[@"id"] = @(102);
    remoteThree[@"display_name"] = @"Girl102";
    remoteThree[@"status"] = @"D";
    
    [Problem processCollectionOfEntitiesAccordingToStatusIndicator:@[remoteOne, remoteTwo, remoteThree]];
    
    total = [Problem countAllWhere:@"name CONTAINS [cd] %@", @"girl"];
    NSUInteger subTotalOne = [Problem countAllWhere:@"name == [cd] %@", @"girl200"];
    NSUInteger subTotalTwo = [Problem countAllWhere:@"name == [cd] %@", @"that girl"];
    NSUInteger subTotalThree = [Problem countAllWhere:@"name == [cd] %@", @"girl102"];

    XCTAssert(total == addedCount, @"Must have a count of %@ after processing the remote dictionary.", @(addedCount));
    XCTAssert(subTotalOne == 1, @"Must have 1 record named Girl200 after processing the remote dictionary.");
    XCTAssert(subTotalTwo == 1, @"Must have 1 record named That Girl after processing the remote dictionary.");
    XCTAssert(subTotalThree == 0, @"Must have 0 records named Girl102 after processing the remote dictionary.");
}

@end
