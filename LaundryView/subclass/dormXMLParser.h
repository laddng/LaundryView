//
//  dormXMLParser.h
//  LaundryView
//
//  Created by Nick Ladd on 12/27/14.
//  Copyright (c) 2014 Wake Forest University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface dormXMLParser : NSXMLParser <NSXMLParserDelegate>

- (dormXMLParser *) initXMLParser;

@property (strong, nonatomic) NSMutableArray *dorms;

@end