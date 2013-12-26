//
//  NSString+Kern.m
//  Kern
//
//  Created by Dustin Steele on 12/23/13.
//  Copyright (c) 2013 Varsity Tutors. All rights reserved.
//

#import "NSString+Kern.h"

@implementation NSString (Kern)

- (BOOL)isEmpty {
    NSString *a = [self stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters];
    return [a isEqualToString:@""];
}

- (BOOL)containsString:(NSString *)string {
    return !NSEqualRanges([self rangeOfString:string], NSMakeRange(NSNotFound, 0));
}

- (NSString *)stringByTrimmingLeadingAndTrailingCharactersInSet:(NSCharacterSet *)characterSet {
    return [[self stringByTrimmingLeadingCharactersInSet:characterSet]
            stringByTrimmingTrailingCharactersInSet:characterSet];
}

- (NSString *)stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters {
    return [[self stringByTrimmingLeadingWhitespaceAndNewlineCharacters]
            stringByTrimmingTrailingWhitespaceAndNewlineCharacters];
}

- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet {
    NSRange rangeOfFirstWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]];
    if (rangeOfFirstWantedCharacter.location == NSNotFound) {
        return @"";
    }
    return [self substringFromIndex:rangeOfFirstWantedCharacter.location];
}

- (NSString *)stringByTrimmingLeadingWhitespaceAndNewlineCharacters {
    return [self stringByTrimmingLeadingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet {
    NSRange rangeOfLastWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]
                                                               options:NSBackwardsSearch];
    if (rangeOfLastWantedCharacter.location == NSNotFound) {
        return @"";
    }
    return [self substringToIndex:rangeOfLastWantedCharacter.location + 1]; // Non-inclusive
}

- (NSString *)stringByTrimmingTrailingWhitespaceAndNewlineCharacters {
    return [self stringByTrimmingTrailingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
