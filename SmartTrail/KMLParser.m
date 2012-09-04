//
// Created by tyler on 2012-08-01.
//


#import <MapKit/MapKit.h>
#import "KMLParser.h"
#import "CollectionUtils.h"
#import "NSDate+Utils.h"

@interface KMLParser ()
- (BOOL) doParse;
@end


@implementation KMLParser


{
    NSMutableString* __currentChars;
    NSMutableArray*  __whenStrings;
    NSMutableArray*  __gxCoordStrings;
}
@synthesize url = __url;
@synthesize locations = __locations;


- (id) initWithFileURL:(NSURL*)url {
    self = [super init];
    if ( self ) {
        __url = url;
        if ( url ) {
            __whenStrings    = [[NSMutableArray alloc] initWithCapacity:128];
            __gxCoordStrings = [[NSMutableArray alloc] initWithCapacity:128];
        }
    }
    return self;
}


- (id) initWithDirPath:(NSString*)path {
    NSURL* dirURL =  path
    ?   [NSURL fileURLWithPath:path isDirectory:YES]
    :   nil;
    return [self initWithFileURL:[dirURL URLByAppendingPathComponent:@"doc.kml"]];
}


- (NSMutableArray*) locations {
    if (
        ! __locations  &&           // Haven't successfully parsed yet.
        [self doParse]              // The parse was successful now.
    ) {

        __locations = map2(

            ^( NSString* whenStr, NSString* gxCoordStr ){
                NSArray* locs = [gxCoordStr componentsSeparatedByString:@" "];
                CLLocationDegrees  lon = [[locs objectAtIndex:0] doubleValue];
                CLLocationDegrees  lat = [[locs objectAtIndex:1] doubleValue];
                CLLocationDistance alt = [[locs objectAtIndex:2] doubleValue];
                NSDate* time = [NSDate
                    dateFromString:whenStr inFormat:@"%Y-%m-%dT%H:%M:%S%Z"
                ];

                return  [[CLLocation alloc]
                    initWithCoordinate:CLLocationCoordinate2DMake(lat,lon)
                              altitude:alt
                    horizontalAccuracy:15.0     // Just a guess.
                      verticalAccuracy:15.0     // Just a guess.
                             timestamp:time
                ];
            },

            __whenStrings,
            __gxCoordStrings

        );
        if ( ! [__locations count] )  __locations = nil;
    }

    return __locations;
}


#pragma mark - Partial implementation of protocol NSXMLParserDelegate


- (void)
             parser:(NSXMLParser*)parser
    didStartElement:(NSString*)elementName
       namespaceURI:(NSString*)namespaceURI
      qualifiedName:(NSString*)qName
         attributes:(NSDictionary*)attributeDict
{
    if (
        [elementName isEqualToString:@"when"]  ||
        [elementName isEqualToString:@"gx:coord"]
    ) {
        //  We can't be inside BOTH "when" and "gx:coord" elems., so just use
        //  the same accumulator for both, __currentChars.
        __currentChars = [NSMutableString new];
    }
}


- (void) parser:(NSXMLParser*)parser foundCharacters:(NSString*)string {
    [__currentChars appendString:string];
}


- (void)
           parser:(NSXMLParser*)parser
    didEndElement:(NSString*)elementName
     namespaceURI:(NSString*)namespaceURI
    qualifiedName:(NSString*)qName
{
    if ( [elementName isEqualToString:@"when"] ) {
        [__whenStrings addObject:__currentChars];
        __currentChars = nil;

    } else if ( [elementName isEqualToString:@"gx:coord"] ) {
        [__gxCoordStrings addObject:__currentChars];
        __currentChars = nil;
    }
}


#pragma mark - Private methods and functions


/** Actually scans the KML file indicated by self.url and assigns data from
    "gx:track" and "when" elements into the state of the receiver.  Returns YES
    iff successful.
*/
- (BOOL) doParse {
    BOOL success = NO;
    if ( [[NSFileManager defaultManager] fileExistsAtPath:self.url.path] ) {
        NSXMLParser* parser = [[NSXMLParser alloc]
            initWithContentsOfURL:self.url
        ];
        parser.delegate = self;
        success = [parser parse];
    }
    return  success;
}


@end
