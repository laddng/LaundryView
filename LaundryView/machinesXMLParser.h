//
//  machinesXMLParser.h
//  LaundryView
//
//  Created by Nick Ladd on 1/16/15.
//  Copyright (c) 2015 Wake Forest University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface machinesXMLParser : NSXMLParser <NSXMLParserDelegate>

- (machinesXMLParser *) initXMLParser;

@property (strong, nonatomic) NSMutableArray *machines;

@end