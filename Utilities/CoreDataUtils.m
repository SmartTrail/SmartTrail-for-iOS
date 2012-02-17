//
//  Created by tyler on 2012-01-13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CoreDataUtils.h"
#import "CoreDataProvisions.h"

@interface CoreDataUtils ()
@property (nonatomic,retain) NSObject<CoreDataProvisions>* appDelegate;
@end


@implementation CoreDataUtils


@synthesize appDelegate = __appDelegate;


- (void) dealloc {
    [__appDelegate release];  __appDelegate = nil;
    [super dealloc];
}


- (id) initWithProvisions:(NSObject<CoreDataProvisions>*)appDelegate {
    self = [super init];
    if ( self ) {
        self.appDelegate = appDelegate;
    }
    return  self;
}


- (NSObject<CoreDataProvisions>*) appDelegate {
    if ( ! __appDelegate ) {
        self.appDelegate = (NSObject<CoreDataProvisions>*)[
            [UIApplication sharedApplication] delegate
        ];
    }
    return  __appDelegate;
}


/** Convenience method for instantiation.
*/
+ (id) coreDataUtilsWithProvisions:(NSObject<CoreDataProvisions>*)appDelegate {
    return  [[[self alloc] initWithProvisions:appDelegate] autorelease];
}


/** For the context readonly property.
*/
- (NSManagedObjectContext*) context {
    return  self.appDelegate.managedObjectContext;
}


- (NSManagedObject*)
    findThe:(NSString*)tmplName
         at:(NSString*)idString
      error:(NSError**)error
{
    return  idString
    ?   [self
            findTheOneUsingRequest:[self requestFor:tmplName atId:idString]
                             error:error
        ]
    :   nil;
}


/**
*/
- (NSManagedObject*)
    updateOrInsertThe:(NSString*)tmplName
                   at:(NSString*)idString
       withAttributes:(NSDictionary*)attrDict
                error:(NSError**)errAddr
{
    NSAssert( idString, @"The \"at:\" id string argument must not be nil" );

    NSManagedObjectContext* ctx = self.context;
    NSFetchRequest* req = [self requestFor:tmplName atId:idString];
    NSManagedObject* obj = [self findTheOneUsingRequest:req error:errAddr];
    if ( ! *errAddr ) {
        if ( ! obj ) {
            //  No managed object with the given id was found. Create one.
            NSEntityDescription* entity = [req entity];
            obj = [[(NSManagedObject*)[NSClassFromString([entity name]) alloc]
                                initWithEntity:entity
                insertIntoManagedObjectContext:ctx
            ] autorelease];
        }

        //  Populate the managed object with the given attributes.
        [obj setValuesForKeysWithDictionary:attrDict];
        [obj setValue:idString forKey:@"id"];
    }
    return obj;
}


/** Obtain a request object based on the template of the given name. If the
    template has no substitution variables, pass nil for the second parameter.
*/
- (NSFetchRequest*)
               requestFor:(NSString*)tmplName
    substitutionVariables:(NSDictionary*)substVars
{
    NSFetchRequest* req = [self.appDelegate.managedObjectModel
        fetchRequestFromTemplateWithName:tmplName
                   substitutionVariables:substVars
    ];

    NSAssert( req, @"Request template \"%@\" could not be found.", tmplName );
    return  req;
}


/** Obtain a request object based on the template of the given name.
    The template should have one substitution variable to accept an ID.
    When run, the request will query for the object with the given id value.
*/
- (NSFetchRequest*) requestFor:(NSString*)tmplName atId:(NSString*)idString {
    NSFetchRequest* req = [self
                   requestFor:tmplName
        substitutionVariables:[NSDictionary
                                  dictionaryWithObject:idString
                                                forKey:@"ID"
                              ]
    ];

    NSAssert( req, @"Request template \"%@\" could not be found.", tmplName );
    return  req;
}


/** Runs the given request and returns the single managed object it finds, or
    nil if none is found. If MORE than one object is found, an error is
    assigned at the given error address.
*/
- (NSManagedObject*)
    findTheOneUsingRequest:(NSFetchRequest*)req
                     error:(NSError**)error
{
    NSArray* foundObjs = [self.context
        executeFetchRequest:req error:error
    ];

    if ( *error == nil  &&  [foundObjs count] > 1 ) {
        NSString* msg = [NSString
            stringWithFormat:@"More than one managed object found."
        ];
        *error = [NSError
            errorWithDomain:@"Places Core Data"
                       code:1
                   userInfo:[NSDictionary
                                dictionaryWithObject:msg
                                              forKey:NSLocalizedDescriptionKey
                            ]
        ];
    }

    return  [foundObjs lastObject];
    //  Note that if foundObjs is empty, lastObject returned nil.
    //  If *error != nil, then foundObjs must be nil, so we returned nil.
}


@end
