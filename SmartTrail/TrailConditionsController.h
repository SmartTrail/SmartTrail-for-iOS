//
// Created by tyler on 2012-07-15.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FetchedResultsTableDataSource.h"
#import "Trail.h"


/** This class encapsulates the display of trail conditions.
*/
@interface TrailConditionsController : NSObject <
    UITableViewDelegate, NSFetchedResultsControllerDelegate
>


/** The table view listing the trail conditions. Its delegate must be set to
    the instance of this class (in IB). It will be shown when the user taps the
    super-view's "Conditions" segmented control.
*/
@property (nonatomic)        IBOutlet UITableView* tableView;


/** We need to retain the data source object, because it is not retained by
    anyone else. It must be the delegate for the table view.
*/
@property (strong,nonatomic) IBOutlet FetchedResultsTableDataSource*
                                                   conditionsDataSource;


/** The trail being examined. Must be set by the TrailDetailViewController
    BEFORE the table of conditions is displayed.
*/
@property (copy,nonatomic)            Trail*       trail;


@end
