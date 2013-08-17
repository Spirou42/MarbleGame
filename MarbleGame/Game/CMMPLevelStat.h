//
//  CMMPLevelStat.h
//  MarbleGame
//
//  Created by Carsten Müller on 8/17/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CMMPLevelSet, CMMarblePlayer;

@interface CMMPLevelStat : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic) int16_t order;
@property (nonatomic) int64_t score;
@property (nonatomic, retain) NSString * scoreMode;
@property (nonatomic) int16_t status;
@property (nonatomic) float time;
@property (nonatomic) int32_t comboHits;
@property (nonatomic) int32_t multiHits;
@property (nonatomic, retain) CMMPLevelSet *levelset;
@property (nonatomic, retain) CMMarblePlayer *player;

@end
