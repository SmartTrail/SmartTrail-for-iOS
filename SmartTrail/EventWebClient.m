//
//  Created by tyler on 2012-03-23.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "EventWebClient.h"
#import "AppDelegate.h"


@implementation EventWebClient


- (id) init {
    return  [self initWithRegionId:1];
}


- (id) initWithRegionId:(NSInteger)regionId {
    self = [super initWithDataUtils:THE(dataUtils) entityName:@"Event"];
    if ( self ) {

        self.urlString = [NSString
            stringWithFormat:@"%@trailsAPI/regions/%d/events",
                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BmaBaseUrl"],
                regionId
        ];

        self.propConverter = [THE(dataUtils)
            dataDictToPropDictConverterForEntityName:@"Event"
                                usingFuncsByPropName:[NSDictionary
                dictionaryWithObjectsAndKeys:

                    //  This calculation using               goes into property
                    //    the data dictionary                  having this name.

                    fnDateSince1970ForDataKey(@"updatedAt"),      @"updatedAt",
                    fnDateSince1970ForDataKey(@"startTimestamp"), @"startAt",
                    fnDateSince1970ForDataKey(@"endTimestamp"),   @"endAt",

                    //  When this dictionary is handed to CoreDataUtil's
                    //  updateOrInsertThe:withProperties: method, serverTime
                    //  will contain the response's Date. So just report it.
                    //
                    [[^(id _1, id _2) {
                        return  self.serverTime;
                    } copy] autorelease],                         @"downloadedAt",

                    fnCoerceDataKey(nil),                         AnyOtherProperty,

                    nil                              ]
        ];
    }
    return  self;
}


@end
