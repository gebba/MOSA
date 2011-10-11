//
//  MOSDownloadOperation.m
//  MOSA
//
//  Created by Johan Sjölin on 10/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MOSDownloadOperation.h"

NSString *const KVOKeyPercentDownloaded = @"percentDownloaded";

@implementation MOSDownloadOperation
@synthesize percentDownloaded, executing, finished;

- (id)initWithURL:(NSURL *)url andFilePath:(NSString *)path
{
    self = [super init];
    if (self) {
        [self setExecuting:NO];
        [self setFinished:NO];
        filePath = [path retain];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        fileData = [[NSMutableData alloc] init];
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [self setPercentDownloaded:0.0f];
    }
    return self;
}

- (void)start
{
    [self setExecuting:YES];
    [connection start];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)registerPercentDownloadedObserver:(id)observer
{
    [self addObserver:observer 
           forKeyPath:KVOKeyPercentDownloaded 
              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
              context:nil];
}

- (void)unregisterPercentDownloadedObserver:(id)observer
{
    [self removeObserver:observer forKeyPath:KVOKeyPercentDownloaded];
}

#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    expectedBytes = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [fileData appendData:data];
    [self setPercentDownloaded:[fileData length]/expectedBytes];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [fileData writeToFile:filePath atomically:YES];
    [self setExecuting:NO];
    [self setFinished:YES];
}

@end
