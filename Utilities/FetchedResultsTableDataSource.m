//
//  Created by tyler on 2011-12-17.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FetchedResultsTableDataSource.h"
#import APP_DELEGATE_H
#import "NSString+Utils.h"

@interface FetchedResultsTableDataSource ()

//  Make fetchedResults writable within this file.
@property (nonatomic,readwrite) FetchedResults* fetchedResults;

- (void) validateState;

@end


@implementation FetchedResultsTableDataSource


@synthesize dataUtils = __dataUtils;
@synthesize fetchedResults = __fetchedResults;
@synthesize requestTemplateName = __requestTemplateName;
@synthesize templateSubstitutionVariables = __templateSubstitutionVariables;
@synthesize keySortedFirst = __keySortedFirst;
@synthesize sortFirstAscending = __sortFirstAscending;
@synthesize hasSections = __hasSections;
@synthesize keySortedSecond = __keySortedSecond;
@synthesize sortSecondAscending = __sortSecondAscending;
@synthesize cellTextAttributeName = __cellTextAttributeName;
@synthesize cellDetailTextAttributeName = __cellDetailTextAttributeName;
@synthesize cellReuseIdentifier = __cellReuseIdentifier;
@synthesize numSectionsForShowingIndex = __numSectionsForShowingIndex;


- (void) dealloc {
    [__dataUtils release],                     __dataUtils = nil;
    [__fetchedResults release],                __fetchedResults = nil;
    [__requestTemplateName release],           __requestTemplateName = nil;
    [__templateSubstitutionVariables release], __templateSubstitutionVariables = nil;
    [__keySortedFirst release],                __keySortedFirst = nil;
    [__keySortedSecond release],               __keySortedSecond = nil;
    [__cellTextAttributeName release],         __cellTextAttributeName = nil;
    [__cellDetailTextAttributeName release],   __cellDetailTextAttributeName = nil;
    [__cellReuseIdentifier release],           __cellReuseIdentifier = nil;
    [super dealloc];
}


/** This method is called if the receiver was created from a nib or storyboard.
    As this class is normally used, the receiver instance does not need
    anything referring to it except the UITableView for which it is the
    dataSource. It just sits as a top-level object with a connection from the
    UITableView's dataSource outlet. But since UITableView's dataSource property
    does not retain its object, the receiver will not have an owner and will be
    released. Therefore, we retain it here, causing it to live for the lifetime
    of the app.
*/
- (void) awakeFromNib {
    [self retain];
}


/** If this method is called, it means a property is being changed. We will
    need to create a new NSFetchedResultsController. We invalidate it, and it
    will be recreated by the fetchedResults getter when needed.
*/
- (void) setValue:(id)val forKey:(NSString*)key {
    id oldVal = [self valueForKey:key];
    if (
        ! [key isEqualToString:@"fetchedResults"]  &&  // Avoid inf. loop.
        ! [val isEqual:oldVal]  &&
        val != oldVal                                     // Handles val = nil.
    ) {
        self.fetchedResults = nil;
    }
    [super setValue:val forKey:key];
}


- (CoreDataUtils*) dataUtils {
    if ( ! __dataUtils ) {
        self.dataUtils = THE(dataUtils);
    }
    return  __dataUtils;
}


- (FetchedResults*) fetchedResults {
    
    //  Initialize fetchedResults if it is nil. If it is non-nil, we refresh
    //  it whenever the following fails:
    //
    //    A non-nil templateSubstitutionVariables matches the one
    //    used for the current (non-nil) fetchedResults.
    //
    //  Note that a nil assignment to a formerly non-nil
    //  templateSubstitutionVariables causes setValue:forKey: to reset
    //  fetchedResults. (See above.)
    //
    //  Also note that oldVars holds a COPY of templateSubstitutionVariables,
    //  not a reference to it. So a change will be detected even if
    //  the latter is mutable and only its contents have changed.
    //
    id vars = self.templateSubstitutionVariables;
    if (
        ! __fetchedResults || (
            vars  &&  ! [vars
                isEqualToDictionary:__fetchedResults.substitutionVariables
            ]
        )
    ) {
        [self validateState];
        self.fetchedResults = [[[FetchedResults alloc]
            initWithDataUtils:self.dataUtils
                 templateName:self.requestTemplateName
             substitutingVars:self.templateSubstitutionVariables
                     sortedBy:self.keySortedFirst
                    ascending:self.sortFirstAscending
                    isSection:self.hasSections
                       thenBy:self.keySortedSecond
                    ascending:self.sortSecondAscending
        ] autorelease];
    }
    return __fetchedResults;
}


/** This setter is needed because this property is privately redeclared as
    "readwrite". (Redeclaring "readonly" as "retain" is not permitted.)
    We handle releasing and retaining as usual.
*/
- (void) setFetchedResults:(FetchedResults*)newVal {
    [__fetchedResults release];
    __fetchedResults = [newVal retain];
}


/** If not set, produces a string like "keySortedFirst/keySortedSecond".
    Otherwise, returns this property's value, which was probably set in the
    User Defined Runtime Attributes section of IB. The self.keySortedFirst
    property cannot be nil or empty, but self.keySortedSecond can be. In that
    case, this method just returns the value of self.keySortedFirst.
*/
- (NSString*) cellReuseIdentifier {
    if ( ! [__cellReuseIdentifier isNotBlank] ) {
        self.cellReuseIdentifier = [self.keySortedSecond isNotBlank]
        ?   [self.keySortedFirst
                stringByAppendingFormat:@"/%@", self.keySortedSecond
            ]
        :   self.keySortedFirst;
    }
    return  __cellReuseIdentifier;
}


#pragma mark - Methods implementing protocol UITableViewDataSource


- (UITableViewCell*)
                tableView:(UITableView*)tableView
    cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    //  We'll need the data for this cell. Retrive it now so the User Defined
    //  Runtime Attributes are validatated first thing.
    id dataObj = [self.fetchedResults objectAtIndexPath:indexPath];
    
    UITableViewCell* cell = [tableView
        dequeueReusableCellWithIdentifier:self.cellReuseIdentifier
    ];
    NSAssert1(
        cell,
        @"Couldn't create a UITableViewCell. In the storyboard, find the Identifier field of the Attributes Inspector for the Table View Cell prototype. It must have value \"%@\".",
        self.cellReuseIdentifier
    );

    //
    //  Use the managed object at indexPath to fill the cell's labels.
    //
    
    //  If cellTextAttributeName has been set (say, in IB), then assign the
    //  managed object's value for that attribute to cell's main text label.
    //  Otherwise, just assign the object's description to the text label.
    cell.textLabel.text = [self.cellTextAttributeName isNotBlank]
    ?   [dataObj valueForKeyPath:self.cellTextAttributeName]
    :   [dataObj description];
    
    //  If cellDetailTextAttributeName has been set (say, in IB), then assign
    //  the managed object's value for that attribute to cell's detail label.
    //  Otherwise, don't assign anything, i.e., leave the label blank.
    if ( self.cellDetailTextAttributeName ) {
        cell.detailTextLabel.text = [dataObj
            valueForKeyPath:self.cellDetailTextAttributeName
        ];
    }
    
    return  cell;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    ERR_ASSERT( [self.fetchedResults performFetch:&ERR] );
    return  [self.fetchedResults.sections count];
}


- (NSInteger)
                tableView:(UITableView*)tableView
    numberOfRowsInSection:(NSInteger)sectIndex
{
    return  [[self.fetchedResults.sections objectAtIndex:(NSUInteger)sectIndex]
        numberOfObjects
    ];
}


/*  Provides the list of titles to appear in the section index on the right
    side of the screen. Returns nil (does NOT show an index) unless the
    current number of sections is at least self.numSectionsForShowingIndex.
*/
- (NSArray*) sectionIndexTitlesForTableView:(UITableView*)tableView {
    return
        [self numberOfSectionsInTableView:tableView] >=
                self.numSectionsForShowingIndex
        ?   [self.fetchedResults sectionIndexTitles]
        :   nil;
}


- (NSInteger)
                      tableView:(UITableView*)tableView
    sectionForSectionIndexTitle:(NSString*)title
                        atIndex:(NSInteger)index
{
    return  [self.fetchedResults
        sectionForSectionIndexTitle:title
                            atIndex:index
    ];
}


/*  Provides the title for each section. If this method is not implemented,
    no sections will appear.
*/
- (NSString*)
                  tableView:(UITableView*)tableView
    titleForHeaderInSection:(NSInteger)sectIndex
{
    return  [[self.fetchedResults.sections objectAtIndex:sectIndex] name];
}


#pragma mark - Private methods and functions


- (void) validateState {
    NSAssert(
        [self.requestTemplateName isNotBlank],
        @"FetchedResultsTableDataSource's requestTemplateName property is nil or empty. You can define its value in IB's Identity Inspector for this FetchedResultsTableDataSource object. Add it in the 'User Defined Runtime Attributes' section."
    );
    NSAssert(
        [self.keySortedFirst isNotBlank],
        @"FetchedResultsTableDataSource's keySortedFirst property is nil or empty. You can define its value in IB's Identity Inspector for this FetchedResultsTableDataSource object. Add it in the 'User Defined Runtime Attributes' section."
    );
}


@end
