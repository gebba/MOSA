//
//  MOSFolderPaths.h
//  MOSA
//
//  Created by Johan Sjölin on 10/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOSFolderPaths : NSObject

+ (NSString *)applicationStoragePath;
+ (NSString *)serverFolderPath;
+ (NSString *)serverJarPath;

@end
