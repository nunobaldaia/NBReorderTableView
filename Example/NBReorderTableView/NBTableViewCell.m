//
//  NBTableViewCell.m
//  NBReorderTableView
//
//  Created by Nuno Baldaia on 03/02/15.
//  Copyright (c) 2015 Nuno Baldaia. All rights reserved.
//

#import "NBTableViewCell.h"

@implementation NBTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont boldSystemFontOfSize:15];
        self.textLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
