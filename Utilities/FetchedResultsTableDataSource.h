//
//  Created by tyler on 2011-12-17.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>
#import "CoreDataUtils.h"
#import "FetchedResults.h"


/** This class makes it dead simple to make a table for displaying the list of
    managed objects resulting from a fetch request. Just drag an Object template
    onto the dock alongside the other top-level objects. Connect it to the
    table view's dataSource outlet and go to its Identity inspector. In the User
    Defined Runtime Attributes section, assign values for some of the properties
    below. No code required! Unless your fetch request has substitution
    variables, you're done. In that case, just programatically assign a value to
    property templateSubstitutionVariables. (See below.)

    If your table uses custom table view cells, all you need to do is implement
    an informal protocol in your subclass of UITableViewCell. Just write a
    method having signature -(void)willShowManagedObject:(NSManagedObject*)obj.
    Here you can assign text to UILabels or otherwise define the appearance of
    your cell based on the managed object's data.

    Below, we've assumed you've already defined an appropriate entity and fetch
    request in Xcode's data modeling tool.
*/
@interface FetchedResultsTableDataSource : NSObject<UITableViewDataSource>


/** The CoreDataUtils object used to obtain the resultsController. Normally,
    you won't set this property; the object in the app delegate's dataUtils
    property is used by default. However, you might want to set it, for
    example, if you needed to access data from a NSManagedObjectContext
    different than the one provided by the app delegate. If you do set it,
    you must do so before any UITableViewDataSource methods are called.
*/
@property (nonatomic,retain)   CoreDataUtils*  dataUtils;


/** The NSFetchedResultsController used by the receiver to obtain data for each
    cell and section in the table view. It is created automatically when first
    needed or when the templateSubstitutionVariables dictionary changes. The
    CoreDataUtils in dataUtils is used to obtain the instance.
*/
@property (nonatomic,readonly,retain) FetchedResults* fetchedResults;


/** If the request template designated by requestTemplateName (see below)
    requires substitution variables, you can programmatically assign a
    dictionary to this property. If you assign an NSMutableDictionary, you can
    repeatedly set new values to variables, and the new results will be
    reflected in the generated table.
*/
@property (nonatomic,retain)   NSDictionary*   templateSubstitutionVariables;


#pragma mark - Properties assigned in IB
/*  The following properties are normally assigned in Interface Builder.
*/


/** Required. The name of the fetch request template as defined in the Xcode
    data modeling tool. If the template has variables, you can programatically
    assign a dictionary to property templateSubstitutionVariables (see above).
*/
@property (nonatomic,retain)   NSString*       requestTemplateName;


/** Required. This must be a name of an attribute of the Entity specified by
    the request template named by property requestTemplateName. This string is
    also used in the table view cell's reuseIdentifier property. In
    Interface Builder, you must enter a string like "yourKeySortedFirst" or
    "yourKeySortedFirst/yourKeySortedSecond" (if a value for keySortedSecond is
    provided) into the Identifier field of the Attributes Inspector for the
    prototype cell.
*/
@property (nonatomic,retain)   NSString*       keySortedFirst;


/** Whether the attribute indicated by keySortedFirst should appear in
    increasing order as you read down the table cells. Default is NO.
*/
@property (nonatomic)          BOOL            sortFirstAscending;


/** Whether the attribute indicated by keySortedFirst should be used to label
    sections in the table view. Specifying NO means there will be no sections.
    Default is NO.
*/
@property (nonatomic)          BOOL            hasSections;


/** The attribute named by this property is used to sort managed objects that
    have equal values for the attribute named by keySortedFirst. Thus, cells
    will appear sorted first by keySortedFirst, then second by keySortedSecond.
    Default is nil, meaning only the attribute named by keySortedFirst is
    examined.
*/
@property (nonatomic,retain)   NSString*       keySortedSecond;


/** If keySortedSecond is non-nil, specifies whether its attribute should appear
    in increasing order as you read down the table cells. Default is NO.
*/
@property (nonatomic)          BOOL            sortSecondAscending;


/** Name of attribute to appear in the cell's main "text" label.
    If not set, no text label will appear, and the "detail" label, if
    cellDetailTextAttributePath was assigned, will be vertically centered.
*/
@property (nonatomic,retain)   NSString*       cellTextAttributePath;


/** Name of attribute to appear in the cell's main "detail" label.
    If not set, no detail label will appear, and the "text" label, if
    cellTextAttributePath was assigned, will be vertically centered.
*/
@property (nonatomic,retain)   NSString*       cellDetailTextAttributePath;


/** Use this property to obtain the table cell's reuse identifier, which was
    assigned in Interface Builder. (See keySortedFirst, above.) If you don't
    assign a value, a string like "yourKeySortedFirst" or
    "yourKeySortedFirst/yourKeySortedSecond" will be generated. This must match
    the value you assigned in Interface Builder.
*/
@property (nonatomic,retain)   NSString*       cellReuseIdentifier;


/** This is the threshold for controlling whether a section index is shown over
    the right side of the table. The index will appear iff there are at least
    this number of sections.
*/
@property (nonatomic)          NSInteger       numSectionsForShowingIndex;


@end
