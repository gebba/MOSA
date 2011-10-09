//
//  MOSServerWindowController.h
//  MOSA
//
//  Created by Johan Sjölin on 10/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MOSServerWindowController : NSWindowController

@property (retain) IBOutlet NSLevelIndicator *playerCountIndicator;
@property (retain) IBOutlet NSTableView *playerTableView;
@property (retain) IBOutlet NSTextField *consoleOutputView;
@property (retain) IBOutlet NSTextField *consoleInputView;

@end
