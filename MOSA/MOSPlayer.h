//
//  MOSPlayer.h
//  MOSA
//
//  Created by Johan Sjölin on 10/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOSPlayer : NSObject

@property (retain) NSString *name;

- (id)initWithName:(NSString *)playerName;

@end
