//
// Created by tyler on 2012-08-01.
//


#import <MapKit/MapKit.h>
#import "KMLParser.h"
#import "CollectionUtils.h"
#import "NSDate+Utils.h"

@interface KMLParser ()
@property (readwrite,strong,nonatomic) NSURL*          url;
@property (readwrite,strong,nonatomic) NSMutableArray* locations;
@end


@implementation KMLParser


{
    NSMutableString* __currentChars;
    NSMutableArray*  __whenStrings;
    NSMutableArray*  __gxCoordStrings;
}
@synthesize url = __url;
@synthesize locations = __locations;


+ (MKPolylineView*) trackOverlayViewForURL:(NSURL*)url {
    KMLParser* kmlParser = [[self alloc] initWithURL:url];
    return  [kmlParser doParse] ? [kmlParser trackOverlayView] : nil;
}


- (id) initWithURL:(NSURL*)url {
    self = [super init];
    if ( self ) {
        self.url = url;
        __whenStrings    = [[NSMutableArray alloc] initWithCapacity:128];
        __gxCoordStrings = [[NSMutableArray alloc] initWithCapacity:128];
    }
    return self;
}


- (BOOL) doParse {
    if ( [__whenStrings count]  ||  [__gxCoordStrings count] ) {
        NSAssert( NO, @"This %@ instance is already used. Make a new one.", [self class] );
        return  NO;

    } else {
        NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:self.url];
        parser.delegate = self;
        return  [parser parse];
    }
}


- (MKPolylineView*) trackOverlayView {

    self.locations = map2(
        ^( NSString* whenStr, NSString* gxCoordStr ){
            NSArray* locStrings = [gxCoordStr componentsSeparatedByString:@" "];
            double lon = [[locStrings objectAtIndex:0] doubleValue];
            double lat = [[locStrings objectAtIndex:1] doubleValue];
            double alt = [[locStrings objectAtIndex:2] doubleValue];
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

    NSUInteger locationsCount = [self.locations count];
    CLLocationCoordinate2D* buffPtr = malloc(
        sizeof( CLLocationCoordinate2D ) * locationsCount
    );

    [self.locations enumerateObjectsUsingBlock:^(id loc, NSUInteger idx, BOOL* stop){
        buffPtr[idx] = ((CLLocation*)loc).coordinate;
    }];

    //  Copy coordinates in buffPtr into a new MKPolyline object.
    MKPolyline* poly = [MKPolyline
        polylineWithCoordinates:buffPtr count:locationsCount
    ];
    free( buffPtr );

    return  [[MKPolylineView alloc] initWithPolyline:poly];
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


@end
