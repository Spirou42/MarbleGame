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
{
  @protected
  CMMarbleSimulationLayer*								_simulationLayer;
  CCScale9Sprite*													_menu;
  CCControlButton*												_menuButton;
  CCControlButton*												_toggleSimulationButton;
	NSInteger																_normalHits,_comboHits,_multiHits;
  CCNode*                                 _effectsNode;                         // nodes holding current effects

	CMMPLevelStat*													_currentStatistics;
  CCNode*																	_statisticsOverlay;
	NSTimeInterval													_lastDisplayTime;
	NSTimer*																_marbleDelayTimer;
	NSMutableSet*														_marblesInGame;
	NSDate*																	_levelStartTime;
	CCSprite*																_backgroundSprite;
	CCSprite*																_foregroundSprite;
	CCSprite*																_overlaySprite;
	CMMarbleSlot*														_marbleSlot;
	CCNode<CCLabelProtocol,CCRGBAProtocol>*	_scoreLabel;
	CCNode<CCLabelProtocol,CCRGBAProtocol>*	_timeLabel;
	CCNode<CCLabelProtocol,CCRGBAProtocol>*	_remarkLabel;
  CMMenuLayer                             *_menuLayer;
	CMMenuLayer															*_resultMenu;
	
	NSMutableArray													*_effectQueue;
	NSMutableArray													*_removedMarbleQueue;
	NSObject<CMMarbleGameScoreModeProtocol>	* _scoreDelegate;
	NSTimer																	*_effectTimer;
	NSInteger																_lastUpdateSecond;
	NSInteger																_lastUpdateScore;
}
@property (nonatomic, retain) CMMarbleSimulationLayer* simulationLayer;
@property (nonatomic, assign) NSInteger normalHits, comboHits, multiHits;
@property (nonatomic, retain) CCNode* effectsNode;
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
@property (nonatomic, retain) CMMenuLayer *menuLayer;
@property (nonatomic, retain) NSObject<CMMarbleGameScoreModeProtocol>* scoreDelegate;
@property (nonatomic, retain) NSTimer* effectTimer;
@property (nonatomic, retain) CMMenuLayer *resultMenu;

- (void) simulationStepDone:(NSTimeInterval)dt;
@end
 