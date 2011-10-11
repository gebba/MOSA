//
//  MOSAppDelegate.h
//  MOSA
//
//  Created by Johan Sjölin on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MOSServerWindowController;

@interface MOSAppDelegate : NSObject <NSApplicationDelegate> {
    MOSServerWindowController *serverWindowController;
}

@property (assign) IBOutlet NSWindow *window;

@end
