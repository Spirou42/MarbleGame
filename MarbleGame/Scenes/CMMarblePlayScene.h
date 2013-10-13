//
//  PlayScene.h
//  CocosTest1
//
//  Created by Carsten Müller on 6/29/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CCScene.h"
#import "Cocos2d.h"
#import "CMMarbleGameDelegate.h"

@protocol CMMarbleGameScoreModeProtocol;
@class CMMarbleSimulationLayer, CCScale9Sprite, CCControlButton, CMMarbleLevelStatistics,CCNode,CMMarbleSlot, CMMenuLayer, CMMPLevelStat;

@interface CMMarblePlayScene : CCScene <CMMarbleGameDelegate>
@property (nonatomic, retain) CMMarbleSimulationLayer* simulationLayer;
@property (nonatomic, assign) NSInteger normalHits, comboHits, multiHits;
@property (nonatomic, retain) CCNode* effectsNode;	// for particles
@property (nonatomic, retain) CCNode* spriteEffectsNode; // for sprites
@property (nonatomic, retain) CCNode* marbleEffectsNode; // for particels
@property (nonatomic, retain) CMMPLevelStat *currentStatistics;
@property (nonatomic, retain) CCNode* statisticsOverlay;
@property (nonatomic, retain) CCNode<CCLabelProtocol,CCRGBAProtocol> *comboMarkerLabel;
@property (nonatomic, assign) NSTimeInterval lastDisplayTime;
@property (nonatomic, retain) NSTimer* marbleDelayTimer;
@property (nonatomic, retain) NSMutableSet* marblesInGame;
@property (nonatomic, retain) NSDate* levelStartTime;
@property (nonatomic, retain) CCSprite* backgroundSprite;
@property (nonatomic, retain) CCSprite* foregroundSprite;
@property (nonatomic, retain) CCSprite* overlaySprite;
@property (nonatomic, retain) CCNode<CCLabelProtocol,CCRGBAProtocol> *scoreLabel,*timeLabel,*remarkLabel;
@property (nonatomic, retain) NSMutableArray* effectQueue;
@property (nonatomic, retain) CMMarbleSlot* marbleSlot;
@property (nonatomic, retain) NSMutableArray *removedMarbleQueue;

@property (nonatomic, retain) CCControlButton* menuButton;
@property (nonatomic, retain) CMMenuLayer *menuLayer;
@property (nonatomic, assign) CCControlButton* toggleSimulationButton;

@property (nonatomic, retain) NSObject<CMMarbleGameScoreModeProtocol>* scoreDelegate;
@property (nonatomic, retain) NSTimer* effectTimer;
@property (nonatomic, retain) CMMenuLayer *resultMenu;

@property (nonatomic, assign) NSInteger lastUpdateSecond, lastUpdateScore;
- (void) simulationStepDone:(NSTimeInterval)dt;
@end
 