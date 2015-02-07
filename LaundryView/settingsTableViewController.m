//
//  settingsTableViewController.m
//  LaundryView
//
//  Created by Nick Ladd on 12/27/14.
//  Copyright (c) 2014 Wake Forest University. All rights reserved.
//

#import "settingsTableViewController.h"
#import "laundryTableViewController.h"
#import "dormXMLParser.h"
#import "dorm.h"

@interface settingsTableViewController ()

@property (strong, nonatomic) NSMutableArray *dorms;

@property dorm *selectedDormObject;

@property (strong, nonatomic) NSIndexPath *checkedIndexPath;

@end

@implementation settingsTableViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    _dorms = [[NSMutableArray alloc] init];
    
    [self loadDormData];

    [self checkOffPreSelectedDorm];

}

- (void) checkOffPreSelectedDorm
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"userDormSettings.txt"];
    
    NSString *filePath = [NSString stringWithFormat:@"%@", documentsDirectory];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if([fileManager fileExistsAtPath:filePath])
    {
        
        NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding: NSUTF8StringEncoding error:nil];
        
        NSArray *dormInformation = [fileContents componentsSeparatedByString:@","];
        
        for (int i=0; i<[_dorms count]; i++)
        {
            
            if ([[[_dorms objectAtIndex:i] dormLocation] isEqualToString:[dormInformation objectAtIndex:0]])
            {
                
                _selectedDormObject = [_dorms objectAtIndex:i];
                
                _checkedIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
             
            }
            
        }
    }
    
    [self.tableView reloadData];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [_dorms count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dorm" forIndexPath:indexPath];

    cell.textLabel.text = [[_dorms objectAtIndex:indexPath.row] name];
    
    if ([_selectedDormObject isEqual:[_dorms objectAtIndex:indexPath.row]])
    {
        
        [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
        
    }
    
    else
    {
        
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
    }
    
    return cell;
    
}

- (void) loadDormData
{
    
    NSURL * pathToDormsFile = [NSURL URLWithString:@"http://api.laundryview.com/school/?api_key=8c31a4878805ea4fe690e48fddbfffe1&method=getRoomData"];
    
    NSData *fileData = [NSData dataWithContentsOfURL:pathToDormsFile];
    
    NSXMLParser *fileParser = [[NSXMLParser alloc] initWithData:fileData];
    
    dormXMLParser *xmlParserDelegate = [[dormXMLParser alloc] initXMLParser];
    
    [fileParser setDelegate:xmlParserDelegate];
    
    [fileParser parse];
    
    _dorms = xmlParserDelegate.dorms;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(_checkedIndexPath)
    {
        
        UITableViewCell *uncheckCell = [tableView cellForRowAtIndexPath:self.checkedIndexPath];
        
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    cell.textLabel.text = [[_dorms objectAtIndex:indexPath.row] name];
    
    _checkedIndexPath = indexPath;
    
    _selectedDormObject = [_dorms objectAtIndex:indexPath.row];
    
    [self saveSelectedDormToDisk];
    
}

-  (void) saveSelectedDormToDisk
{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *userDormSelection = [NSString stringWithFormat:@"%@,%@", [_selectedDormObject dormLocation], [[_selectedDormObject name] stringByReplacingOccurrencesOfString:@"North Campus" withString:@"NC"]];

    [userDormSelection writeToFile:[documentsDirectory stringByAppendingPathComponent:@"userDormSettings.txt"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [self performSegueWithIdentifier:@"unwindLaundryVC" sender:self];
    
    [self dismissViewControllerAnimated:NO completion: nil];
    
}

- (IBAction)viewDidUnwind:(UIStoryboardSegue *)segue
{
    
}

@end