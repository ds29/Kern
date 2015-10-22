//
//  Dude.h
//  KernExampleApp
//
//  Created by Dustin Steele on 12/26/13.
//  Copyright (c) 2013 Varsity Tutors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Dude : NSManagedObject

@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * luckyNumber;
@property (nonatomic, retain) NSDate * timeStamp;




@end
