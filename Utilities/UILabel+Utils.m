//
//  Created by tyler on 2012-03-12.
//
//


#import <CoreGraphics/CoreGraphics.h>
#import "UILabel+Utils.h"

#define HIGHEST_PT_SZ 20
static CGFloat FudgeForPtSz[HIGHEST_PT_SZ + 2] = {
    [0 ... 7] = 0.0,
    3.0, -1.0, 8.0, 5.0, 2.0, -1.0, 11.0, 10.0, 8.0, 6.0, 3.0, 1.0, -2.0,
    //                                   Value for HIGHEST_PT_SZ is ^^^^
    0.0  // <-- Extra value to allow for interpolation at HIGHEST_PT_SZ.
};
CGFloat fudge( CGFloat pointSize );


@implementation UILabel (Utils)


- (CGFloat) minHeightWanted {
    CGSize withLabelWidth = CGSizeMake(self.bounds.size.width, CGFLOAT_MAX);

    CGSize textSize = [self.text
             sizeWithFont:self.font
        constrainedToSize:withLabelWidth
            lineBreakMode:self.lineBreakMode
    ];
    return  textSize.height + fudge( self.font.pointSize );
}


- (CGFloat) moreHeightWanted {
    CGFloat more = [self minHeightWanted] - self.bounds.size.height;
    return  more >= 0.0  ?  more  :  0.0;
}


#pragma mark - Private methods and functions


/** This function is just a hack to adjust for what a UILabel does when its
    height is readjusted. Assume the UILabel has adjustsFontSizeToFitWidth to
    NO. Say its text doesn't fit, and the part showing is drawn at a certain
    vertical position y. If its height is expanded to that returned by method
    sizeWithFont:constrainedToSize:lineBreakMode:, the text will fit, but will
    be drawn starting too high at y-d1, where d1 is just a few pixels. If its
    height is expanded a bit more, the text will be drawn starting at y. Great!
    But if it's expanded a bit more still, the text will be drawn at y+d2, a
    few pixels too low.

    This function just interpolates a compensating "fudge factor" from the array
    FudgeForPtSz. The values in the array were discovered simply by trial and
    error. The given point size should be between 8 and 20. The value returned
    for sizes outside this range will be 0, except for sizes between 7 and 8
    and between 20 and 21. These are interpolated towards 0 at 7 and 21,
    respectively.
*/
CGFloat fudge( CGFloat pointSize ) {
    double intgPart;
    double fracPart = modf( (double)pointSize, &intgPart );
    int idx = (int)intgPart;

    return  idx <= HIGHEST_PT_SZ
    ?   FudgeForPtSz[idx] + (
            FudgeForPtSz[idx+1] - FudgeForPtSz[idx]
        )*fracPart
    :   0.0;
}


@end
