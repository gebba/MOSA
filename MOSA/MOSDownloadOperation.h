//
//  MOSDownloadOperation.h
//  MOSA
//
//  Created by Johan Sjölin on 10/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const KVOKeyPercentDownloaded;

@interface MOSDownloadOperation : NSOperation <NSURLConnectionDelegate> {
    NSURLConnection *connection;
    NSString *filePath;
    NSMutableData *fileData;
    NSInteger expectedBytes;
}

@property (nonatomic) float percentDownloaded;
@property (nonatomic, getter = isExecuting) BOOL executing;
@property (nonatomic, getter = isFinished) BOOL finished;

- (id)initWithURL:(NSURL *)url andFilePath:(NSString *)path;

- (void)registerPercentDownloadedObserver:(id)observer;
- (void)unregisterPercentDownloadedObserver:(id)observer;

@end
