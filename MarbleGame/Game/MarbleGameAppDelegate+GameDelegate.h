//
//  MarbleGameAppDelegate+GameDelegate.h
//  MarbleGame
//
//  Created by Carsten Müller on 7/30/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "AppDelegate.h"
@class CMMarbleLevelSet;
@protocol CMMarbleGameScoreModeProtocol;

@interface MarbleGameAppDelegate (GameDelegate)

- (void) registerUserDefaults;
- (void) initializeMarbleGame;

- (CMMarblePlayerOld*) currentPlayer;
- (void) setCurrentPlayer:(CMMarblePlayerOld*)player;
- (NSObject<CMMarbleGameScoreModeProtocol>*)currentScoreDelegate;

@property (nonatomic, retain) CMMarblePlayerOld *currentPlayer;

@end
