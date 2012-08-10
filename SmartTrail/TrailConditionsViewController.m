//
// Created by tyler on 2012-07-15.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TrailConditionsViewController.h"
#import "ConditionTableViewCell.h"
#import "UILabel+Utils.h"

@interface TrailConditionsViewController ()
- (void) toggleCellForIndexPath:(NSIndexPath*)idxPath toHeight:(CGFloat)hght;
@end


@implementation TrailConditionsViewController
{
    //  These two ivars maintain the height of the cell to be expanded, if any,
    //  and the index of its row in the table view.
    NSIndexPath* __expandedCellIndexPath;
    CGFloat      __expandedCellHeight;
}


@synthesize tableView = __tableView;
@synthesize conditionsDataSource = __conditionsDataSource;
@synthesize trail = __trail;


- (void)viewDidLoad {
    [super viewDidLoad];
    //  For some reason, you can't set this in IB:
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}


- (void) viewDidUnload {
    self.tableView = nil;
    self.conditionsDataSource = nil;
    [super viewDidUnload];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orient {
    return  orient == UIInterfaceOrientationPortrait;
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //  Tell the data source for the table of conditions which trail we're
    //  viewing, so it can generate the list of Condition objects for it.
    self.conditionsDataSource.templateSubstitutionVariables = [NSDictionary
        dictionaryWithObject:self.trail.id forKey:@"id"
    ];
}


#pragma mark - UITableViewDelegate implementation for the table of conditions


- (NSIndexPath*)
                   tableView:(UITableView*)tableView
    willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    //  Set of indexes of rows whose cells will change their height. The given
    //  indexPath will not be nil, but expandedCellIndexPath will be nil if no
    //  other cell is expanded. Also, expandedCellIndexPath may be the same as
    //  indexPath, hence the use of an NSSet.
    NSSet* changingCellIndexes = [NSSet
        setWithObjects:indexPath, __expandedCellIndexPath, nil
    ];

    //  Record the at-most-one cell to be expanded in height.
    ConditionTableViewCell* cell = (ConditionTableViewCell*)[tableView
        cellForRowAtIndexPath:indexPath
    ];
    [self
        toggleCellForIndexPath:indexPath
                      toHeight:(   cell.bounds.size.height
                               +   [cell.commentLabel moreHeightWanted]
                               )
    ];

    //  Reload the one or two rows whose cells have changed height.
    [self.tableView
        reloadRowsAtIndexPaths:[changingCellIndexes allObjects]
              withRowAnimation:UITableViewRowAnimationNone
    ];

    return  indexPath;
}


- (CGFloat)
                  tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return  [indexPath isEqual:__expandedCellIndexPath]
    ?   __expandedCellHeight            // New height of selected row.
    :   tableView.rowHeight;            // Default for all other rows.
}


#pragma mark - NSFetchedResultsControllerDelegate implementation for the table of conditions


- (void) controllerDidChangeContent:(NSFetchedResultsController*)sender {
    //  Some managed object known by the results controller has been added,
    //  removed, moved, or updated.
    [self.tableView reloadData];
}


#pragma mark - Private methods and functions


/** Record the new height of the single cell to be expanded in the table of
    conditions, along with the index of its row. The stored data will be
    accessed by the table view when it calls the
    tableView:heightForRowAtIndexPath: delegate method.
*/
- (void) toggleCellForIndexPath:(NSIndexPath*)idxPath toHeight:(CGFloat)hght {
    __expandedCellIndexPath =
        [idxPath isEqual:__expandedCellIndexPath]  ?  nil  :  idxPath;
    __expandedCellHeight = hght;
}


@end
