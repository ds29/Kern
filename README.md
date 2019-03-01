# Kern

A simple Core Data manager with easy setup and fetching. Kern enables a simple context with easy-to-use fetching methods.  It's far less feature-rich than the more awesome libraries like [MagicalRecord](https://github.com/MagicalPanda/MagicalRecord) and [ObjectiveRecord](https://github.com/mneorr/ObjectiveRecord).  It serves a very simple purpose, to store and fetch data in one context (with background processing).

It borrows heavily from the work of the projects above but strips it down to a bare minimum for its intended purpose.  I don't make any claim to its originality (call it a mashup).

The one *original* concept/implementation included is the data mapping.  It allows a given `NSManagedObjectModel` to specify a set of mapped attributes (with data types) and then use those attributes to easily save changes.

## Usage

#### Setup the stack

```obj-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Setup Kern
	[Kern setupAutoMigratingCoreDataStack];

	return YES;
}
```

#### Create some records

```obj-c
User *jimmy = [User createEntity]; //create an empty entity
jimmy.firstName = @"Jimmy";
jimmy.lastName = @"James";
jimmy.luckyNumber = @3;

User *doogie = [User createEntity:@{@"firstName": @"Doogie", @"lastName": @"Howser", @"luckyNumber": @7}];

User *george = [User createEntity:@{"firstName": @"George", @"lastName": @"Bluth", @"luckyNumber": @13}];

User *michael = [User createEntity:@{"firstName": @"Michael", @"lastName": @"Bluth", @"luckyNumber": @13}];

User *georgeMichael = [User createEntity:@{"firstName": @"George Michael", @"lastName": @"Bluth", @"luckyNumber": @9}];

User *buster = [User createEntity:@{"firstName": @"Buster", @"lastName": @"Bluth"}];  // not lucky

User *oscar = [User createEntity:@{"firstName": @"Oscar", @"lastName": @"Bluth"}];  // not lucky
```

#### Save the records

```obj-c
[Kern saveContext]; // save the whole context

User *ron = [User createEntity:@{"firstName": @"Ron", @"lastName": @"Swanson", @"luckyNumber": @11}];
[ron saveEntity]; // save a single instance
```

#### Finding and sorting records

Easy and powerful find/sort options.

```obj-c
NSArray *all = [User findAll]; // um, all the records

// find and sort by luckyNumber
NSArray *sorted = [User findAllSortedBy:@"luckyNumber"]; // ascending sort if not specified

// find and sort by luckyNumber (dictionary form)
sorted = [User findAllSortedBy:@{@"luckyNumber": @"asc"}];

// find and sort by luckyNumber (plain old NSSortDescriptor)
sorted = [User findAllSortedBy:[NSSortDescriptor sortDescriptorWithKey:@"luckyNumber" ascending:YES]];

// sort by lastName descending, luckyNumber ascending
sorted = [User findAllSortedBy:@"lastName desc,luckyNumber"];

// sort by lastName descending, luckyNumber ascending (dictionary form)
sorted = [User findAllSortedBy:@[@{@"lastName": "DESC"}, @{@"luckyNumber": @"ASC"}]];

// sort by lastName descending, luckyNumber ascending (sort descriptors)
NSArray *descriptors = [NSArray arrayWithObjects:
	[NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:NO],
	[NSSortDescriptor sortDescriptorWithKey:@"luckyNumber" ascending:YES],
	nil];
sorted = [User findAllSortedBy:descriptors];

// limiting
NSArray *top3Luckiest = [User findAllSortedBy:@"luckyNumber desc" withLimit:3];

// conditionals (where)
// find all the bluth's
NSArray *allBluths = [User findAllWhere:@"lastName ==[cd] 'bluth'")];

// find all the bluths
allBluths = [User findAllWhere:@"lastName ==[cd] %@", @"bluth"];

// find all the bluths with a luckyNumber of 13
allBluths = [User findAllWhere:@"lastName ==[cd] %@ AND luckyNumber == %@", @"bluth", @13];

// find all the bluths with a luckyNumber of 13 (dictionary form)
allBluths = [User findAllWhere:@{@"lastName": @"Bluth", @"luckyNumber": @13}];

// find all the bluths with a luckyNumber of 13 (plain old NSPredicate)
allBluths = [User findAllWhere:[NSPredicate predicateWithFormat:@"lastName ==[cd] %@ AND luckyNumber == %@", @"bluth", @13]];

// find, sort, and limit
// find all sorted by luckyNumber, limited to top 2, where lastName is bluth
NSArray *topTwoBluths = [User findAllSortedBy:@"luckyNumber desc" withLimit:2 where:@"lastName ==[cd] %@", @"bluth"]];

// fetching with NSFetchedResultsController
// fetch all sorted by lastName, luckyNumber DESC and grouped by lastName
NSFetchedResultsController *frc = [User fetchAllSortedBy:@"lastName, luckyNumber DESC" groupedBy:@"lastName" where:@"lastName NOT IN %@", @[@"Howser", @"James"]];
frc.delegate = self; // if you want to control the delegate
NSError *error = nil;
	[frc performFetch:&error]; // perform the fetch
	if (error) {
		NSLog(@"Uh oh.");
	}

// See the included tests for more details
// See the headers for other fetching variants
```

#### Data Mapping

One of the best features of Kern is the ability to do data mapping. We can easily import data from an NSDictionary (typically sourced from JSON) and store the result with by using predefined data map.

For example, our User model implementation looks like this:
```obj-c
# User.h
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * luckyNumber;
@property (nonatomic, retain) NSDate * timeStamp;

# User.m
#import "User.h"
#import <Kern.h>

@implementation User

@dynamic remoteID;
@dynamic firstName;
@dynamic lastName;
@dynamic luckyNumber;
@dynamic timeStamp;

+ (NSDictionary*)kern_mappedAttributes {
	return @{
		@"remoteID": @[@"id",KernDataTypeNumber,KernIsPrimaryKey],
		@"firstName": @[@"first_name",KernDataTypeString],
		@"lastName": @[@"last_name",KernDataTypeString],
		@"luckyNumber": @[@"lucky_number",KernDataTypeNumber],
		@"timeStamp": @[@"timestamp",KernDataTypeTime]
	};
}
@end
```
The data mapping methods call into the `kern_mappedAttributes` to determine how to map input data to the Core Data model.

Attributes are mapped using a key value pair of attribute name and the mapping array. The mapping array expects at least 2 elements: the JSON attribute name as string and the Kern data type value. If the attribute is the primary key, the third array element should specify. Each model should have a primary key.

In the above example, we mapped the `remoteID` attribute of our Core Data model to the expected JSON attribute of `id` which is a `KernDataTypeNumber` and is the primary key (`KernIsPrimaryKey`).

To illustrate, we'll continue on with the simplified example but rest assured that Kern is capable of mapping more complex relationships. Using `KernDataTypeRelationshipBlock`, you are able to define associations between models (see the lib for more).

By way of demonstration, let's assume we've made an API call to get a user which returns the JSON below:

```
GET /users/99
```
```json
{
	"id": 99,
	"first_name": "Gob",
	"last_name": "Bluth",
	"lucky_number": 21,
	"timestamp": "1970-01-01T00:00:00Z"
}
```

We can then parse this data and call our data mapping method to update or create
the user. `updateOrCreateEntityUsingRemoteDictionary` takes in the dictionary and
uses the data mapping defined in `kern_mappedAttributes`. If a record with the
primary key already exists, it will find the record and update it. If it does not
yet exist, it will be created. In either scenario, all of the attributes are
automatically mapped and assigned for you reducing a lot of data type checking.

```obj-c
// Assume we've made the above API call and stored a resulting NSData object as data
NSError *jsonError;
NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

if (jsonError) {
	// handle error
} else {
	/*
	// parsed json into NSDictionary:
	@{
	  @"id": @99,
	  @"first_name": @"Gob",
	  @"last_name": @"Bluth",
	  @"lucky_number": @21,
	  @"timestamp": @"1970-01-01T00:00:00Z"
	}
	*/
	// Import data into Core Data model with a simple call
	User *gob = [User updateOrCreateEntityUsingRemoteDictionary:json];
	[gob saveEntity];
}
```

Kern also provides `updateOrCreateEntitiesUsingRemoteArray` to accomplish batch processing. Other method signatures allow you to provide a block which is performed on the object after it has been updated. This provides flexibility to perform additional operations when necessary (perhaps to set an associated object).

The example project provided (`KernExampleApp`) contains a working example of data mapping, build and run the example to see it in action.

## Installation

Kern is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "Kern"

## Author

Dustin Steele

## License

Kern is available under the MIT license. See the LICENSE file for more info.
