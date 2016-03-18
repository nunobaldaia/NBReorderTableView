// NBReorderingTableView.h
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

#import <UIKit/UIKit.h>

@protocol NBReorderTableViewDelegate <UITableViewDelegate>

/**
 Asks the delegate a placeholder view to be dragged by the user, representing the cell being reordered. (required)
 
 @discussion In order to give more freedom on configuring this view, its frame must be set by the delegate. Returning a nil view will cancel the move.
 
 @param tableView The table-view object requesting this information.
 @param cell The cell being reordered.
 */
- (nullable UIView *)tableView:(nonnull UITableView *)tableView placeholderViewForReorderingCell:(nonnull UITableViewCell *)cell;

@optional

/**
 Informs the delegate that the table-view will start reordering a cell.

 @param tableView The table-view object requesting this information.
 @param indexPath The original index path of the cell.
 */
- (void)tableView:(nonnull UITableView *)tableView willStartReorderingCellAtIndexPath:(nonnull NSIndexPath *)indexPath;

/**
 Informs the delegate that the table-view will finish reordering a cell.
 
 @param tableView The table-view object requesting this information.
 @param indexPath The final index path of the cell.
 */
- (void)tableView:(nonnull UITableView *)tableView willFinishReorderingCellAtIndexPath:(nonnull NSIndexPath *)indexPath;

/**
 Informs the delegate that the reordering has finished.
 
 @discussion This is called after the reordering view is reset to the final position.
 
 @param tableView The table-view object requesting this information.
*/
- (void)tableViewDidFinishReordering:(nonnull UITableView *)tableView;

@end


@interface NBReorderTableView : UITableView <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <NBReorderTableViewDelegate> delegate;

@property (strong, nonatomic, readonly) UILongPressGestureRecognizer * _Nonnull longPressGestureRecognizer;

@end
