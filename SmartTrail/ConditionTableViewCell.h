//
//  ConditionTableViewCell.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-03-09.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Condition.h"

@interface ConditionTableViewCell : UITableViewCell

@property (retain,nonatomic) IBOutlet UILabel*     updatedAtLabel;
@property (retain,nonatomic) IBOutlet UILabel*     authorLabel;
@property (retain,nonatomic) IBOutlet UILabel*     commentLabel;
@property (retain,nonatomic) IBOutlet UIImageView* ratingImageView;

- (void) willShowManagedObject:(Condition*)condition;

@end
