//
// Created by tyler on 2012-08-01.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface KMLParser : NSObject<NSXMLParserDelegate>


@property (readonly,strong,nonatomic) NSURL*           url;
@property (readonly,strong,nonatomic) NSMutableArray*  locations;


/** Convenience method that parses the KML file at the given URL and generates a
    poly-line overlay view from the track information found there. If the file
    cannot be parsed, returns nil.
*/
+ (MKPolylineView*) trackOverlayViewForURL:(NSURL*)url;

- (id) initWithURL:(NSURL*)url;
- (BOOL) doParse;
- (MKPolylineView*) trackOverlayView;


@end
