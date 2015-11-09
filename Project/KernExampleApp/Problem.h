//
//  Problem.h
//  
//
//  Created by Nick Morgan on 11/6/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Problem : NSManagedObject

@property (nonatomic, retain) NSNumber *problemID;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *status;

@end


