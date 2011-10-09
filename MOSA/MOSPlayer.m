//
//  MOSPlayer.m
//  MOSA
//
//  Created by Johan Sjölin on 10/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MOSPlayer.h"

@implementation MOSPlayer
@synthesize name;

- (id)initWithName:(NSString *)playerName
{
    self = [super init];
    if (self) {
        [self setName:playerName];
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[MOSPlayer class]] && [self.name isEqual:[(MOSPlayer *)object name]];
}

@end
