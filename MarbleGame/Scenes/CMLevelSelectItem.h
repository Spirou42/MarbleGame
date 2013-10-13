//
//  CMLevelSelectItem.h
//  MarbleGame
//
//  Created by Carsten Müller on 10/7/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMActionLayer.h"

typedef enum {
	kLevelState_Locked = -1,
	kLevelState_Unfinished = 0,
	kLevelState_Star1 = 1,
	kLevelState_Star2 = 2,
	kLevelState_Star3 = 3,
}LevelSelectState;

@class CCSprite;
@interface CMLevelSelectItem : CMActionLayer

@property (nonatomic,retain) CCSprite *icon;

@property (nonatomic,retain) NSString *name;
@property (nonatomic,assign) LevelSelectState levelState;

@end
