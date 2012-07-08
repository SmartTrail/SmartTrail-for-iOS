//
// Created by tyler on 2012-07-03.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface NSFileManager (NSFileManager_Utils)


/** Creates a URL that has the app's temp. directory as an ancestor. The given
    pathname is essentially appended to temp. directory's URL, and the result
    returned.
*/
- (NSURL*) tmpURLEndingInPathComponent:(NSString*)name;


/** Creates a URL that has the app's cache directory as an ancestor. The given
    pathname is essentially appended to the cache directory's URL, and the
    result returned.
*/
- (NSURL*) cacheURLEndingInPathComponent:(NSString*)name;


/** Decompresses the zip-compressed file indicated by zipURL. The contents
    are placed in a new directory located at destURL. If a directory already
    exists there, it and its contents are removed. If the decompression is
    successful, the file indicated by zipURL is removed. Returns YES iff the
    decompression is successful.

    This method depends upon the Objective-Zip library.
*/
- (BOOL) unzip:(NSURL*)zipURL intoNewDirAtURL:(NSURL*)destURL;


@end
