//
//  machinesXMLParser.m
//  LaundryView
//
//  Created by Nick Ladd on 1/16/15.
//  Copyright (c) 2015 Wake Forest University. All rights reserved.
//

#import "machinesXMLParser.h"
#import "machine.h"

@interface machinesXMLParser ()

@property machine *tempMachineObject;

@property NSString *currentElement;

@property NSMutableString *foundValue;

@end

@implementation machinesXMLParser

- (machinesXMLParser *) initXMLParser
{
    
    self = [super init];
    
    self.machines = [[NSMutableArray alloc] init];
    
    self.foundValue = [[NSMutableString alloc] init];
    
    return self;
    
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
    if ([elementName isEqualToString:@"appliance"])
    {
        
        self.tempMachineObject = [[machine alloc] init];
                
    }
    
    self.currentElement = elementName;
    
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    if ([elementName isEqualToString:@"appliance"])
    {
        
        [self.machines addObject:self.tempMachineObject];
        
    }
    
    else if ([elementName isEqualToString:@"appliance_desc_key"])
    {
        
        self.tempMachineObject.machineID = [[[NSString stringWithString:self.foundValue]stringByReplacingOccurrencesOfString:@"\n" withString:@""]stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        
    }
    
    else if ([elementName isEqualToString:@"appliance_type"])
    {
        
        self.tempMachineObject.type = [NSString stringWithString:self.foundValue];
        
    }
    
    else if ([elementName isEqualToString:@"status"])
    {
        
        self.tempMachineObject.inUse = [NSString stringWithString:self.foundValue];
        
    }
    
    else if ([elementName isEqualToString:@"out_of_service"])
    {
        
        self.tempMachineObject.outOfService = [NSString stringWithString:self.foundValue];
        
    }
    
    else if ([elementName isEqualToString:@"label"])
    {
        
        self.tempMachineObject.name = [NSString stringWithString:self.foundValue];
        
    }
    
    else if ([elementName isEqualToString:@"avg_cycle_time"])
    {
        
        self.tempMachineObject.cycleTime = [NSString stringWithString:self.foundValue];
        
    }
    
    else if ([elementName isEqualToString:@"time_remaining"])
    {
        
        self.tempMachineObject.timeRemaining = [NSString stringWithString:self.foundValue];
        
    }
    
    [self.foundValue setString:@""];

}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
    if ([self.currentElement isEqualToString:@"appliance"]
        || [self.currentElement isEqualToString:@"time_remaining"]
        || [self.currentElement isEqualToString:@"label"]
        || [self.currentElement isEqualToString:@"avg_cycle_time"]
        || [self.currentElement isEqualToString:@"out_of_service"]
        || [self.currentElement isEqualToString:@"status"]
        || [self.currentElement isEqualToString:@"appliance_type"]
        || [self.currentElement isEqualToString:@"appliance_desc_key"]
        )
    {
        
        if (![string isEqualToString:@"\n"] && ![string isEqualToString:@"\n\t\t\t"])
        {
            
            [self.foundValue appendString:string];
            
        }
        
    }
    
}

@end
