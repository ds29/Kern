//
//  Kern.h
//  Kern
//
//    Copyright (c) 2013 Dustin Steele
//
//    Kern is licensed under MIT license (as-is) provided that proper
//    attribution is given to the ORIGINAL authors of the collective works.
//
//    Much of Kern is adapted from MagicalRecord, ObjectiveRecord and SSToolKit.
//    Accordingly, appropriate attribution is provided herein:
//
//    MagicalRecord:
//    Copyright (c) 2010, Magical Panda Software, LLC
//
//    ObjectiveRecord:
//    Copyright © 2012 Marin Usalj, http://mneorr.com
//
//    SSToolkit:
//    Copyright (c) 2008-2013 Sam Soffes
//
//    The above works were provided under the MIT license. For brevity,
//    the license is provided here and applies to all of the above works.
//
//    Permission is hereby granted, free of charge, to any person
//    obtaining a copy of this software and associated documentation
//    files (the "Software"), to deal in the Software without
//    restriction, including without limitation the rights to use,
//    copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the
//    Software is furnished to do so, subject to the following
//    conditions:
//
//    The above copyright notice and this permission notice shall be
//    included in all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//    OTHER DEALINGS IN THE SOFTWARE.


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Kern.h"
#import "NSString+Kern.h"

extern NSString * const kKernDefaultStoreFileName;
#define kKernDefaultBatchSize 20

@interface Kern : NSObject

+ (NSManagedObjectModel*)sharedModel;
+ (NSManagedObjectContext*)sharedContext;
+ (NSManagedObjectContext*)sharedThreadedContext;
+ (NSURL*)storeURL;

+ (void)setupAutoMigratingCoreDataStackWithDoNotBackupAttribute;
+ (void)setupAutoMigratingCoreDataStack;
+ (void)setupInMemoryStoreCoreDataStack;
+ (void)cleanUp;

+ (BOOL)saveContext;

+ (NSFetchRequest*)kern_fetchRequestForEntityName:(NSString*)entityName condition:(id)condition sort:(id)sort limit:(NSUInteger)limit;
+ (NSUInteger)kern_countForFetchRequest:(NSFetchRequest*)fetchRequest;
+ (NSArray*)kern_executeFetchRequest:(NSFetchRequest*)fetchRequest;

@end
