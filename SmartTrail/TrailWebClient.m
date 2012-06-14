//
//  Created by tyler on 2012-03-21.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TrailWebClient.h"
#import "AppDelegate.h"


@implementation TrailWebClient


- (id) initWithDataUtils:(CoreDataUtils*)utils regionId:(NSInteger)regionId {
    self = [super initWithDataUtils:utils entityName:@"Trail"];
    if ( self ) {

        self.urlString = [NSString
            stringWithFormat:@"%@trailsAPI/regions/%d/trails",
                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BmaBaseUrl"],
                regionId
        ];

        __weak TrailWebClient* unretained_self = self; // Avoid retain cycle.
        __weak CoreDataUtils* unretained_utils = utils;
        self.propConverter = [utils
            dataDictToPropDictConverterForEntityName:@"Trail"
                                usingFuncsByPropName:[NSDictionary
                dictionaryWithObjectsAndKeys:

                    //  This calculation using               goes into property
                    //    the data dictionary                  having this name.

                    fnIntegerForDataKey(@"aerobicRating"),   @"aerobicRating",
                    fnIntegerForDataKey(@"coolRating"),      @"coolRating",
                    fnRawForDataKey(@"description"),         @"descriptionPartial",
                    fnIntegerForDataKey(@"elevationGain"),   @"elevationGain",
                    fnFloatForDataKey(@"length"),            @"length",
                    fnIntegerForDataKey(@"techRating"),      @"techRating",
                    fnDateSince1970ForDataKey(@"updatedAt"), @"updatedAt",

                    //  When this dictionary is handed to CoreDataUtil's
                    //  updateOrInsertThe:withProperties: method, serverTime
                    //  will contain the response's Date. So just report it.
                    //
                    [^(id _1, id _2) {
                        return  unretained_self.serverTime;
                    } copy],                                 @"downloadedAt",

                    //  All that remains is to populate the "area" relationship.
                    //  For this to work, The Area entities must already have
                    //  been loaded.
                    //
                    [^( NSDictionary* dataDict, id _ ){
                        return  [unretained_utils
                            findThe:@"AreaForId"
                                 at:[dataDict objectForKey:@"area"]
                        ];
                    } copy],                                 @"area",

                    fnCoerceDataKey(nil),                    AnyOtherProperty,

                    nil                              ]
        ];
    }
    return  self;
}


@end
