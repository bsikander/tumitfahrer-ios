//
//  PanoramioUtilities.h
//  tumitfahrer
//
//  Created by Pawel Kwiecien on 4/11/14.
//  Copyright (c) 2014 Pawel Kwiecien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol PanoramioUtilitiesDelegate <NSObject>

-(void)didReceivePhotoForLocation:(UIImage *)image rideId:(NSInteger)rideId;

@end

@interface PanoramioUtilities : NSObject

@property (nonatomic, weak) id<PanoramioUtilitiesDelegate> delegate;

+ (PanoramioUtilities*)sharedInstance; // Singleton method

- (UIImage*)fetchPhotoForLocation:(CLLocation*)location rideId:(NSInteger)rideId;

@end