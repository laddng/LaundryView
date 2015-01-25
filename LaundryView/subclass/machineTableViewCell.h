//
//  machineTableViewCell.h
//  LaundryView
//
//  Created by Nick Ladd on 12/27/14.
//  Copyright (c) 2014 Wake Forest University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface machineTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIProgressView *progressMeter;

@property (weak, nonatomic) IBOutlet UIImageView *icon;

@property (weak, nonatomic) IBOutlet UIImageView *animatedImageView;

@property (weak, nonatomic) IBOutlet UILabel *machineName;

@property (weak, nonatomic) IBOutlet UILabel *timeRemaining;

@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;

@property (weak, nonatomic) IBOutlet UILabel *available;

@end