//
//  AppDelegate.m
//  LaundryView
//
//  Created by Nick Ladd on 12/27/14.
//  Copyright (c) 2014 Wake Forest University. All rights reserved.
//
#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    return YES;
    
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    
    UIViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"initialViewController"];

    self.window.rootViewController = rootViewController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
    
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notification
{
    
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTheTable" object:nil];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

@end