//
//  MOSAppDelegate.m
//  MOSA
//
//  Created by Johan Sjölin on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MOSAppDelegate.h"
#import "MOSServerWindowController.h"

@interface MOSAppDelegate()

- (void)loadMainWindowController:(NSTimer *)timer;

@end

@implementation MOSAppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSTimer *splashTimer = [NSTimer timerWithTimeInterval:3 
                                                   target:self
                                                 selector:@selector(loadMainWindowController:) 
                                                 userInfo:nil
                                                  repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:splashTimer forMode:NSDefaultRunLoopMode];
}

- (void)loadMainWindowController:(NSTimer *)timer
{
     serverWindowController = [[MOSServerWindowController alloc] initWithWindowNibName:@"ServerWindow"];
    NSDictionary *fadeOut = [NSDictionary dictionaryWithObjectsAndKeys:
                      self.window, NSViewAnimationTargetKey,
                      NSViewAnimationFadeOutEffect,
                      NSViewAnimationEffectKey, nil];
    
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:fadeOut]];
    [animation setAnimationBlockingMode:NSAnimationBlocking];
    [animation setDuration:1];
    [animation startAnimation];
    [self.window release];
    [self setWindow:serverWindowController.window];
}

@end
