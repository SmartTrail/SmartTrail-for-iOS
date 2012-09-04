//
// Created by tyler on 2012-08-01.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


/** Given the path to a KML directory or the URL of the "doc.kml" file it must
    contain, an instance of this class lazily parses this data into an array
    of CLLocation objects.
*/
@interface KMLParser : NSObject<NSXMLParserDelegate>


/** The file URL provided to initWithFileURL: indicating the KML file to parse.
    The value comes from method initWithFileURL: or method initWithDirPath:,
    where the latter's argument refers to a directory containing a file named
    "doc.kml".
*/
@property (readonly,strong,nonatomic) NSURL*             url;


/** An array of CLLocation objects generated from the sequence of "gx:coord" and
    "when" elements parsed from the KML data. Thus, each element contains both
    3-D coordinate and time data and is in the order found in the KML. When
    this property is first read (or if only a nil value has been read
    previously) the parsing of the KML file actually takes place and the
    resulting array of locations, if non-nil, is cached. Subsequent reads
    return the cached array. Returns nil if self.url is nil, self.url refers to
    a file that doesn't exist, or no locations could be parsed from the file.
    Thus, the returned array, if non-nil, is guaranteed to be non-empty.
*/
@property (readonly,strong,nonatomic) NSMutableArray*    locations;


/** Designated initializer taking the URL of the file to be parsed. No parsing
    is done yet. See method doParse.
*/
- (id) initWithFileURL:(NSURL*)url;


/** Takes the file path of a DIRECTORY containing a file named "doc.kml".
*/
- (id) initWithDirPath:(NSString*)path;


@end
