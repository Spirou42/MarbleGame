//
//  CMMarblePlayer.h
//  MarbleGame
//
//  Created by Carsten Müller on 7/25/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMMarbleLevelStatistics;
@interface CMMarblePlayer : NSObject <NSCoding>

+(id) playerWithName:(NSString*)userName;
-(id) initWithName:(NSString*)userName;
@property (nonatomic,retain) NSString* name;
@property (nonatomic,assign) NSUInteger currentLevel;

//@property (nonatomic,retain) NSDictionary* levelSetStatistics;

//@property (nonatomic,readonly) NSSet* playedLevelSets;

//- (NSSet*) playedLevelsInSet:(NSString*) setName;
//- (CMMarbleLevelStatistics*) statisticsForLevel:(NSString*)levelName inSet:(NSString*)setName;

@end
