//
// Created by tyler on 2012-07-15.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FetchedResultsTableDataSource.h"
#import "Trail.h"


@interface TrailConditionsController : NSObject <
    UITableViewDelegate, NSFetchedResultsControllerDelegate
>


@property (strong,nonatomic) IBOutlet UITableView* tableView;

/** We need to retain the data source object, because it is not retained by
    anyone else, even though it is the delegate for the table view.
*/
@property (strong,nonatomic) IBOutlet FetchedResultsTableDataSource*
                                                   conditionsDataSource;


/** The trail being examined. Must be set by the TrailDetailViewController
    BEFORE the table of conditions is displayed.
*/
@property (copy,nonatomic)            Trail*       trail;


@end
