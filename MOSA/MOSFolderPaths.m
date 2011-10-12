//
//  MOSFolderPaths.m
//  MOSA
//
//  Created by Johan Sjölin on 10/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MOSFolderPaths.h"

@implementation MOSFolderPaths

+ (NSString *)applicationStoragePath
{
    NSString *appSupportPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *applicationStoragePath = [appSupportPath stringByAppendingPathComponent:@"MOSA"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:applicationStoragePath]) {
        [fileManager createDirectoryAtPath:applicationStoragePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return applicationStoragePath;
}

+ (NSString *)serverFolderPath
{
    NSString *appStoragePath = [MOSFolderPaths applicationStoragePath];
    NSString *serverFolderPath = [appStoragePath stringByAppendingPathComponent:@"server"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:serverFolderPath]) {
        [fileManager createDirectoryAtPath:serverFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return serverFolderPath;
}

+ (NSString *)serverJarPath
{
    // https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft_server.jar
    NSString *servFolderPath = [MOSFolderPaths serverFolderPath];
    return [[servFolderPath stringByAppendingPathComponent:@"minecraft_server"] stringByAppendingPathExtension:@"jar"];
}

@end
