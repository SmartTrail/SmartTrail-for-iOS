//
//  FetchedResults.m
//  Places
//
//  Created by Tyler Perkins on 2012-02-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FetchedResults.h"
#import "NSString+Utils.h"


@implementation FetchedResults


@synthesize substitutionVariables = __substitutionVariables;


- (id)
    initWithDataUtils:(CoreDataUtils*)dataUtils
         templateName:(NSString*)tmplName
     substitutingVars:(NSDictionary*)substDict
             sortedBy:(NSString*)key1
            ascending:(BOOL)asc1
            isSection:(BOOL)isSect
               thenBy:(NSString*)key2
            ascending:(BOOL)asc2
{
    NSFetchRequest* req = [dataUtils
        requestFor:tmplName substitutionVariables:substDict
    ];
    NSSortDescriptor* sort1 = [NSSortDescriptor
        sortDescriptorWithKey:key1 ascending:asc1
    ];
    if ( [key2 isNotBlank] ) {
        NSSortDescriptor* sort2 = [NSSortDescriptor
            sortDescriptorWithKey:key2 ascending:asc2
        ];
        req.sortDescriptors = [NSArray arrayWithObjects:sort1,sort2,nil];
        
    } else {
        req.sortDescriptors = [NSArray arrayWithObject:sort1];
    }
    
    self = [super
        initWithFetchRequest:req
        managedObjectContext:dataUtils.context
          sectionNameKeyPath:(isSect ? key1 : nil)
                   cacheName:nil
    ];
    if ( self ) {
        __substitutionVariables = [substDict copy];
    }

    return  self;

}


@end
