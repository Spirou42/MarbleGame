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

@class CMMarbleSimulationLayer, CCScale9Sprite, CCControlButton, CMMarbleLevelStatistics,CCNode;

@interface CMMarblePlayScene : CCScene <CMMarbleGameDelegate>
{
  @protected
  CMMarbleSimulationLayer*								_simulationLayer;
  CCScale9Sprite*													_menu;
  CCControlButton*												_menuButton;
  CCControlButton*												_toggleSimulationButton;
	NSInteger																_normalHits,_comboHits,_multiHits;
	CMMarbleLevelStatistics*								_currentStatistics;
  CCNode*																	_statisticsOverlay;
	CCNode<CCLabelProtocol,CCRGBAProtocol>*	_comboMarkerLabel;
	NSTimeInterval													_lastDisplayTime;
	NSTimer*																_marbleDelayTimer;
	NSMutableSet*														_marblesInGame;
	NSDate*																	_levelStartTime;
	CCSprite*																_backgroundSprite;
	CCSprite*																_foregroundSprite;
	CCSprite*																_overlaySprite;

}
@property (nonatomic, retain) CMMarbleSimulationLayer* simulationLayer;
@property (nonatomic, assign) NSInteger normalHits, comboHits, multiHits;
@property (nonatomic, retain) CMMarbleLevelStatistics *currentStatistics;
@property (nonatomic, retain) CCNode* statisticsOverlay;
@property (nonatomic, retain) CCNode<CCLabelProtocol,CCRGBAProtocol> *comboMarkerLabel;
@property (nonatomic, assign) NSTimeInterval lastDisplayTime;
@property (nonatomic, retain) NSTimer* marbleDelayTimer;
@property (nonatomic, retain) NSMutableSet* marblesInGame;
@property (nonatomic, retain) NSDate* levelStartTime;
@property (nonatomic, retain) CCSprite* backgroundSprite;
@property (nonatomic, retain) CCSprite* foregroundSprite;
@property (nonatomic, retain) CCSprite* overlaySprite;
- (void) simulationStepDone:(NSTimeInterval)dt;
@end
 