//
//  Created by tyler on 2012-03-20.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "AreaWebClient.h"
#import "AppDelegate.h"


@implementation AreaWebClient


- (id) init {
    return  [self initWithRegionId:1];
}


- (id) initWithRegionId:(NSInteger)regionId {
    self = [super initWithDataUtils:THE(dataUtils) entityName:@"Area"];
    if ( self ) {
        self.urlString = [NSString
            stringWithFormat:@"%@trailsAPI/regions/%d/areas",
                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BmaBaseUrl"],
                regionId
        ];
    }
    return  self;
}


@end
