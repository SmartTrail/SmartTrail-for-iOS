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
@property (nonatomic,readwrite,retain) NSFetchedResultsController* fetchedResults;
@property (nonatomic,retain)           NSDictionary*               prevSubstVars;
- (void) validateState;
- (Class) fetchedResultsClassWithName:(NSString*)name;
@end


@implementation FetchedResultsTableDataSource


@synthesize dataUtils = __dataUtils;
@synthesize fetchedResults = __fetchedResults;
@synthesize fetchedResultsClassName = __fetchedResultsClassName;
@synthesize requestTemplateName = __requestTemplateName;
@synthesize templateSubstitutionVariables = __templateSubstitutionVariables;
@synthesize keySortedFirst = __keySortedFirst;
@synthesize sortFirstAscending = __sortFirstAscending;
@synthesize hasSections = __hasSections;
@synthesize keySortedSecond = __keySortedSecond;
@synthesize sortSecondAscending = __sortSecondAscending;
@synthesize cellTextAttributePath = __cellTextAttributePath;
@synthesize cellDetailTextAttributePath = __cellDetailTextAttributePath;
@synthesize cellReuseIdentifier = __cellReuseIdentifier;
@synthesize numSectionsForShowingIndex = __numSectionsForShowingIndex;
@synthesize delegate = __delegate;
@synthesize prevSubstVars = __prevSubstVars;


- (void) dealloc {
    [__dataUtils release];                     __dataUtils = nil;
    [__fetchedResults release];                __fetchedResults = nil;
    [__fetchedResultsClassName release];       __fetchedResultsClassName = nil;
    [__requestTemplateName release];           __requestTemplateName = nil;
    [__templateSubstitutionVariables release]; __templateSubstitutionVariables = nil;
    [__keySortedFirst release];                __keySortedFirst = nil;
    [__keySortedSecond release];               __keySortedSecond = nil;
    [__cellTextAttributePath release];         __cellTextAttributePath = nil;
    [__cellDetailTextAttributePath release];   __cellDetailTextAttributePath = nil;
    [__cellReuseIdentifier release];           __cellReuseIdentifier = nil;
    [__delegate release];                      __delegate = nil;
    [__prevSubstVars release];                 __prevSubstVars = nil;

    [super dealloc];
}


- (void) awakeFromNib {
    NSAssert(
        [self.keySortedFirst isNotBlank],
        @"FetchedResultsTableDataSource's keySortedFirst property is nil or empty. You can define its value in IB's Identity Inspector for this FetchedResultsTableDataSource object. Add it in the 'User Defined Runtime Attributes' section."
    );
    NSAssert(
        [self.requestTemplateName isNotBlank],
        @"FetchedResultsTableDataSource's requestTemplateName property is nil or empty. You can define its value in IB's Identity Inspector for this FetchedResultsTableDataSource object. Add it in the 'User Defined Runtime Attributes' section."
    );
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
        val != oldVal                                  // Handles val == nil.
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


- (NSFetchedResultsController*) fetchedResults {

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
            vars  &&  ! [vars isEqualToDictionary:self.prevSubstVars]
        )
    ) {
        [self validateState];

        //  Save substitution vars. in order to compare (above) the next time.
        self.prevSubstVars = [[vars copy] autorelease];

        //  Configure a new fetch request for the new NSFetchedResultsController
        //  we will create below.
        //
        NSFetchRequest* req = [self.dataUtils
            requestFor:self.requestTemplateName substitutionVariables:vars
        ];
        {   NSSortDescriptor* sort1 = [NSSortDescriptor
                sortDescriptorWithKey:self.keySortedFirst
                            ascending:self.sortFirstAscending
            ];
            if ( [self.keySortedSecond isNotBlank] ) {
                NSSortDescriptor* sort2 = [NSSortDescriptor
                    sortDescriptorWithKey:self.keySortedSecond
                                ascending:self.sortSecondAscending
                ];
                req.sortDescriptors = [NSArray arrayWithObjects:sort1,sort2,nil];

            } else {
                req.sortDescriptors = [NSArray arrayWithObject:sort1];
            }
        }

        //  Create the new NSFetchedResultsController, which may be a subclass
        //  designated by name in self.fetchedResultsClassName.
        //
        self.fetchedResults = [[[[self
            fetchedResultsClassWithName:self.fetchedResultsClassName
        ] alloc]
            initWithFetchRequest:req
            managedObjectContext:self.dataUtils.context
              sectionNameKeyPath:(self.hasSections ? self.keySortedFirst : nil)
                       cacheName:nil
        ] autorelease];

        __fetchedResults.delegate = self.delegate;
    }

    return __fetchedResults;
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
    //  We'll need the data for this cell. Retrieve it now so the User Defined
    //  Runtime Attributes are validated first thing.
    id dataObj = [self.fetchedResults objectAtIndexPath:indexPath];

    UITableViewCell* cell = [tableView
        dequeueReusableCellWithIdentifier:self.cellReuseIdentifier
    ];
    NSAssert(
        cell,
        @"Couldn't create a UITableViewCell. In the storyboard, find the Identifier field of the Attributes Inspector for the Table View Cell prototype. It must have value \"%@\".",
        self.cellReuseIdentifier
    );

    //
    //  Use the managed object at indexPath to fill the cell's labels.
    //

    //  If cellTextAttributeName has been set (say, in IB), then assign the
    //  managed object's value for that attribute to cell's main text label.
    if ( [self.cellTextAttributePath isNotBlank] ) {
        cell.textLabel.text =
            [[dataObj valueForKeyPath:self.cellTextAttributePath] description];
    }

    //  If cellDetailTextAttributeName has been set (say, in IB), then assign
    //  the managed object's value for that attribute to cell's detail label.
    //  Otherwise, don't assign anything, i.e., leave the label blank.
    if ( [self.cellDetailTextAttributePath isNotBlank] ) {
        cell.detailTextLabel.text = [[dataObj
            valueForKeyPath:self.cellDetailTextAttributePath
        ] description];
    }

    SEL willShowManagedObjectSEL = @selector( willShowManagedObject: );
    if ( [cell respondsToSelector:willShowManagedObjectSEL] ) {
        //  Here we accommodate a custom table view cell by sending it the
        //  managed object data. Presumably, it would assign values to labels
        //  it manages, etc.
        [cell performSelector:willShowManagedObjectSEL withObject:dataObj];
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
    return  [[self.fetchedResults.sections objectAtIndex:(NSUInteger)sectIndex]
        name
    ];
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


/** Find the class of the given name and ensure it is a subclass of
    NSFetchedResultsController. If the name is nil, just return class
    NSFetchedResultsController.
*/
- (Class) fetchedResultsClassWithName:(NSString*)name {
    Class theClass = name
    ?   NSClassFromString(name)
    :   [NSFetchedResultsController class];

    NSAssert( theClass, @"No class by name '%@' is currently loaded. Check the fetchedResultsClassName property in the 'User Defined Runtime Attributes' section of IB's Identity Inspector for this FetchedResultsTableDataSource object. If present, it must be the name of a defined subclass of NSFetchedResultsController.", name );
    NSAssert(
        [theClass isSubclassOfClass:[NSFetchedResultsController class]],
        @"%@ is not a subclass of NSFetchedResultsController, as required. Check the fetchedResultsClassName property in the 'User Defined Runtime Attributes' section of IB's Identity Inspector for this FetchedResultsTableDataSource object.",
        theClass
    );

    return theClass;
}


@end
