//
//  dormXMLParser.m
//  LaundryView
//
//  Created by Nick Ladd on 12/27/14.
//  Copyright (c) 2014 Wake Forest University. All rights reserved.
//

#import "dormXMLParser.h"
#import "dorm.h"

@interface dormXMLParser ()

@property dorm *tempDormObject;

@property NSString *currentElement;

@property NSMutableString *foundValue;

@end

@implementation dormXMLParser

- (dormXMLParser *) initXMLParser
{
    
    self = [super init];
    
    self.dorms = [[NSMutableArray alloc] init];
    
    self.foundValue = [[NSMutableString alloc] init];

    return self;
    
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{

    if ([elementName isEqualToString:@"laundryroom"])
    {
        
        self.tempDormObject = [[dorm alloc] init];
        
    }
    
    self.currentElement = elementName;
        
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    if ([elementName isEqualToString:@"laundryroom"])
    {
        
        [self.dorms addObject:self.tempDormObject];
        
    }
    
    else if ([elementName isEqualToString:@"location"])
    {
        
        self.tempDormObject.dormLocation = [[[NSString stringWithString:self.foundValue] stringByReplacingOccurrencesOfString:@"\n" withString:@""]stringByReplacingOccurrencesOfString:@"\t" withString:@""];

    }
    
    else if ([elementName isEqualToString:@"laundry_room_name"])
    {
        
        self.tempDormObject.name = [[[[NSString stringWithString:self.foundValue] lowercaseString]capitalizedString] stringByReplacingOccurrencesOfString:@"1St" withString:@"1st"];
        
    }
    
    else if ([elementName isEqualToString:@"status"])
    {
        
        self.tempDormObject.status = [NSString stringWithString:self.foundValue];
        
    }
    
    [self.foundValue setString:@""];
    
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
    if ([self.currentElement isEqualToString:@"status"] ||
     [self.currentElement isEqualToString:@"laundry_room_name"] || [self.currentElement isEqualToString:@"location"])
    {
    
        if (![string isEqualToString:@"\n"] && ![string isEqualToString:@"\n\t\t\t"])
        {
            
            [self.foundValue appendString:string];
            
        }
        
    }
    
}

@end