//
//  RideViewController.h
//  tumitfahrer
//
//  Created by Pawel Kwiecien on 4/1/14.
//  Copyright (c) 2014 Pawel Kwiecien. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RideDetailsViewController : UIViewController

- (IBAction)arrowLeftPressed:(id)sender;

@property (nonatomic, assign) NSInteger imageNumber;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
- (IBAction)joinButtonPressed:(id)sender;
- (IBAction)contactDriverButtonPressed:(id)sender;

@end