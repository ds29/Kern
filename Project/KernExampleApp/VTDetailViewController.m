//
//  VTDetailViewController.m
//  KernExampleApp
//
//  Created by Dustin Steele on 12/26/13.
//  Copyright (c) 2013 Varsity Tutors. All rights reserved.
//

#import "VTDetailViewController.h"

@interface VTDetailViewController ()
- (void)configureView;
@end

@implementation VTDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        User *user = (User*)self.detailItem;
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterLongStyle;
        
        NSString *formattedString = [NSString stringWithFormat:@"%@ %@ (%@)\n%@", user.firstName, user.lastName, user.luckyNumber, [formatter stringFromDate:user.timeStamp]];
        self.detailDescriptionLabel.text = formattedString;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
