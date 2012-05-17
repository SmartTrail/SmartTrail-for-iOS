//
//  Created by tyler on 2012-04-28.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "CoreDataUtils.h"

/** This class makes it very easy to intercept user taps on links in a web view
    and transition to a detail view of the managed object associated with the
    URL of the link. You should normally not need to instantiate this class
    programmatically. Just use Interface Builder to drag an "Object" cube icon
    onto your view controller's dock. In the Identity Inspector, give it class
    LinkingWebViewDelegate and define User Defined Runtime Attributes
    requestTemplateName and destinationIdentifier. Connect your web view's
    delegate outlet to the cube, and connect the cube's viewController outlet
    to your view controller. Of course, you must also define a fetch request
    template in the Object Modeling Tool with the same name as that in
    requestTemplateName, and in Interface Builder you must assign an identifier
    matching the one in destinationIdentifier to the desired destination view
    controller or segue object.

    This class implements the method of protocol UIWebViewDelegate called
    webView:shouldStartLoadWithRequest:navigationType:. The method returns YES
    unless the given navigation type is UIWebViewNavigationTypeLinkClicked, when
    it returns NO. So if the user taps a link, the method intercepts it and
    calls method managedObjectForURL: to obtain a managed object corresponding
    to the URL of the tapped link. If none is found, the system is called upon
    to open the URL. For example, if the URL is http://www.apple.com/, Safari
    will come up and open that page, putting your app in the background.

    If a managed object IS found corresponding to the tapped URL, method
    destinationIdentifierForURL: is called to map the URL to an identifier
    string. The identifier must match the identifier of a view controller or
    a segue in the storyboard of the UIViewController connected to the
    viewController outlet. A view controller matching the identifier is used if
    it is found, otherwise a segue matching the identifier is used.

    If a view controller matches, then its property named after the entity of
    the managed object is assigned the managed object. Now the view controller
    knows which managed object it should use to render its view. Finally, the
    view controller is pushed onto the self.viewController.navigationController
    stack of view controllers and its view is displayed.

    For example, if destinationIdentifierForURL: returned "addrView" and the
    managed object's entity is named "HomeAddress", then the view controller
    with identifier "addrView" must have property "homeAddress", since it will
    be assigned the managed object. Note that the property name is the same as
    the entity name, except possibly for its first character which must be lower
    case.

    If there is no view controller in self.viewController.storyboard with a
    matching identifier, there must be a segue with a matching identifier.
    Then self.viewController is told to perform the segue. This
    LinkingWebViewDelegate is passed as well, which then appears as the sender
    in the call to self.viewController's prepareForSegue:sender: method. Your
    implementation can then access the sender's managedObjectForURL, webView,
    or destinationIdentifier to render the view.

    Note that it is currently impossible to define a segue transitioning from
    a view controller to itself. This ought to be doable, but until Apple
    implements it, if you want to transition from a scene to another instance
    of the same scene, you'll need to assign the identifier to the scene's view
    controller, not to a segue.
*/
@interface LinkingWebViewDelegate : NSObject<UIWebViewDelegate>


#pragma mark - Properties assigned in Interface Builder


/** The UIViewController of the scene containing the web view whose link the
    user will tap. If its identifier is equal to the string in property
    destinationIdentifier, then another instance of it can be pushed onto its
    navigation controller.
*/
@property (assign,nonatomic) IBOutlet UIViewController* viewController;


/**
*/
@property (copy,nonatomic)            NSString*         requestTemplateName;


/** Unless you override method destinationIdentifierForURL:, the identifers of
    view controllers and segues of self.viewController's storyboard will be
    searched for the string in this property to find the scene we are taken to.
    Assign its value in the User Defined Runtime Attributes section of the
    Identity Inspector in Interface Builder.
*/
@property (copy,nonatomic)            NSString*         destinationIdentifier;


#pragma mark - Data available to self.viewController when segue is performed
//  The following properties will contain data of interest to
//  self.viewController's implementation of method prepareForSegue:sender:.
//  Just query the sender: argument.


/** The managed object associated with the URL of the link the user tapped,
    assigned by method managedObjectForURL:.
*/
@property (readonly,retain,nonatomic) NSManagedObject*  managedObjectForURL;


/** The UIWebView in which the user tapped a link.
*/
@property (readonly,assign,nonatomic) UIWebView*        webView;


/** The CoreDataUtils object used by method managedObjectForURL: to find the
    managed object associated with the tapped link's URL. The
    NSManagedObjectContext used is thus available in self.dataUtils.context.
*/
@property (retain,nonatomic)          CoreDataUtils*    dataUtils;


#pragma mark - Calculating where to go and what data to show


/** Subclasses may override this method to determine the view controller to be
    pushed when a link to the given URL is tapped. By default, this
    implementation simply returns the value of self.destinationIdentifier, which
    is presumably a User Defined Runtime Attribute assigned in Interface Builder.
*/
- (NSString*) destinationIdentifierForURL:(NSURL*)url;


/** Subclasses may override this method to determine the managed object to be
    used by the destination view controller when it is pushed. By default, this
    implementation returns one of the managed objects obtained by the fetch
    request defined by self.requestTemplateName with the given URL.
*/
- (NSManagedObject*) managedObjectForURL:(NSURL*)url;


@end
