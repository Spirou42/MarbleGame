//
//  CMMarbleGameScoreModeProtocol.h
//  MarbleGame
//
//  Created by Carsten Müller on 8/14/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

/**
 This protocol describes the interface of an object which can decide about the how many points a player scores or if the level was finished successfully.
 */

#import <Foundation/Foundation.h>

typedef enum {
	kCMLevelStatus_Unfinished 	= -1,
	kCMLevelStatus_Failed				=  0,
	kCMLevelStatus_Amateure			=  1,
	kCMLevelStatus_Professional =  2,
	kCMLevelStatus_Master				=	 3,
}CMMarbleGameLevelStatus;

@class CMMarbleLevel,CMMarbleLevelStatistics,CMMarblePlayerOld;
@protocol CMMarbleGameDelegate;

@protocol CMMarbleGameScoreModeProtocol <NSObject>

@required
@property (nonatomic, assign) NSObject<CMMarbleGameDelegate>* gameDelegate;

- (void) scoreWithMarbles:(NSArray*)removedMarbles inLevel:(CMMarbleLevelStatistics*)statistics;
- (void) marbleDropped:(CMMarbleLevelStatistics*)statistics;
- (void) marbleFired;

@end