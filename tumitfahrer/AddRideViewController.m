//
//  AddRideViewController.m
//  tumitfahrer
//
//  Created by Pawel Kwiecien on 4/23/14.
//  Copyright (c) 2014 Pawel Kwiecien. All rights reserved.
//

#import "AddRideViewController.h"
#import "CustomBarButton.h"
#import "ActionManager.h"
#import "CurrentUser.h"
#import "Ride.h"
#import "ActionManager.h"
#import "LocationController.h"
#import "SwitchTableViewCell.h"
#import "RidesStore.h"
#import "NavigationBarUtilities.h"
#import "MMDrawerBarButtonItem.h"
#import "SearchRideViewController.h"
#import "DriverPassengerCell.h"
#import "KGStatusBar.h"
#import "RideDetailViewController.h"

@interface AddRideViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *shareValues;
@property (nonatomic, strong) NSMutableArray *tableValues;
@property (nonatomic, strong) NSMutableArray *tableDriverPlaceholders;
@property (nonatomic, strong) NSMutableArray *tablePassengerPlaceholders;
@property (nonatomic, strong) NSMutableArray *tableSectionHeaders;
@property (nonatomic, strong) NSMutableArray *tableSectionIcons;

@end

@implementation AddRideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tableDriverPlaceholders = [[NSMutableArray alloc] initWithObjects:@"", @"Departure", @"Destination", @"Time", @"Free Seats", @"Car", @"Meeting Point", nil];
        self.tablePassengerPlaceholders = [[NSMutableArray alloc] initWithObjects:@"Departure", @"Destination", @"Time", nil];
        self.tableValues = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", @"", @"", nil];
        self.shareValues = [[NSMutableArray alloc] initWithObjects:@"Facebook", @"Email", nil];
        self.tableSectionIcons = [[NSMutableArray alloc] initWithObjects:[ActionManager colorImage:[UIImage imageNamed:@"DetailsIcons"] withColor:[UIColor whiteColor]], [ActionManager colorImage:[UIImage imageNamed:@"ShareIcon"] withColor:[UIColor whiteColor]], nil];
        self.tableSectionHeaders = [[NSMutableArray alloc] initWithObjects:@"Details", @"Share", nil];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    NSString *departurePlace = [LocationController sharedInstance].currentAddress;
    
    if(departurePlace!=nil)
        [self.tableValues replaceObjectAtIndex:0 withObject:departurePlace];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor customLightGray];
    
    UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"AddRideTableHeader" owner:self options:nil] objectAtIndex:0];
    self.tableView.tableHeaderView = headerView;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    [self setupNavigationBar];
    
    if(self.RideDisplayType == ShowAsViewController)
        [self setupLeftMenuButton];
}

-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

-(void)setupNavigationBar {
    UINavigationController *navController = self.navigationController;
    [NavigationBarUtilities setupNavbar:&navController withColor:[UIColor colorWithRed:0 green:0.463 blue:0.722 alpha:1] ];
    
    // right button of the navigation bar
    CustomBarButton *searchButton = [[CustomBarButton alloc] initWithTitle:@"Add"];
    [searchButton addTarget:self action:@selector(addRideButtonPressed) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    self.navigationItem.rightBarButtonItem = searchButtonItem;
    
    self.title = @"Add ride";
    
    UIButton *settingsView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [settingsView addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [settingsView setBackgroundImage:[ActionManager colorImage:[UIImage imageNamed:@"DeleteIcon2"] withColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:settingsView];
    [self.navigationItem setLeftBarButtonItem:settingsButton];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.tableDriverPlaceholders count]; // plus one for the first row with selection of driver/passenger
    } else if (section == 1){
        return [self.shareValues count];
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"GeneralCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {
        
        if(indexPath.row == 0) {
            DriverPassengerCell *cell = [DriverPassengerCell driverPassengerCell];
            return cell;
        } else if(indexPath.row == 4) {
            FreeSeatsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FreeSeatsTableViewCell"];
            
            if(cell == nil){
                cell = [FreeSeatsTableViewCell freeSeatsTableViewCell];
            }
            
            cell.delegate = self;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.stepperLabelText.text = [self.tableDriverPlaceholders objectAtIndex:indexPath.row];
            return  cell;
        }
        
        if (indexPath.row < [self.tableValues count] && [self.tableValues objectAtIndex:indexPath.row] != nil) {
            cell.detailTextLabel.text = [self.tableValues objectAtIndex:indexPath.row];
        }
        cell.textLabel.text = [self.tableDriverPlaceholders objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
    } else if(indexPath.section == 1) {
        SwitchTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
        
        if (switchCell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SwitchTableViewCell" owner:self options:nil];
            switchCell = [nib objectAtIndex:0];
        }
        switchCell.switchCellTextLabel.text = [self.shareValues objectAtIndex:indexPath.row];
        switchCell.switchCellTextLabel.textColor = [UIColor blackColor];
        switchCell.backgroundColor = [UIColor clearColor];
        switchCell.contentView.backgroundColor = [UIColor clearColor];
        switchCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return switchCell;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if ([[self.tableDriverPlaceholders objectAtIndex:indexPath.row] isEqualToString:@"Meeting Point"] || [[self.tableDriverPlaceholders objectAtIndex:indexPath.row] isEqualToString:@"Car"]) {
            MeetingPointViewController *meetingPointVC = [[MeetingPointViewController alloc] init];
            meetingPointVC.selectedValueDelegate = self;
            meetingPointVC.indexPath = indexPath;
            meetingPointVC.title = [self.tableDriverPlaceholders objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:meetingPointVC animated:YES];
        }
        else if (([[self.tableDriverPlaceholders objectAtIndex:indexPath.row] isEqualToString:@"Destination"]) || [[self.tableDriverPlaceholders objectAtIndex:indexPath.row] isEqualToString:@"Departure"]) {
            DestinationViewController *destinationVC = [[DestinationViewController alloc] init];
            destinationVC.delegate = self;
            destinationVC.rideTableIndexPath = indexPath;
            [self.navigationController pushViewController:destinationVC animated:YES];
        } else if([[self.tableDriverPlaceholders objectAtIndex:indexPath.row] isEqualToString:@"Time"]) {
            RMDateSelectionViewController *dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
            dateSelectionVC.delegate = self;
            [dateSelectionVC show];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40.0)];
    headerView.backgroundColor = [UIColor lighterBlue];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 20, 20)];
    imageView.image = [self.tableSectionIcons objectAtIndex:section];
    [headerView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 10, 10)];
    label.text = [self.tableSectionHeaders objectAtIndex:section];
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    [headerView addSubview:label];
    return headerView;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Details";
    } else if (section ==1)
    {
        return @"Share a ride";
    } else if(section == 2) {
        return @"Passengers";
    }
    return @"Default";
}

-(void)addRideButtonPressed {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    NSDictionary *queryParams;
    // add enum
    NSString *departurePlace = [self.tableValues objectAtIndex:1];
    NSString *destination = [self.tableValues objectAtIndex:2];
    NSString *freeSeats = [self.tableValues objectAtIndex:4];
    NSDate *departureTime = [self.tableValues objectAtIndex:5];
    NSString *meetingPoint = [self.tableValues objectAtIndex:6];
    if (!departurePlace || !destination || !meetingPoint || !departureTime) {
        return;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    NSString *now = [formatter stringFromDate:departureTime];
    
    queryParams = @{@"departure_place": departurePlace, @"destination": destination, @"departure_time": now, @"free_seats": freeSeats, @"meeting_point": meetingPoint, @"ride_type": [NSNumber numberWithInt:self.RideType]};
    NSDictionary *rideParams = @{@"ride": queryParams};
    
    [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:@"apiKey" value:[[CurrentUser sharedInstance] user].apiKey];
    
    [objectManager postObject:nil path:@"/api/v2/rides" parameters:rideParams success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        Ride *ride = (Ride *)[mappingResult firstObject];
        [[RidesStore sharedStore] addRideToStore:ride];
        [[LocationController sharedInstance] fetchLocationForAddress:ride.destination rideId:ride.rideId];
        NSLog(@"Response: %@", operation.HTTPRequestOperation.responseString);
        NSLog(@"This is ride: %@", ride);
        NSLog(@"This is driver: %@", ride.driver);
        [KGStatusBar showSuccessWithStatus:@"Ride added"];
        RideDetailViewController *rideDetailVC = [[RideDetailViewController alloc] init];
        rideDetailVC.ride = ride;
        if(self.RideDisplayType == ShowAsModal)
            [self dismissViewControllerAnimated:YES completion:nil];
        //else
        //    [self.navigationController pushViewController:rideDetailVC animated:YES];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [ActionManager showAlertViewWithTitle:[error localizedDescription]];
        RKLogError(@"Load failed with error: %@", error);
    }];
}

-(void)closeButtonPressed {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(NSFetchedResultsController *)fetchedResultsController {
    
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
        [ActionManager showAlertViewWithTitle:[error localizedDescription]];
    }
    
    return self.fetchedResultsController;
}

#pragma mark - RMDateSelectionViewController Delegates

- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSDate *)aDate {
    [self.tableValues replaceObjectAtIndex:3 withObject:[ActionManager stringFromDate:aDate]];
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)dateSelectionViewControllerDidCancel:(RMDateSelectionViewController *)vc {
    
}

-(void)didSelectValue:(NSString *)value forIndexPath:(NSIndexPath *)indexPath {
    [self.tableValues replaceObjectAtIndex:indexPath.row withObject:value];
}

-(void)selectedDestination:(NSString *)destination indexPath:(NSIndexPath*)indexPath{
    [self.tableValues replaceObjectAtIndex:indexPath.row withObject:destination];
}

-(void)stepperValueChanged:(NSInteger)stepperValue {
    [self.tableValues replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:(int)stepperValue]];
}

#pragma mark - Button Handlers

-(void)leftDrawerButtonPress:(id)sender{
    [self.sideBarController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

@end
