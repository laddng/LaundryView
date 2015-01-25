//
//  initialViewController.m
//  LaundryView
//
//  Created by Nick Ladd on 1/24/15.
//  Copyright (c) 2015 Wake Forest University. All rights reserved.
//

#import "initialViewController.h"
#import "laundryTableViewController.h"
#import "settingsTableViewController.h"

@interface initialViewController ()

@end

@implementation initialViewController

- (void) viewDidLoad
{
    
    [_spinner startAnimating];
    
}

- (void) viewDidAppear:(BOOL)animated
{

    if(!self.dormHasBeenSelected)
    {

        settingsTableViewController *settings = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"settingsViewController"];
        
        [self.navigationController presentViewController:settings animated:NO completion:nil];

    }

    else
    {
        laundryTableViewController *laundryMachines = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mainViewController"];
        
        [self.navigationController presentViewController:laundryMachines animated:NO completion:nil];

    }

}

- (BOOL) dormHasBeenSelected
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"userDormSettings.txt"];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if([fileManager fileExistsAtPath:documentsDirectory])
    {
        
        return YES;
        
    }
    
    else
    {
        
        return NO;
        
    }
    
}

@end