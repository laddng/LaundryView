//
//  machine.h
//  LaundryView
//
//  Created by Nick Ladd on 1/16/15.
//  Copyright (c) 2015 Wake Forest University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface machine : NSObject

@property NSString *machineID;

@property NSString *type;

@property NSString *name;

@property NSString *outOfService;

@property NSString *inUse;

@property NSString *cycleTime;

@property NSString *timeRemaining;

@end