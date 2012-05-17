//
//  Created by tyler on 2012-04-28.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LinkingWebViewDelegate.h"
#import "NSString+Utils.h"
#import APP_DELEGATE_H

@interface LinkingWebViewDelegate ()
@property (readwrite,retain,nonatomic)  NSManagedObject*  managedObjectForURL;
@property (readwrite,assign,nonatomic)  UIWebView*        webView;
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


- (void) dealloc {
    //  (__viewController is not retained)
                                        __viewController = nil;
    [__requestTemplateName release];    __requestTemplateName = nil;
    [__destinationIdentifier release];  __destinationIdentifier = nil;
    [__managedObjectForURL release];    __managedObjectForURL = nil;
    [__webView release];                __webView = nil;
    [__dataUtils release];              __dataUtils = nil;

    [super dealloc];
}


/** This method is called if the receiver was created from a storyboard.
    As this class is normally used, the receiver instance does not need
    anything referring to it except the UIWebView for which it is the delegate.
    It just sits as a top-level object with a connection from the UIWebView's
    delegate outlet. But since UIWebView's delegate property does not retain its
    object, the receiver will not have an owner and will be released. Therefore,
    we retain it here, causing it to live for the lifetime of the app.
*/
- (void) awakeFromNib {
    NSAssert(
        self.viewController,
        @"WebViewDelegate's viewController outlet must be connected to a UIViewController."
    );
    NSAssert(
        [self.requestTemplateName isNotBlank],
        @"WebViewDelegate's requestTemplateName property is nil or empty. You can define its value in IB's Identity Inspector for this FetchedResultsTableDataSource object. Add it in the 'User Defined Runtime Attributes' section."
    );
    [self retain];
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
    UIViewController* newViewController = [[self.viewController storyboard]
        instantiateViewControllerWithIdentifier:ident
    ];

    if ( newViewController ) {
        //  Found a view controller with given identifier. Push it.

        [newViewController
            setValue:manObj
              forKey:[manObj.entity.name decapitalizedString]
        ];
        [self.viewController.navigationController
            pushViewController:newViewController animated:YES
        ];

    } else {
        //  No controller for ident, so find a segue for ident and perform it.

        @try {
            [self.viewController
                performSegueWithIdentifier:ident sender:self
            ];

        } @catch ( NSException* exception ) {
            NSAssert(
                NO,
                @"Could find neither a UIViewController nor a UIStoryboardSegue having identifier '%@'. Use IB's Attributes inspector to assign it.",
                self.destinationIdentifier
            );
        }
    }
}


@end
