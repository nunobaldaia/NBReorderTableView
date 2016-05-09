// NBReorderingTableView.m
//
// Copyright (c) 2015 Nuno Baldaia - http://nunobaldaia.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "NBReorderTableView.h"


CGFloat const AutoScrollingMinDistanceFromEdge = 60;


@interface NBReorderTableView ()

@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (strong, nonatomic) NSIndexPath *movingIndexPath;
@property (strong, nonatomic) UIView *placeholderView;
@property (nonatomic) CGFloat touchOriginY;
@property (strong, nonatomic) CADisplayLink *timerToAutoscroll;
@property (nonatomic) CGFloat autoscrollAmount;

@end

@implementation NBReorderTableView
@dynamic delegate;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    longPressGestureRecognizer.delegate = self;
    [self addGestureRecognizer:longPressGestureRecognizer];

    self.longPressGestureRecognizer = longPressGestureRecognizer;
}


#pragma mark - Gesture recognizer

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.longPressGestureRecognizer) {
        if ([self.dataSource respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)]) {
            NSIndexPath *indexPath = [self indexPathForRowAtPoint:[gestureRecognizer locationInView:self]];
            return indexPath && [self.dataSource tableView:self canMoveRowAtIndexPath:indexPath];
        }
        return NO;
	}
	return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint locationInView = [gestureRecognizer locationInView:self];
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self startMovingCellAtLocation:locationInView];
            break;
            
        case UIGestureRecognizerStateChanged:
            if ([self isMovingCell]) {
                [self keepMovingCellAtLocation:locationInView];
            }
            break;

        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            if ([self isMovingCell]) {
                [self finishMovingCell];
            }
            break;

        default:
            break;
    }
}

#pragma mark - Internal API

- (BOOL)isMovingCell
{
    return self.placeholderView != nil;
}

- (void)startMovingCellAtLocation:(CGPoint)location
{
    // Reset the state
    self.placeholderView = nil;
    
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:location];
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    
    if (cell == nil) {
        return;
    }
    
    // Request a dragging view from the delegate
    UIView *placeholderView = [self.delegate tableView:self placeholderViewForReorderingCell:cell];
    
    if (placeholderView == nil) {
        return;
    }

    self.placeholderView = placeholderView;
    
    // Inform the delegate that the reordering is about to begin
    if ([self.delegate respondsToSelector:@selector(tableView:willStartReorderingCellAtIndexPath:)]) {
        [self.delegate tableView:self willStartReorderingCellAtIndexPath:indexPath];
    }
    
    // Store the current moving cell indexPath
    // This should be stored after calling tableView:willStartReorderingCellAtIndexPath:
    // because the delegate may change the data source (e.g. collapse some cells)
    self.movingIndexPath = [self indexPathForCell:cell];
    
    self.touchOriginY = self.placeholderView.center.y - location.y;
    
    // Hide the cell and add the moving placeholder
    cell.hidden = YES;
    [self addSubview:placeholderView];
}

- (void)keepMovingCellAtLocation:(CGPoint)location
{
    [self autoScrollIfNeeded];

    CGPoint newCenter = CGPointMake(self.placeholderView.center.x, location.y + self.touchOriginY);

    self.placeholderView.center = newCenter;

    [self movingCellDidMove];
}

- (void)finishMovingCell
{
    // Reset autoscroll timer
    [self.timerToAutoscroll invalidate]; self.timerToAutoscroll = nil;

    // Inform the delegate that the reordering will finish
    if ([self.delegate respondsToSelector:@selector(tableView:willFinishReorderingCellAtIndexPath:)]) {
        [self.delegate tableView:self willFinishReorderingCellAtIndexPath:self.movingIndexPath];
    }

    // Reset the moving cell
    [UIView animateWithDuration:0.3 animations:^{
        self.placeholderView.frame = [self movingRect];
    } completion:^(BOOL finished) {
        for (UITableViewCell *cell in self.visibleCells) {
            cell.hidden = NO;
        }
        [self.placeholderView removeFromSuperview];
        self.placeholderView = nil;
        self.movingIndexPath = nil;
        
        // Inform the delegate that the reordering did finish
        if ([self.delegate respondsToSelector:@selector(tableViewDidFinishReordering:)]) {
            [self.delegate tableViewDidFinishReordering:self];
        }
    }];
}

- (void)movingCellDidMove
{
    // Ensure that the cell is kept hidden
    [self movingCell].hidden = YES;

    // Move row if necessary
    NSIndexPath *targetIndexPath = self.targetIndexPath;
    NSIndexPath *oldMovingIndexPath = self.movingIndexPath;
    
    if (targetIndexPath && oldMovingIndexPath) {
        // Keep the target index path on a valid position
        if ([self.delegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)]) {
            targetIndexPath = [self.delegate tableView:self targetIndexPathForMoveFromRowAtIndexPath:oldMovingIndexPath toProposedIndexPath:targetIndexPath];
        }
        
        // Store the new index path
        self.movingIndexPath = targetIndexPath;
        
        [self beginUpdates];
        
        // Update the data source
        if ([self.dataSource respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)]) {
            [self.dataSource tableView:self moveRowAtIndexPath:oldMovingIndexPath toIndexPath:targetIndexPath];
        }
        
        // Move rows
        [self moveRowAtIndexPath:oldMovingIndexPath toIndexPath:targetIndexPath];
        
        [self endUpdates];

        // Ensure the moving view is always in front
        UIView *placeholderView = self.placeholderView;
        
        if (placeholderView) {
            [self bringSubviewToFront:placeholderView];
        }
    }
}

/*
 Return the target index path if different from current one or nil
 */
- (NSIndexPath *)targetIndexPath
{
    CGPoint location = [self.longPressGestureRecognizer locationInView:self];
    NSIndexPath *overlappingIndexPath = [self indexPathForRowAtPoint:location];
    
    CGRect movingRect = [self movingRect];
    CGFloat diffY = self.placeholderView.frame.origin.y - movingRect.origin.y;

    if (diffY < 0) { // Moving up
        // Check if the cell moved above the overlaping cell
        if ([overlappingIndexPath compare:self.movingIndexPath] < 0 && location.y < (CGRectGetMinY([self rectForRowAtIndexPath:overlappingIndexPath]) + CGRectGetMaxY(movingRect))/2) {
            //NSLog(@"Move to indexPath above:%@", overlappingIndexPath);
            return overlappingIndexPath;
        }
        
        if (overlappingIndexPath == nil || overlappingIndexPath.section < self.movingIndexPath.section) {
            // Check if it's above the current section
            for (NSInteger section = self.movingIndexPath.section; section > 0 ; section--) {
                //NSLog(@"checking section:%i", section);
                if (location.y < CGRectGetMinY([self rectForSection:section])) {
                    //NSLog(@"Move to the section above:%i", section);
                    return [NSIndexPath indexPathForRow:[self numberOfRowsInSection:section-1] inSection:section-1];
                }
            }
        }
    }
    else { // Moving down
        // Check if the cell moved below the overlaping cell
        if ([overlappingIndexPath compare:self.movingIndexPath] > 0 && location.y > (CGRectGetMinY(movingRect) + CGRectGetMaxY([self rectForRowAtIndexPath:overlappingIndexPath]))/2) {
            //NSLog(@"Move to indexPath below:%@", overlappingIndexPath);
            return overlappingIndexPath;
        }
        
        if (overlappingIndexPath == nil || overlappingIndexPath.section > self.movingIndexPath.section) {
            // Check if it's inside some section below
            for (NSInteger section = self.numberOfSections-1; section > self.movingIndexPath.section; section--) {
                //NSLog(@"checking section below:%i", section);
                if (location.y > CGRectGetMinY([self rectForSection:section])) {
                    //NSLog(@"Move to the section below:%i", section);
                    return [NSIndexPath indexPathForRow:0 inSection:section];
                }
            }
        }
    }
    
    return nil;
}

- (nullable UITableViewCell *)movingCell {
    NSIndexPath *movingIndexPath = self.movingIndexPath;
    
    if (movingIndexPath) {
        return [self cellForRowAtIndexPath:movingIndexPath];
    }
    
    return nil;
}

- (CGRect)movingRect {
    NSIndexPath *movingIndexPath = self.movingIndexPath;
    
    if (movingIndexPath) {
        return [self rectForRowAtIndexPath:movingIndexPath];
    }
    
    return CGRectNull;
}


#pragma mark - Overriden

- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    UITableViewCell *cell = [super dequeueReusableCellWithIdentifier:identifier];
    cell.hidden = NO;
    return cell;
}

- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.hidden = NO;
    return cell;
}

#pragma mark - Autoscroll

- (void)autoScrollIfNeeded
{
    self.autoscrollAmount = 0;

    CGPoint location = [self.longPressGestureRecognizer locationInView:self];

    if (self.contentSize.height > self.frame.size.height) {
        float distanceFromTop = location.y - self.contentOffset.y;
        float distanceFromBottom = self.bounds.size.height - (location.y - self.contentOffset.y);

        if (distanceFromTop < AutoScrollingMinDistanceFromEdge) {
            self.autoscrollAmount = -[self autoscrollAmountForDistanceToEdge:distanceFromTop];
        }
        else if (distanceFromBottom < AutoScrollingMinDistanceFromEdge) {
            self.autoscrollAmount = [self autoscrollAmountForDistanceToEdge:distanceFromBottom];
        }
    }

    if (self.autoscrollAmount == 0) {
        [self.timerToAutoscroll invalidate]; self.timerToAutoscroll = nil;
    }
    else if (self.timerToAutoscroll == nil) {
        self.timerToAutoscroll = [CADisplayLink displayLinkWithTarget:self selector:@selector(autoscrollTimerFired:)];
        [self.timerToAutoscroll addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (float)autoscrollAmountForDistanceToEdge:(float)distance
{
    return ceilf((AutoScrollingMinDistanceFromEdge - distance) / 10);
}

- (void)autoscrollTimerFired:(NSTimer *)timer
{
    CGPoint contentOffset = [self contentOffset];

    CGFloat initialContentOffsetY = contentOffset.y;

    contentOffset.y += self.autoscrollAmount;
    if (contentOffset.y < 0) {
        contentOffset.y = 0;
    }
    if (contentOffset.y > [self contentSize].height - self.bounds.size.height) {
        contentOffset.y = [self contentSize].height - self.bounds.size.height;
    }
    self.contentOffset = contentOffset;

    self.placeholderView.center = CGPointMake(self.placeholderView.center.x, self.placeholderView.center.y + contentOffset.y - initialContentOffsetY);

    [self movingCellDidMove];
}

@end
