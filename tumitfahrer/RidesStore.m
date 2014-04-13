//
//  RidesStore.m
//  tumitfahrer
//
//  Created by Pawel Kwiecien on 4/11/14.
//  Copyright (c) 2014 Pawel Kwiecien. All rights reserved.
//

#import "RidesStore.h"
#import "Ride.h"

@interface RidesStore () <NSFetchedResultsControllerDelegate>

@property (nonatomic) NSMutableArray *privateRides;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation RidesStore

-(instancetype)init {
    self = [super init];
    if (self) {
        [self loadRides];
        if ([self.privateRides count] == 0) {
            [self fetchRidesFromWebservice];
        }
    }
    return self;
}

+(instancetype)sharedStore {
    static RidesStore *ridesStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ridesStore = [[self alloc] init];
    });
    return ridesStore;
}

-(void)loadRides {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *e = [NSEntityDescription entityForName:@"Ride"
                                         inManagedObjectContext:[RKManagedObjectStore defaultStore].
                              mainQueueManagedObjectContext];
    request.entity = e;
    
    NSError *error;
    NSArray *result = [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext executeFetchRequest:request error:&error];
    if (!result) {
        [NSException raise:@"Fetch failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    
    self.privateRides = [[NSMutableArray alloc] initWithArray:result];
}

-(void)fetchRidesFromWebservice {
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
//    [objectManager.HTTPClient setDefaultHeader:@"Authorization: Basic" value:[self encryptCredentialsWithEmail:self.emailTextField.text password:self.passwordTextField.text]];
    
    [objectManager postObject:nil path:@"/api/v2/rides" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.privateRides = [NSMutableArray arrayWithArray:[mappingResult array]];
        
        for (Ride *ride in self.privateRides) {
            [[LocationController sharedInstance] fetchLocationForAddress:ride.destination];
        }
        
        [self.delegate didRecieveRidesFromWebService:self.privateRides];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
    }];
}

-(NSArray *)allRides {
    return self.privateRides;
}

-(NSFetchedResultsController *)fetchedResultsController
{
    if (self.fetchedResultsController != nil) {
        return self.fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Ride"];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
    fetchRequest.sortDescriptors = @[descriptor];
    NSError *error = nil;
    
    // Setup fetched results
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetchRequest
                                     managedObjectContext:[RKManagedObjectStore defaultStore].
                                     mainQueueManagedObjectContext
                                     sectionNameKeyPath:nil cacheName:@"Ride"];
    self.fetchedResultsController.delegate = self;
    
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error fetching from db: %@", [error localizedDescription]);
    }
    
    return self.fetchedResultsController;
}

-(void)didReceiveLocationForAddress:(CLLocation *)location rideId:(NSInteger)rideId{
    Ride *ride = [self getRideWithId:rideId];
    ride.destinationLatitude = location.coordinate.latitude;
    ride.destinationLongitude = location.coordinate.longitude;
    
    [self printAllRides];
    [[PanoramioUtilities sharedInstance] fetchPhotoForLocation:location rideId:rideId];
}

-(void)didReceivePhotoForLocation:(UIImage *)image rideId:(NSInteger)rideId{
    Ride *ride = [self getRideWithId:rideId];
    ride.destinationImage = image;
    [self.delegate didReceivePhotoForRide:rideId];
}

#pragma mark - utility funtioncs

- (Ride *)getRideWithId:(NSInteger)rideId {
    for (Ride *ride in self.allRides) {
        if (ride.rideId == rideId) {
            return ride;
        }
    }
    return nil;
}

- (void)printAllRides {
    for (Ride *ride in self.allRides) {
        NSLog(@"Ride: %@", ride);
    }
}

@end