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

@class CMMarbleLevel,CMMPLevelStat;
@protocol CMMarbleGameDelegate;

@protocol CMMarbleGameScoreModeProtocol <NSObject>

@required
@property (nonatomic, assign) NSObject<CMMarbleGameDelegate>* gameDelegate;
@property (nonatomic, readonly) CGFloat lastScore;
- (void) scoreWithMarbles:(NSArray*)removedMarbles inLevel:(CMMPLevelStat*)statistics;

- (void) marbleDropped:(CMMPLevelStat*)statistics;
- (void) marbleFired;
- (CMMPLevelStat*) betterStatOfOld:(CMMPLevelStat*) oldStat new:(CMMPLevelStat*)newStat;
- (CMMarbleGameLevelStatus) statusOfLevel:(CMMarbleLevel*)level forStats:(CMMPLevelStat*) statistics;

@end
