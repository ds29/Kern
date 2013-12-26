//
//  NSString+Kern.h
//  Kern
//
//  Created by Dustin Steele on 12/23/13.
//  Copyright (c) 2013 Varsity Tutors. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Kern)

# pragma mark - Kern methods

/**
 Returns a Boolean if the receiver is empty.
 
 @return A Boolean if the receiver is empty.
 */
- (BOOL)isEmpty;

# pragma mark - NSString (SSToolkit methods)

/**
 Returns a Boolean if the receiver contains the given `string`.
 
 @param string A string to test the the receiver for
 
 @return A Boolean if the receiver contains the given `string`
 */
- (BOOL)containsString:(NSString *)string;

/**
 Returns a new string by trimming leading and trailing characters in a given `NSCharacterSet`.
 
 @param characterSet Character set to trim characters
 
 @return A new string by trimming leading and trailing characters in `characterSet`
 */
- (NSString *)stringByTrimmingLeadingAndTrailingCharactersInSet:(NSCharacterSet *)characterSet;

/**
 Returns a new string by trimming leading and trailing whitespace and newline characters.
 
 @return A new string by trimming leading and trailing whitespace and newline characters
 */
- (NSString *)stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters;

/**
 Returns a new string by trimming leading characters in a given `NSCharacterSet`.
 
 @param characterSet Character set to trim characters
 
 @return A new string by trimming leading characters in `characterSet`
 */
- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet;

/**
 Returns a new string by trimming leading whitespace and newline characters.
 
 @return A new string by trimming leading whitespace and newline characters
 */
- (NSString *)stringByTrimmingLeadingWhitespaceAndNewlineCharacters;

/**
 Returns a new string by trimming trailing characters in a given `NSCharacterSet`.
 
 @param characterSet Character set to trim characters
 
 @return A new string by trimming trailing characters in `characterSet`
 */
- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet;

/**
 Returns a new string by trimming trailing whitespace and newline characters.
 
 @return A new string by trimming trailing whitespace and newline characters
 */
- (NSString *)stringByTrimmingTrailingWhitespaceAndNewlineCharacters;

@end
