//
//  laundryTableViewController.m
//  LaundryView
//
//  Created by Nick Ladd on 12/27/14.
//  Copyright (c) 2014 Wake Forest University. All rights reserved.
//

#import "laundryTableViewController.h"
#import "dorm.h"
#import "dormXMLParser.h"
#import "machineTableViewCell.h"
#import "availableMachineTableViewCell.h"
#import "outOfServiceTableViewCell.h"
#import "machinesXMLParser.h"
#import "machine.h"
#import "machineNotification.h"

@interface laundryTableViewController ()

@property (strong, nonatomic) NSMutableArray *machines;

@property (strong, nonatomic) NSMutableArray *notfiyMeArray;

@property (strong, nonatomic) NSMutableArray *arrayOfNotificationObjects;

@property NSString *dormID;

@property NSString *dormName;

@end

@implementation laundryTableViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self loadUserDormSettings];
    
    _machines = [[NSMutableArray alloc] init];
    
    _notfiyMeArray = [[NSMutableArray alloc] init];
    
    _arrayOfNotificationObjects = [[NSMutableArray alloc] init];

    [self loadMachines:nil];
    
    [self loadNotificationsFromDisk];
    
}

- (void) loadUserDormSettings
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    NSString *documentsDirectory = [paths objectAtIndex:0];

    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"userDormSettings.txt"];
    
    NSString *filePath = [NSString stringWithFormat:@"%@", documentsDirectory];

    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if([fileManager fileExistsAtPath:filePath])
    {
        
        NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        
        NSArray *dormInformation = [fileContents componentsSeparatedByString:@","];
        
        _dormID = [dormInformation objectAtIndex:0];
        
        _dormName = [dormInformation objectAtIndex:1];
        
        self.navigationItem.title = _dormName;

    }
    
    [self.tableView reloadData];
    
    [self loadMachines:nil];
    
}

- (void) loadMachines:(NSTimer *) timer
{
    
    [timer invalidate];
    
    NSURL * pathToMachinesFile = [NSURL URLWithString:[NSString stringWithFormat: @"http://api.laundryview.com/room/?api_key=8c31a4878805ea4fe690e48fddbfffe1&method=getAppliances&location=%@", _dormID]];
    
    NSData *fileData = [NSData dataWithContentsOfURL:pathToMachinesFile];
    
    NSXMLParser *fileParser = [[NSXMLParser alloc] initWithData:fileData];
    
    machinesXMLParser *xmlParserDelegate = [[machinesXMLParser alloc] initXMLParser];
    
    [fileParser setDelegate:xmlParserDelegate];
    
    [fileParser parse];
    
    _machines = xmlParserDelegate.machines;
    
    [self.tableView reloadData];
    
    [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(loadMachines:) userInfo:nil repeats:YES];
    
}

- (void) loadNotificationsFromDisk
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"userNotifications.txt"];
    
    NSString *filePath = [NSString stringWithFormat:@"%@", documentsDirectory];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if([fileManager fileExistsAtPath:filePath])
    {
        
        NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        
        NSArray *notificationRequests = [fileContents componentsSeparatedByString:@","];
        
        [_notfiyMeArray addObjectsFromArray:notificationRequests];
        
    }
    
    [self.tableView reloadData];

}

- (void) saveNotificationsToDisk
{
        
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *notificationRequests = [[NSString alloc] init];
    
    for (int i = 0; i<[_notfiyMeArray count]; i++)
    {
        
        notificationRequests = [notificationRequests stringByAppendingString:[NSString stringWithFormat:@"%@,", [_notfiyMeArray objectAtIndex:i]]];
        
    }

    [notificationRequests writeToFile:[documentsDirectory stringByAppendingPathComponent:@"userNotifications.txt"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [_machines count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    machine *machine = [_machines objectAtIndex:indexPath.row];
    
    if ([machine.timeRemaining isEqualToString:@"out of service"])
    {
        
        outOfServiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"outOfService"];
        
        cell.machineName.text = [NSString stringWithFormat:@"%@ %@", [[machine.type lowercaseString]capitalizedString], [NSString stringWithFormat:@"%d", [machine.name intValue]]];
        
        return cell;
        
    }
    
    else if ([machine.inUse isEqualToString:@"In Use"])
    {
        
        machineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"machine" forIndexPath:indexPath];

        if ([_notfiyMeArray containsObject:[[_machines objectAtIndex:indexPath.row] machineID]])
        {
            
            [cell.notificationSwitch setOn:YES animated:NO];

        }
        
        else
        {
            
            [cell.notificationSwitch setOn:NO animated:NO];
            
        }
        
        cell.machineName.text = [NSString stringWithFormat:@"%@ %@", [[machine.type lowercaseString]capitalizedString], [NSString stringWithFormat:@"%d", [machine.name intValue]]];
        
        float averageMachineTime = [machine.cycleTime floatValue];
        
        float timeRemaining = [[[machine.timeRemaining componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""] floatValue];
        
        cell.progressMeter.progress = 1-(timeRemaining/averageMachineTime);
        
        cell.timeRemaining.text = [NSString stringWithFormat:@"%i min.", (int) timeRemaining];
        
        NSArray *imageNames = @[@"activeMachineIcon@f1x2.png",
                                @"activeMachineIcon@f2x2.png",
                                @"activeMachineIcon@f3x2.png",
                                @"activeMachineIcon@f4x2.png",
                                @"activeMachineIcon@f5x2.png"];
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < imageNames.count; i++)
        {
            [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
        }

        cell.animatedImageView.animationImages = images;
        
        cell.animatedImageView.animationDuration = 0.2;
        
        [cell.animatedImageView startAnimating];

        return cell;

    }
    
    else if ([machine.inUse isEqualToString:@"Available"])
    {
        
        availableMachineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"availableMachine" forIndexPath:indexPath];
        
        cell.machineName.text = [NSString stringWithFormat:@"%@ %@", [[machine.type lowercaseString]capitalizedString], [NSString stringWithFormat:@"%d", [machine.name intValue]]];
        
        return cell;
        
    }
    
    else
    {
     
        availableMachineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"availableMachine" forIndexPath:indexPath];
        
        cell.machineName.text = [NSString stringWithFormat:@"%@ %@", [[machine.type lowercaseString]capitalizedString], [NSString stringWithFormat:@"%d", [machine.name intValue]]];

        return cell;
        
    }
    
}

- (IBAction)notificationSwitchChanged:(UISwitch *)sender
{
    
    CGPoint center = sender.center;
    
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:rootViewPoint];
    
    if(sender.on)
    {
        
        [self createNotification:[_machines objectAtIndex:indexPath.row]];
        
        NSString *machineID = [[_machines objectAtIndex:indexPath.row] machineID];
        
        [_notfiyMeArray addObject: machineID];
        
        [self saveNotificationsToDisk];

    }
    
    else if (!sender.on)
    {
        
        [_notfiyMeArray removeObject:[[_machines objectAtIndex:indexPath.row] machineID]];
        
        [self saveNotificationsToDisk];
        
        for (int i = 0; i<[_arrayOfNotificationObjects count]; i++)
        {
            
            if ([[[_arrayOfNotificationObjects objectAtIndex:i] machineID] isEqualToString:[[_machines objectAtIndex:indexPath.row] machineID]])
            {
                
                [[UIApplication sharedApplication] cancelLocalNotification:[_arrayOfNotificationObjects objectAtIndex:i]];
                
            }
            
        }
        
    }

}

- (void) createNotification:(machine *) userMachine
{

    machineNotification *notifyMe = [[machineNotification alloc] init];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"mm"];
    
    NSString *timeRemainingInt = [[[userMachine timeRemaining] componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    NSDate *start = [dateFormatter dateFromString:@"01"];
    
    NSDate *end = [dateFormatter dateFromString:timeRemainingInt];
    
    NSTimeInterval timeIntervalOfLaundryLoad = [end timeIntervalSinceDate:start];

    NSDate *now = [NSDate date];

    NSDate *endTimeOfLaundryLoad = [[NSDate alloc] initWithTimeInterval:timeIntervalOfLaundryLoad sinceDate:now];

    NSTimeZone *timeZoneOfUser = [NSTimeZone timeZoneWithName:@"EDT"];

    [notifyMe setFireDate:endTimeOfLaundryLoad];

    [notifyMe setTimeZone:timeZoneOfUser];

    if ([[userMachine type] isEqualToString:@"WASHER"])
    {
        
        notifyMe.alertBody = @"Your laundry load in the washer will be finished in 1 minute!";

    }
    
    else if ([[userMachine type] isEqualToString:@"DRYER"])
    {
        
        notifyMe.alertBody = @"Your laundry load in the dryer will be finished in 1 minute!";

    }
    
    notifyMe.alertLaunchImage = @"NotificationLaunchScreen";

    notifyMe.applicationIconBadgeNumber = 1;

    notifyMe.alertAction = @"view the status of your laundry";
    
    notifyMe.soundName = UILocalNotificationDefaultSoundName;
    
    notifyMe.machineID = [userMachine machineID];
    
    [_arrayOfNotificationObjects addObject:notifyMe];

    [[UIApplication sharedApplication] scheduleLocalNotification:notifyMe];

}

- (IBAction)mainViewDidUnwind:(UIStoryboardSegue *)segue
{
 
    [self loadUserDormSettings];
    
}

@end