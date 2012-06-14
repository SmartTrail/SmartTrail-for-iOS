//
//  Created by tyler on 2012-04-28.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LinkingWebViewDelegate.h"
#import "NSString+Utils.h"
#import APP_DELEGATE_H

@interface LinkingWebViewDelegate ()
@property (readwrite,nonatomic)         NSManagedObject*  managedObjectForURL;
@property (readwrite,weak,nonatomic)    UIWebView*        webView;
- (void)
    pushControllerOrSegueForIdentifier:(NSString*)ident
                     withManagedObject:(NSManagedObject*)manObj;
@end


@implementation LinkingWebViewDelegate


@synthesize viewController = __viewController;
@synthesize requestTemplateName = __requestTemplateName;
@synthesize destinationIdentifier = __destinationIdentifier;
@synthesize managedObjectForURL = __managedObjectForURL;
@synthesize webView = __webView;
@synthesize dataUtils = __dataUtils;


- (void) awakeFromNib {
    NSAssert(
        self.viewController,
        @"LinkingWebViewDelegate's viewController outlet must be connected to a UIViewController."
    );
    NSAssert(
        [self.requestTemplateName isNotBlank],
        @"LinkingWebViewDelegate's requestTemplateName property is nil or empty. You can define its value in IB's Identity Inspector for this FetchedResultsTableDataSource object. Add it in the 'User Defined Runtime Attributes' section."
    );
}


#pragma mark - Accessors


- (CoreDataUtils*) dataUtils {
    if ( ! __dataUtils )  self.dataUtils = THE(dataUtils);
    return  __dataUtils;
}


#pragma mark - Partial implementation of protocol UIWebViewDelegate


- (BOOL)
                       webView:(UIWebView*)webView
    shouldStartLoadWithRequest:(NSURLRequest*)request
                navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldLoad = YES;

    if ( navigationType == UIWebViewNavigationTypeLinkClicked ) {
        shouldLoad = NO;

        NSManagedObject* foundObj = [self managedObjectForURL:[request URL]];
        if ( foundObj ) {
            //  This is a URL we can handle. Push a new view controller.

            NSString* destIdent = [self
                destinationIdentifierForURL:[request URL]
            ];

            //  These values may be used by the pushed view controller to update
            //  its state.
            self.destinationIdentifier = destIdent;
            self.managedObjectForURL = foundObj;
            self.webView = webView;

            [self
                pushControllerOrSegueForIdentifier:destIdent
                                 withManagedObject:foundObj
            ];

        } else {
            //  Let the system open the URL.
            [[UIApplication sharedApplication] openURL:[request URL]];
        }
    }

    return  shouldLoad;
}


#pragma mark - Calculating where to go and what data to show


- (NSString*) destinationIdentifierForURL:(NSURL*)url {
    return  self.destinationIdentifier;
}


- (NSManagedObject*) managedObjectForURL:(NSURL*)url {
    return [[self.dataUtils
                         find:self.requestTemplateName
        substitutionVariables:[NSDictionary
                                dictionaryWithObject:[url relativeString]
                                              forKey:@"url"
                              ]
    ] lastObject];
}


#pragma mark - Private methods and functions


- (void)
    pushControllerOrSegueForIdentifier:(NSString*)ident
                     withManagedObject:(NSManagedObject*)manObj
{
    //  Unfortunately, there is no API for querying the storyboard for a
    //  view controller or segue having a given identifier. We'll just have to
    //  try to create a view controller with the identifier, and if that fails,
    //  instead try to perform the segue with the identifier.
    //
    @try {
        //  First look for view controller. This throws exception on failure.
        UIViewController* newViewController = [[self.viewController storyboard]
            instantiateViewControllerWithIdentifier:ident
        ];

        //  Found the view controller. Initialize and push it.
        [newViewController
            setValue:manObj
              forKey:[manObj.entity.name decapitalizedString]
        ];
        [self.viewController.navigationController
            pushViewController:newViewController animated:YES
        ];

    } @catch ( NSException* viewControllerNotFound ) {
        //  No controller for ident, so find a segue for ident and perform it.

        @try {
            [self.viewController
                performSegueWithIdentifier:ident sender:self
            ];

        } @catch ( NSException* segueNotFound ) {
            NSAssert(
                NO,
                @"No view controller found with identifier '%@', and could not perform a segue having that identifier. Check in IB that a segue has that identifier, and check that your implementation of prepareForSegue:sender: in class %@ handles '%@'.",
                ident,
                [self.viewController class],
                ident
            );
        }
    }
}


@end
