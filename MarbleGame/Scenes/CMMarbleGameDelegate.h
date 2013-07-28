//
//  CMMarbleGameDelegate.h
//  MarbleGame
//
//  Created by Carsten Müller on 7/28/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CMMarbleGameDelegate <NSObject>

@required
	- (NSUInteger) marbleIndex;
	- (NSString*) marbleSetName;
	// called by the game simluation view in case a marble is new in the game
	- (void) marbleInGame;
@end
