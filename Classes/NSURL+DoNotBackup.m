
#import "NSURL+DoNotBackup.h"

@implementation NSURL (DoNotBackup)

- (BOOL)addSkipBackupAttribute {
  NSError *error = nil;
  BOOL success = [self setResourceValue: [NSNumber numberWithBool: YES]
                                forKey: NSURLIsExcludedFromBackupKey error: &error];
  if(!success){
    NSLog(@"Error excluding %@ from backup %@", [self lastPathComponent], error);
  }
  return success;
}

@end
