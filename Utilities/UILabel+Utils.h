//
//  Created by tyler on 2012-03-12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <UIKit/UIKit.h>

@interface UILabel (Utils)

/** Returns the minimum height of the receiver required to fit its text. The
    intention is that when the receiver is too small to show all its text, if
    its height is enlarged to the returned value, all the text is shown and the
    vertical position where it is drawn does not shift. Currently recommended
    only for whole font sizes between 8 and 20, inclusive.
*/
- (CGFloat) minHeightWanted;

/** Returns the number of points the receiver needs to grow in order to show
    all its text. If all its text is already showing, 0.0 is returned. The
    comments and caveats for minHeightWanted apply here too.
*/
- (CGFloat) moreHeightWanted;

@end
