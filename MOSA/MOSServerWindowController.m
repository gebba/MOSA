//
//  MOSServerWindowController.m
//  MOSA
//
//  Created by Johan Sjölin on 10/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MOSServerWindowController.h"

@implementation MOSServerWindowController
@synthesize playerCountIndicator, playerTableView, consoleInputView, consoleOutputView;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
