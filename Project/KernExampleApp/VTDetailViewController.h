//
//  VTDetailViewController.h
//  KernExampleApp
//
//  Created by Dustin Steele on 12/26/13.
//  Copyright (c) 2013 Varsity Tutors. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VTDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
