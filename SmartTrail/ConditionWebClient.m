//
//  Created by tyler on 2012-03-22.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ConditionWebClient.h"
#import "AppDelegate.h"


@implementation ConditionWebClient


- (id) initWithDataUtils:(CoreDataUtils*)utils regionId:(NSInteger)regionId {
    self = [super initWithDataUtils:utils entityName:@"Condition"];
    if ( self ) {

        //  Default: Just get all conditions in region 1.
        self.urlString = [NSString
            stringWithFormat:@"%@trailsAPI/regions/1/conditions",
                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BmaBaseUrl"]
        ];

        __block ConditionWebClient* unretained_self = self; // Avoid retain cycle.
        __block CoreDataUtils* unretained_utils = utils;
        self.propConverter = [utils
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
                        return  unretained_self.serverTime;
                    } copy] autorelease],                    @"downloadedAt",

                    //  All that remains is to populate the "trail" relationship.
                    //  For this to work, The Trail entities must already have
                    //  been loaded.
                    //
                    [[^( NSDictionary* dataDict, id _ ){
                        return  [unretained_utils
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


- (id) initWithDataUtils:(CoreDataUtils*)utils areaId:(NSString*)areaId {
    self = [self initWithDataUtils:utils regionId:1];
    if ( self ) {
        self.urlString = [NSString
            stringWithFormat:@"%@trailsAPI/areas/%@/conditions",
                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BmaBaseUrl"],
                areaId
        ];
    }
    return  self;
}


@end
