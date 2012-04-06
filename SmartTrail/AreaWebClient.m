//
//  Created by tyler on 2012-03-20.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "AreaWebClient.h"
#import "AppDelegate.h"


@implementation AreaWebClient


- (id) initWithDataUtils:(CoreDataUtils*)utils regionId:(NSInteger)regionId {
    self = [super initWithDataUtils:utils entityName:@"Area"];
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
