//
//  AppDelegate.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2011-12-10.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMAController.h"
#import "CoreDataUtils.h"

@interface AppDelegate :
    NSObject<UIApplicationDelegate,CoreDataProvisions>

@property (strong,nonatomic)   UIWindow*      window;
@property (readonly,nonatomic) BMAController* bmaController;
@property (readonly,nonatomic) CoreDataUtils* dataUtils;

- (NSURL*) applicationDocumentsDirectory;
- (UIImage*)
    imageForRating:(NSInteger)rating
           inRange:(NSInteger)lo
           through:(NSInteger)hi;

@end

#define APP_DELEGATE   ((AppDelegate*)[[UIApplication sharedApplication] \
                           delegate                                      \
                       ])
#define THE(propName)  [APP_DELEGATE propName]
