//
//  CMMPLevelSet.h
//  MarbleGame
//
//  Created by Carsten Müller on 8/17/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CMMPLevelStat, CMMarblePlayer;

@interface CMMPLevelSet : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) CMMarblePlayer *player;
@property (nonatomic, retain) NSSet *levels;
@end

@interface CMMPLevelSet (CoreDataGeneratedAccessors)

- (void)addLevelsObject:(CMMPLevelStat *)value;
- (void)removeLevelsObject:(CMMPLevelStat *)value;
- (void)addLevels:(NSSet *)values;
- (void)removeLevels:(NSSet *)values;

@end
