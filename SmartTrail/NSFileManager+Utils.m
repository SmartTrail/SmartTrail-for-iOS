//
// Created by tyler on 2012-07-03.
//

#import "NSFileManager+Utils.h"
#import "FileInZipInfo.h"
#import "ZipReadStream.h"


@implementation NSFileManager (NSFileManager_Utils)


- (NSURL*) tmpURLEndingInPathComponent:(NSString*)name {
    return [[NSURL fileURLWithPath:NSTemporaryDirectory()]
        URLByAppendingPathComponent:name
    ];
}


- (NSURL*) cacheURLEndingInPathComponent:(NSString*)name {
    NSURL* cacheDirURL = nil;
    ERR_ASSERT(
        cacheDirURL = [self
              URLForDirectory:NSCachesDirectory
                     inDomain:NSUserDomainMask
            appropriateForURL:nil
                       create:YES
                        error:&ERR
        ]
    );
    return [cacheDirURL URLByAppendingPathComponent:name];
}


- (BOOL) unzip:(NSURL*)zipURL intoNewDirAtURL:(NSURL*)destURL {
    BOOL successful = NO;

    //  Remove old destination directory, if present.
    [self removeItemAtURL:destURL error:nil];

    //  Make a new, empty dir. to hold unzipped contents.
    ERR_ASSERT(
        [self
                   createDirectoryAtURL:destURL
            withIntermediateDirectories:NO
                             attributes:nil
                                  error:&ERR
        ]
    );

    //  Decompress file at zipURL into directory destURL.
    //
    ZipFile* zipFile = nil;
    @try {
        zipFile = [[ZipFile alloc]
            initWithFileName:[zipURL path]
                        mode:ZipFileModeUnzip
        ];
        for ( FileInZipInfo *info in zipFile.listFileInZipInfos ) {

            [zipFile locateFileInZip:info.name];
            ZipReadStream* reader = [zipFile readCurrentFileInZip];
            NSData* unzipData  = [reader
                readDataOfLength:info.length
            ];
            [reader finishedReading];

            [unzipData
                writeToURL:[destURL
                             URLByAppendingPathComponent:info.name
                           ]
                atomically:YES
            ];
        }
        successful = YES;

        //  Delete the zip file.
        [self removeItemAtURL:zipURL error:nil];

    } @catch ( NSException* e ) {
        NSAssert( NO, @"Couldn't decompress URL %@", zipURL );

    } @finally {
        [zipFile close];
    }
    return  successful;
}


@end
