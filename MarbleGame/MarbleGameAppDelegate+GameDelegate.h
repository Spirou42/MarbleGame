//
//  MarbleGameAppDelegate+GameDelegate.h
//  MarbleGame
//
//  Created by Carsten Müller on 7/30/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "AppDelegate.h"
@class CMMarbleLevelSet;
@interface MarbleGameAppDelegate (GameDelegate)

- (void) registerUserDefaults;
- (void) initializeMarbleGame;

- (CMMarblePlayer*) currentPlayer;

@end
