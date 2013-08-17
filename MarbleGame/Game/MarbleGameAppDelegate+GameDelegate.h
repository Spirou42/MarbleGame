//
//  MarbleGameAppDelegate+GameDelegate.h
//  MarbleGame
//
//  Created by Carsten Müller on 7/30/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "AppDelegate.h"
@class CMMarbleLevelSet,CMMarblePlayer,CMMPLevelStat,CMMarbleLevel;
@protocol CMMarbleGameScoreModeProtocol;

@interface MarbleGameAppDelegate (GameDelegate)

- (void) registerUserDefaults;
- (void) initializeMarbleGame;

- (CMMarblePlayer*) currentPlayer;
- (NSObject<CMMarbleGameScoreModeProtocol>*)currentScoreDelegate;
- (CMMPLevelStat*) temporaryStatisticFor:(CMMarblePlayer*)player andLevel:(CMMarbleLevel*)level;
- (CMMPLevelStat*) statisticsForPlayer:(CMMarblePlayer*)player andLevel:(CMMarbleLevel*)level;
- (void) addStatistics:(CMMPLevelStat*) stat toPlayer:(CMMarblePlayer*)player;
- (BOOL) player:(CMMarblePlayer*)player hasPlayedLevel:(NSString*)name;

@property (nonatomic, readonly) CMMarblePlayer *currentPlayer;
@property (readonly, strong, nonatomic) NSURL *defaultStoreURL;

@end
