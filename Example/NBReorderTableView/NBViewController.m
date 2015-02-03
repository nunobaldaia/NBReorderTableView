//
//  NBViewController.m
//  NBReorderTableView
//
//  Created by Nuno Baldaia on 02/03/2015.
//  Copyright (c) 2014 Nuno Baldaia. All rights reserved.
//

#import "NBViewController.h"
#import <NBReorderTableView/NBReorderTableView.h>
#import "NBTableViewCell.h"

@interface NBViewController ()

@property (nonatomic, strong) NSMutableArray *rows;

@end

@implementation NBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rows = [NSMutableArray new];
    
    for (int i = 0; i < 20; i++) {
        [self.rows addObject:[NSString stringWithFormat:@"Row %i", i + 1]];
    }

    self.tableView = [NBReorderTableView new];
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView registerClass:[NBTableViewCell class] forCellReuseIdentifier:@"Cell"];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.rows[indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView placeholderViewForReorderingCell:(UITableViewCell *)cell
{
    // Create an image from the cell being dragged
    UIGraphicsBeginImageContextWithOptions(cell.contentView.bounds.size, NO, 0);
    [cell.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create the placeholder view to be dragged
    UIImageView *placeholder = [[UIImageView alloc] initWithImage:cellImage];
    
    // Set the view's frame
    CGRect frame = placeholder.frame;
    frame.origin.y = cell.frame.origin.y;
    placeholder.frame = frame;
    
    placeholder.layer.shouldRasterize = YES;
    placeholder.layer.shadowOpacity = 0.4;
    placeholder.layer.shadowRadius = 2;
    placeholder.layer.shadowOffset = CGSizeZero;
    placeholder.layer.zPosition = MAXFLOAT;
    [UIView animateWithDuration:0.25 animations:^{
        placeholder.transform = CGAffineTransformMakeScale(1.02, 1.02);
    }];
    placeholder.alpha = 0.8;
    
    return placeholder;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self.rows exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
}

@end
