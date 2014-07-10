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

#### Importing Data

```obj-c

	// TODO: Describe the process here.  (For now, you can look at the headers, example app, and tests.)

```

## Requirements

It requires ARC and iOS 7+.  It's only for iOS.  *Ok, it may run on older/other OS requirements, but that's all it's built/tested against.*

## Installation

Kern is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "Kern"

## Author

Dustin Steele

## License

Kern is available under the MIT license. See the LICENSE file for more info.

