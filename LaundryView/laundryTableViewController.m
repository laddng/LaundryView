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
#import "unknownTableViewCell.h"
#import "outOfServiceTableViewCell.h"
#import "machinesXMLParser.h"
#import "machine.h"

@interface laundryTableViewController ()

@property (strong, nonatomic) NSMutableArray *machines;

@property NSString *dormID;

@property NSString *dormName;

@end

@implementation laundryTableViewController

- (void)viewDidLoad
{

    [super viewDidLoad];
    
    _machines = [[NSMutableArray alloc] init];

    [self loadUserDormSettings];
    
    [self loadMachines:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadData) name:@"reloadTheTable" object:nil];
    
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
    
    [self downloadData];
    
    [self.tableView reloadData];
    
}

- (void) loadMachines:(NSTimer *) timer
{
    
    [timer invalidate];
    
    [self performSelectorInBackground:@selector(downloadData) withObject:nil];
    
    [self.tableView reloadData];
    
    [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(loadMachines:) userInfo:nil repeats:YES];

}

- (void) downloadData
{
    
    NSURL * pathToMachinesFile = [NSURL URLWithString:[NSString stringWithFormat: @"http://api.laundryview.com/room/?api_key=8c31a4878805ea4fe690e48fddbfffe1&method=getAppliances&location=%@", _dormID]];
    
    NSData *fileData = [NSData dataWithContentsOfURL:pathToMachinesFile];
    
    NSXMLParser *fileParser = [[NSXMLParser alloc] initWithData:fileData];
    
    machinesXMLParser *xmlParserDelegate = [[machinesXMLParser alloc] initXMLParser];
    
    [fileParser setDelegate:xmlParserDelegate];
    
    [fileParser parse];
    
    _machines = xmlParserDelegate.machines;
    
    [self.tableView reloadData];
    
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
        
        outOfServiceTableViewCell *cell = [outOfServiceTableViewCell alloc];
        
        if ([machine.type isEqualToString:@"WASHER"])
        {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"outOfService"];

        }
        
        else {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"outOfServiceDryer"];

        }
        
        cell.machineName.text = [NSString stringWithFormat:@"%@ %@", [[machine.type lowercaseString]capitalizedString], [NSString stringWithFormat:@"%d", [machine.name intValue]]];
        
        return cell;
        
    }
    
    else if ([machine.timeRemaining isEqualToString:@"unknown"])
    {
        
        unknownTableViewCell *cell = [unknownTableViewCell alloc];
        
        if ([machine.type isEqualToString:@"WASHER"])
        {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"unknown"];
            
        }
        
        else {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"unknownDryer"];

        }
        
        cell.machineName.text = [NSString stringWithFormat:@"%@ %@", [[machine.type lowercaseString]capitalizedString], [NSString stringWithFormat:@"%d", [machine.name intValue]]];
        
        return cell;
        
    }
    
    else if ([machine.inUse isEqualToString:@"In Use"])
    {
        
        machineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"machine" forIndexPath:indexPath];
        
        [cell.notificationSwitch setOn:NO animated:NO];

        UIApplication *app = [UIApplication sharedApplication];

        NSArray *eventArray = [app scheduledLocalNotifications];

        for (int i=0; i<[eventArray count]; i++)
        {

            UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
            
            NSDictionary *userInfoCurrent = oneEvent.userInfo;
            
            NSString *machineId = [NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"machineID"]];
            
            if ([machineId isEqualToString:[[_machines objectAtIndex:indexPath.row] machineID]])
            {
                
                [cell.notificationSwitch setOn:YES animated:NO];
                
            }
            
        }

        cell.machineName.text = [NSString stringWithFormat:@"%@ %@", [[machine.type lowercaseString]capitalizedString], [NSString stringWithFormat:@"%d", [machine.name intValue]]];
        
        float averageMachineTime = [machine.cycleTime floatValue];
        
        float timeRemaining = [[[machine.timeRemaining componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""] floatValue];
        
        cell.progressMeter.progress = 1-(timeRemaining/averageMachineTime);
        
        cell.timeRemaining.text = [NSString stringWithFormat:@"%i min.", (int) timeRemaining];
        
        NSArray *imageNames = [NSArray alloc];
        
        if ([machine.type isEqualToString:@"WASHER"])
        {
            
            imageNames = @[@"activeMachineIcon@f1x2.png",
                                    @"activeMachineIcon@f2x2.png",
                                    @"activeMachineIcon@f3x2.png",
                                    @"activeMachineIcon@f4x2.png",
                                    @"activeMachineIcon@f5x2.png"];
            
        }

        else {
            
             imageNames = @[@"activeDryerIcon@f1x2.png",
                            @"activeDryerIcon@f2x2.png",
                            @"activeDryerIcon@f1x2.png",
                            @"activeDryerIcon@f2x2.png"];
        }
        
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
        
        availableMachineTableViewCell *cell = [availableMachineTableViewCell alloc];
        
        if ([machine.type isEqualToString:@"WASHER"])
        {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"availableWasher" forIndexPath:indexPath];

        }
        
        else {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"availableDryer" forIndexPath:indexPath];
            
        }
        
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

        [self performSelectorInBackground:@selector(createNotification:) withObject:[_machines objectAtIndex:indexPath.row]];
        
    }
    
    else if (!sender.on)
    {

        UIApplication *app = [UIApplication sharedApplication];
        
        NSArray *eventArray = [app scheduledLocalNotifications];

        for (int i=0; i<[eventArray count]; i++)
        {

            UILocalNotification* oneEvent = [eventArray objectAtIndex:i];

            NSDictionary *userInfoCurrent = oneEvent.userInfo;

            NSString *machineId = [NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"machineID"]];

            if ([machineId isEqualToString:[[_machines objectAtIndex:indexPath.row] machineID]])
            {

                [app cancelLocalNotification:oneEvent];

            }

        }
        
    }

}

- (void) createNotification:(machine *) userMachine
{

    UILocalNotification *notifyMe = [[UILocalNotification alloc] init];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"mm"];
    
    NSString *timeRemainingInt = [[[userMachine timeRemaining] componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    NSDate *start = [dateFormatter dateFromString:@"05"];
    
    NSDate *end = [dateFormatter dateFromString:timeRemainingInt];
    
    NSTimeInterval timeIntervalOfLaundryLoad = [end timeIntervalSinceDate:start];

    NSDate *now = [NSDate date];

    NSDate *endTimeOfLaundryLoad = [[NSDate alloc] initWithTimeInterval:timeIntervalOfLaundryLoad sinceDate:now];

    NSTimeZone *timeZoneOfUser = [NSTimeZone timeZoneWithName:@"EDT"];

    [notifyMe setFireDate:endTimeOfLaundryLoad];

    [notifyMe setTimeZone:timeZoneOfUser];

    if ([[userMachine type] isEqualToString:@"WASHER"])
    {
        
        notifyMe.alertBody = @"Your laundry load in the washer will be finished in 5 minutes!";

    }
    
    else if ([[userMachine type] isEqualToString:@"DRYER"])
    {
        
        notifyMe.alertBody = @"Your laundry load in the dryer will be finished in 5 minutes!";

    }

    notifyMe.alertAction = @"view the status of your laundry";
    
    notifyMe.applicationIconBadgeNumber = 1;
    
    notifyMe.soundName = UILocalNotificationDefaultSoundName;
    
    NSDictionary *machineIDrecord = [[NSDictionary alloc] initWithObjects:@[[userMachine machineID]] forKeys: @[@"machineID"]];

    notifyMe.userInfo = machineIDrecord;

    for (UILocalNotification *notifyMeList in [[UIApplication sharedApplication] scheduledLocalNotifications])
    {

        if([[notifyMeList.userInfo objectForKey:@"machineID"] isEqualToString:[userMachine machineID]])
        {
            
            return;
            
        }
        
    }

    [[UIApplication sharedApplication] scheduleLocalNotification:notifyMe];

}

- (IBAction)mainViewDidUnwind:(UIStoryboardSegue *)segue
{
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
 
    [self loadUserDormSettings];
    
}

@end