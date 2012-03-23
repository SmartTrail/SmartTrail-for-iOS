//
//  Created by tyler on 2012-03-22.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ConditionWebClient.h"
#import "AppDelegate.h"


@implementation ConditionWebClient


- (id) init {
    self = [super initWithDataUtils:THE(dataUtils) entityName:@"Condition"];
    if ( self ) {

        //  Default: Just get all conditions in region 1.
        self.urlString = [NSString
            stringWithFormat:@"%@trailsAPI/regions/1/conditions",
                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BmaBaseUrl"]
        ];

        self.propConverter = [THE(dataUtils)
            dataDictToPropDictConverterForEntityName:@"Condition"
                                usingFuncsByPropName:[NSDictionary
                dictionaryWithObjectsAndKeys:

                    //  This calculation using               goes into property
                    //    the data dictionary                  having this name.

                    fnStringForDataKey(@"nickname"),         @"authorName",
                    fnIntegerForDataKey(@"conditionId"),     @"rating",
                    fnDateSince1970ForDataKey(@"updatedAt"), @"updatedAt",

                    //  When this dictionary is handed to CoreDataUtil's
                    //  updateOrInsertThe:withProperties: method, serverTime
                    //  will contain the response's Date. So just report it.
                    //
                    [[^(id _1, id _2) {
                        return  self.serverTime;
                    } copy] autorelease],                    @"downloadedAt",

                    //  All that remains is to populate the "trail" relationship.
                    //  For this to work, The Trail entities must already have
                    //  been loaded.
                    //
                    [[^( NSDictionary* dataDict, id _ ){
                        return  [THE(dataUtils)
                            findThe:@"TrailForId"
                                 at:[dataDict objectForKey:@"trailId"]
                        ];
                    } copy] autorelease],                    @"trail",

                    fnCoerceDataKey(nil),                    AnyOtherProperty,

                    nil                              ]
            ];
    }
    return self;
}


- (id) initWithAreaId:(NSInteger)areaId {
    self = [self init];
    if ( self ) {

        self.urlString = [NSString
            stringWithFormat:@"%@trailsAPI/areas/%d/conditions",
                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BmaBaseUrl"],
                areaId
        ];

    }
    return  self;
}


@end
