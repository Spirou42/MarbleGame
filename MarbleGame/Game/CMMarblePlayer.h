//
//  CMMarblePlayer.h
//  MarbleGame
//
//  Created by Carsten Müller on 8/17/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CMMPLevelSet, CMMPLevelStat, CMMPSettings;

@interface CMMarblePlayer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic) int16_t currentLevel;
@property (nonatomic, retain) NSString * currentLevelSet;
@property (nonatomic, retain) NSSet *levelSets;
@property (nonatomic, retain) CMMPSettings *settings;
@property (nonatomic, retain) CMMPLevelStat *currentLevelStat;
@end

@interface CMMarblePlayer (CoreDataGeneratedAccessors)

- (void)addLevelSetsObject:(CMMPLevelSet *)value;
- (void)removeLevelSetsObject:(CMMPLevelSet *)value;
- (void)addLevelSets:(NSSet *)values;
- (void)removeLevelSets:(NSSet *)values;

@end
