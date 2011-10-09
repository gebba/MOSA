//
//  ServerWrapper.m
//  Minecraft Server
//
//  Created by Johan Sjölin on 8/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MOSServerWrapper.h"
#import "RegexKitLite.h"
#import "MOSPlayer.h"

static NSTask *theServer;

static NSString *const ChatMsgRegex = @".?+INFO.?+ <([a-zA-Z0-9]+)> (.+)$";
static NSString *const PlayerListRegex = @"Connected players: ([a-zA-Z0-9].+)";
static NSString *const PlayerCountRegex = @"^Player count: ([+\\-]?[0-9]+)";
static NSString *const PlayerJoinedRegex = @".?+INFO.?+ ([a-zA-Z0-9]+) .+ logged in$";
static NSString *const PlayerDisconnectedRegex = @".?+INFO.?+ ([a-zA-Z0-9]+) lost connection: .+";

@implementation MOSServerWrapper
@synthesize delegate, running, lastJoined, players;

- (id)initWithDelegate:(id<MOSServerWrapperDelegate>)newDelegate {

	self = [super init];
	
	[self reloadSettings];
	
	self.running = NO;
	
	[self setupServerTask];
	
	return self;
	
}

-(id)init {

	self = [super init];
	
	self.running = NO;
	
	[self setupServerTask];
	
	// Setup notification center to listen for a "Server did terminate notification"
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveServerTerminatedNotification) name:NSTaskDidTerminateNotification object:theServer];
	
	return self;
	
}

- (void)setupServerTask {
	
	if (theServer != nil) {
		[theServer release];
		theServer = nil;
	}
	
	//NSTask *newServer = 
	
	theServer = [[NSTask alloc] init];
	
	[theServer setLaunchPath:@"/bin/sh"];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *settingsFolderPath = [documentsDirectory stringByAppendingPathComponent:@"MinecraftServerSettings"];
	NSString *settingsServerBinariesPath = [settingsFolderPath stringByAppendingPathComponent:@"server"];
	NSString *serverBinaryPath = [settingsServerBinariesPath stringByAppendingPathComponent:@"minecraft_server.jar"];
	
	NSMutableString *launchRegular = [NSMutableString stringWithFormat:@"java -Xmx%dM -Xms%dM -jar \"%@\" nogui", javaMem, javaMem, serverBinaryPath];
	
	NSArray *arguments = [NSArray arrayWithObjects:
						  @"-c", launchRegular, nil];
	
	[theServer setArguments:arguments];
	
	[theServer setCurrentDirectoryPath:settingsServerBinariesPath];
	
	if (outputPipe != nil) {
		[outputPipe release];
		outputPipe = nil;
	}
	
	outputPipe = [[NSPipe alloc] init];
	[theServer setStandardOutput:outputPipe];
	outputDataSrc = [outputPipe fileHandleForReading];
	
	if (errorPipe != nil) {
		[errorPipe release];
		errorPipe = nil;
	}
	
	errorPipe = [[NSPipe alloc] init];
	[theServer setStandardError:errorPipe];
	errorDataSrc = [errorPipe fileHandleForReading];
	
	if (inputPipe != nil) {
		[inputPipe release];
		inputPipe = nil;
	}
	
	inputPipe = [[NSPipe alloc] init];
	[theServer setStandardInput:inputPipe];
	inputDataSrc = [inputPipe fileHandleForWriting];
	
	// Setup notification center to listen for a "Server did terminate notification"
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveServerTerminatedNotification) name:NSTaskDidTerminateNotification object:theServer];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievedData:) name:NSFileHandleReadCompletionNotification object:outputDataSrc];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievedData:) name:NSFileHandleReadCompletionNotification object:errorDataSrc];
}
	 
- (void)recievedData:(NSNotification*)notification {
	
	NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
	
	NSMutableString *string = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSArray *stringArray = [string componentsSeparatedByString:@"\n"];

	for (NSString *newString in stringArray) {
		if (![newString isEqualToString:@""]) {
			
			if ([newString isMatchedByRegex:PlayerListRegex]) {
				NSString *playerListString = [newString stringByMatching:PlayerCountRegex capture:1L];
				NSArray *playerListArray = [playerListString componentsSeparatedByString:@", "];
				[delegate serverWrapperPlayersListed:playerListArray];
			} else if ([newString isMatchedByRegex:PlayerJoinedRegex]) {
                MOSPlayer *player = [[MOSPlayer alloc] initWithName:[newString stringByMatching:PlayerJoinedRegex capture:1L]];
                [players addObject:player];
                [player release];
			} else if ([newString isMatchedByRegex:ChatMsgRegex]) {
				[delegate serverWrapperChatMessageReceivedFrom:[newString stringByMatching:ChatMsgRegex capture:1L]
													   message:[newString stringByMatching:ChatMsgRegex capture:2L]];
			} else if ([newString isMatchedByRegex:PlayerDisconnectedRegex]) {
				[delegate serverWrapperPlayerDisconnected:[newString stringByMatching:PlayerDisconnectedRegex capture:1L]];
			}

			
			[self debug:[NSString stringWithFormat:@"%@\n", newString]];
		}
	}
	
	[outputDataSrc readInBackgroundAndNotify];
	[errorDataSrc readInBackgroundAndNotify];
	[string release];
	
}

- (void)startServer {

	if (!self.isRunning) {
		[theServer launch];
		[outputDataSrc readInBackgroundAndNotify];
		[errorDataSrc readInBackgroundAndNotify];
		[self debug:@"Server launched\n"];
		self.running = YES;
	} else if (self.isRunning) {
		[self debug:@"Server is already running\n"];
	}

	
}

- (void)stopServer {
	
	if (self.isRunning) {
		[self doCommand:@"stop"];
		self.running = NO;
	} else if (!self.isRunning) {
		[self debug:@"Server not started yet\n"];
	}

	
}

- (void)reloadSettings {
	
	// Load settings, and create new settings file if it does not exist
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *settingsFolderPath = [documentsDirectory stringByAppendingPathComponent:@"MinecraftServerSettings"];
	NSString *settingsPath = [settingsFolderPath stringByAppendingPathComponent:@"ServerSettings.plist"];
	
	NSMutableDictionary *serverSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
	
	int tempJavaMem = [[serverSettings objectForKey:@"MaxJavaMemory"] intValue];
	
	if (tempJavaMem != javaMem) {
		[self debug:@"Java memory settings changed, restart server for changes to have effect\n"];
	}
	
	javaMem = [[serverSettings objectForKey:@"MaxJavaMemory"] intValue];
	
}

#pragma mark Server commands

- (void)doCommand:(NSString*)command {
	
	NSString *newCommand = [NSString stringWithFormat:@"%@\n", command];
	
	[inputDataSrc writeData:[NSData dataWithData:[newCommand dataUsingEncoding:NSUTF8StringEncoding]]];
	
}

- (void)say:(NSString*)message {

	[self doCommand:[NSString stringWithFormat:@"say %@", message]];
	
}

- (void)saveOn {

	[self doCommand:@"save-on"];
	
}

- (void)saveOff {

	[self doCommand:@"save-off"];
	
}

- (void)saveAll {
	
	[self doCommand:@"save-all"];
	
}

- (void)givePlayer:(NSString*)playerName item:(int)itemId count:(int)itemCount {
	
	[self doCommand:[NSString stringWithFormat:@"give %@ %d %d", playerName, itemId, itemCount]];
	
}

- (void)kickPlayer:(NSString*)playerName {

	[self doCommand:[NSString stringWithFormat:@"kick %@", playerName]];
	
}

- (void)didReceiveServerTerminatedNotification {

	[self debug:@"Server terminated\n"];
	[self setupServerTask];
	self.running = NO;
	
}

- (void)debug:(NSString*)message {
	
	if (delegate != nil) {
		[delegate serverWrapperDidSendMessage:message];
	}
	
}

+ (NSTask*)theServerTask {

	return theServer;
	
}

- (void)dealloc {
    [(NSObject*)delegate release];
	[theServer terminate];
	[theServer release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
