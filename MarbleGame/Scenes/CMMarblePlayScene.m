//
//  PlayScene.m
//  CocosTest1
//
//  Created by Carsten Müller on 6/29/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMarblePlayScene.h"
#import "CMMarbleSimulationLayer.h"
#import "CMMarbleMainMenuScene.h"
#import "CCControlExtension.h"
#import "SceneHelper.h"
#import "CMMarbleSettingsScene.h"
#import "CMMarbleCollisionCollector.h"
#import "CMMPLevelStat.h"
#import "CMMarbleLevel.h"
#import "CMMarbleLevelSet.h"
#import "CMMarblePlayer.h"
#import "MarbleGameAppDelegate+GameDelegate.h"
#import "CCLabelBMFont+CMMarbleRealBounds.h"
#import "CMMarbleMultiComboSprite.h"
#import "CMMarbleSprite.h"
#import "CMMarbleSlot.h"
#import "CMMenuLayer.h"
#import "CMMarbleGameScoreModeProtocol.h"
#import "CMMPLevelStat+DisplayHelper.h"
#import "SimpleAudioEngine.h"
#import "CocosDenshion.h"
#import "AppDelegate.h"
#import "CMMarblePlayer.h"
#import "CMMPSettings.h"
#import "CMParticleSystemQuad.h"
#import "CMScoreSprite.h"
#import "CMMarblePowerProtocol.h"
#import "CMMarbleEmitter.h"
#import "CMRubeBody.h"

@interface CMMarblePlayScene ()
@property (nonatomic,retain) NSMutableDictionary *particleCache;
@end

@implementation CMMarblePlayScene

@synthesize  simulationLayer=simulationLayer_, normalHits = normalHits_,comboHits=comboHits_,multiHits=multiHits_;
@synthesize effectsNode = effectsNode_,marbleEffectsNode = marbleEffectsNode_,spriteEffectsNode=spriteEffectsNode_;
@synthesize  currentStatistics = currentStatistics_, statisticsOverlay=statisticsOverlay_;
@synthesize  comboMarkerLabel = comboMarkerLabel_, lastDisplayTime = lastDisplayTime_, marbleDelayTimer = marbleDelayTimer_;
@synthesize  marblesInGame=marblesInGame_,levelStartTime = levelStartTime_, backgroundSprite=backgroundSprite_;
@synthesize  foregroundSprite=foregroundSprite_, overlaySprite=overlaySprite_;
@synthesize  scoreLabel=scoreLabel_, timeLabel = timeLabel_, remarkLabel= remarkLabel_;
@synthesize  effectQueue = effectQueue_,marbleSlot=marbleSlot_, removedMarbleQueue = removedMarbleQueue_;
@synthesize  menuButton=menuButton_, menuLayer = menuLayer_,toggleSimulationButton=toggleSimulationButton_;
@synthesize  scoreDelegate = scoreDelegate_, effectTimer = effectTimer_, resultMenu = resultMenu_, lastUpdateScore=lastUpdateScore_, lastUpdateSecond=lastUpdateSecond_;
@synthesize particleCache=particleCache_;

@dynamic playEffect, soundVolume;

- (NSString*) stringForSeconds:(NSTimeInterval) seconds
{
#if __CC_PLATFORM_MAC
	NSString* result = [NSString stringWithFormat:@"%02ld:%02ld",(NSInteger)seconds/60,(NSInteger)seconds%60];
#else
	NSString* result = [NSString stringWithFormat:@"%02d:%02d",(NSInteger)seconds/60,(NSInteger)seconds%60];
#endif
	return result;
}

- (NSString*) currentTimeString
{
	NSTimeInterval dt = -[self.levelStartTime timeIntervalSinceNow];
	NSString *result = [NSString stringWithFormat:@"%lu", (unsigned long)self.simulationLayer.marbleBatchNode.children.count ];
//[self stringForSeconds:dt];
	return result;
}
- (NSString*) currentScoreString
{
	NSString *result = [NSString stringWithFormat:@"%ld",(long)self.currentStatistics.score];
	return result;
}

- (id) init
{
	if( (self = [super init]) ){
		self.backgroundSprite = defaultLevelBackground();

    [self createMenu];
//		[self scheduleUpdate];
    CMMarbleSimulationLayer *l =[CMMarbleSimulationLayer node];
    self.simulationLayer =l;
		self.simulationLayer.gameDelegate = self;
		self.simulationLayer.currentLevel = [self currentLevel];
		self.scoreLabel = defaultGameLabel(@"0");
		self.timeLabel = defaultGameLabel(@"00:00");
		self.effectQueue = [NSMutableArray array];
		self.marbleSlot = [[[CMMarbleSlot alloc] initWithSize:CGSizeMake(284, 28) andDelegate:self]autorelease];
		self.removedMarbleQueue = [NSMutableArray array];
    self.overlaySprite = defaultLevelOverlay();
    self.overlaySprite.anchorPoint=ccp(0.0, 0.0);
    self.overlaySprite.position=ccp(0,0);
    self.particleCache = [NSMutableDictionary dictionary];
#if DEBUG_ALPHA_ON
		self.overlaySprite.opacity = 128;
#endif

    self.effectsNode = [CCNode node ];
    [self addChild:self.effectsNode z:EFFECTS_LAYER];

		self.spriteEffectsNode = [CCNode node];
		[self addChild:self.spriteEffectsNode z:EFFECTS_LAYER];

		
		self.marbleEffectsNode = [CCNode node];
		[self addChild:self.marbleEffectsNode z:MARBLE_EFFECTS_LAYER];

		
#ifdef __CC_PLATFORM_MAC
    self.simulationLayer.mousePriority=1;
#else
    self.simulationLayer.touchPriority=1;
#endif
		
		[self resetSimulationAction:nil];
		self.scoreDelegate = [CMAppDelegate currentScoreDelegate];
		self.levelStartTime = [NSDate date];
		MarbleGameAppDelegate *appDel  = CMAppDelegate;
		CMMarblePlayer *player = appDel.currentPlayer;
		[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:player.settings.musicVolume];
		[[SimpleAudioEngine sharedEngine] setEffectsVolume:player.settings.soundVolume];
	}
	return self;
}
- (void) dealloc
{
	self.levelStartTime = nil;
	[self.marbleDelayTimer invalidate];
	self.marbleDelayTimer = nil;
	[self.effectTimer invalidate];
	self.effectTimer = nil;
	self.currentStatistics = nil;
	self.simulationLayer = nil;
	self.marblesInGame = nil;
	self.backgroundSprite = nil;
	self.foregroundSprite = nil;
	self.overlaySprite = nil;
	self.effectQueue = nil;
	self.marbleSlot = nil;
	self.removedMarbleQueue = nil;

  self.menuLayer = nil;
	self.scoreLabel = nil;
	self.timeLabel = nil;
	self.remarkLabel = nil;
	self.scoreDelegate = nil;
//	self.menuButton = nil;
	self.spriteEffectsNode = nil;
	self.effectsNode = nil;
	self.marbleEffectsNode = nil;
  self.particleCache = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark Properties

- (void) setSimulationLayer:(CMMarbleSimulationLayer *)simLay
{
  if( self->simulationLayer_ != simLay){
    self->simulationLayer_.simulationRunning=NO;
    [self removeChild:self->simulationLayer_ cleanup:YES];

    [self->simulationLayer_ release];
    self->simulationLayer_ = [simLay retain];
		if (simLay) {
			[self addChild:simLay z:MARBLE_LAYER];
		}
  }
}
- (void) addChild:(CCNode *)node z:(NSInteger)z
{
  [super addChild:node z:z];
}

- (CMMarbleSimulationLayer*) simulationLayer
{
  return self->simulationLayer_;
}

- (void) setBackgroundSprite:(CCSprite *)bS
{
	if (self->backgroundSprite_ != bS) {
		[self removeChild:self->backgroundSprite_ cleanup:YES];
		[self->backgroundSprite_ release];
		self->backgroundSprite_ = [bS retain];
		self->backgroundSprite_.anchorPoint = cpv(0.5, 0.5);
		self->backgroundSprite_.position = centerOfScreen()
		;		if (bS) {
			[self addChild:bS z:BACKGROUND_LAYER];
		}
	}
}

- (void) setForegroundSprite:(CCSprite *)fS
{
	if (self->foregroundSprite_ != fS) {
		[self removeChild:self->foregroundSprite_ cleanup:YES];
		[self->foregroundSprite_ release];
		self->foregroundSprite_ = [fS retain];
		self->foregroundSprite_.anchorPoint = cpv(0.5, 0.5);
		self->foregroundSprite_.position = centerOfScreen();
		if (fS) {
			[self addChild:fS z:FOREGROUND_LAYER];
		}
	}
}

- (void) setOverlaySprite:(CCSprite *)oS
{
	if (self->overlaySprite_ != oS) {
		[self removeChild:self->overlaySprite_ cleanup:YES];
		[self->overlaySprite_ release];
		self->overlaySprite_ = [oS retain];
		self->overlaySprite_.anchorPoint=cpv(0.0, 1.0);
		self->overlaySprite_.position=cpv(0.0, 768);
		if (oS) {
			[self addChild:oS z:OVERLAY_LAYER];
		}
	}
}

- (void) setScoreLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol> *)sL
{
	if (self->scoreLabel_ != sL) {
		CGRect realBounds = CGRectZero;
		if ([sL isKindOfClass:[CCLabelBMFont class]]) {
			CCLabelBMFont*p = (CCLabelBMFont*)sL;
			realBounds = [p outerBounds];
		}else
			realBounds = sL.boundingBox;
		
		if (self->scoreLabel_) {
			[self removeChild:self->scoreLabel_];
			[self->scoreLabel_ release];
		}
		self->scoreLabel_ = [sL retain];
		self->scoreLabel_.anchorPoint = cpv(1.0, 0.5);
		if (self->scoreLabel_) {
			[self addChild:self->scoreLabel_ z:OVERLAY_LABEL_LAYER];
		}

		self->scoreLabel_.opacity=0.75 * 255;
		self->scoreLabel_.position=cpv(238, realBounds.size.height/4.0-2);
	}
}
- (void) setTimeLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol> *)tL
{
	if (self->timeLabel_ != tL) {
		CGRect realBounds = CGRectZero;
		if ([tL isKindOfClass:[CCLabelBMFont class]]) {
			CCLabelBMFont*p = (CCLabelBMFont*)tL;
			realBounds = [p outerBounds];
		}else
			realBounds = tL.boundingBox;
		
		if (self->timeLabel_) {
			[self removeChild:self->timeLabel_];
			[self->timeLabel_ release];
		}
		self->timeLabel_ = [tL retain];
		if (self->timeLabel_) {
			[self addChild:self->timeLabel_ z:OVERLAY_LABEL_LAYER];
		}

		self->timeLabel_.opacity=0.75 * 255;
		self->timeLabel_.position=cpv(815, realBounds.size.height/4.0-2);
	}
}

- (void) setRemarkLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol> *)rL
{
	if (self->remarkLabel_ != rL) {
		CGRect realBounds = CGRectZero;
		if ([rL isKindOfClass:[CCLabelBMFont class]]) {
			CCLabelBMFont*p = (CCLabelBMFont*)rL;
			realBounds = [p outerBounds];
		}else
			realBounds = rL.boundingBox;
		if (self->remarkLabel_) {
			[self removeChild:self->remarkLabel_];
			[self->remarkLabel_ release];
		}
		
		self->remarkLabel_ = [rL retain];
		self->remarkLabel_.anchorPoint=cpv(0.5, 0.5);
		if (self->remarkLabel_) {
			[self addChild:self->remarkLabel_ z:OVERLAY_LABEL_LAYER];
		}

		self->remarkLabel_.opacity=0.75 * 255;
		self->remarkLabel_.position=cpv(375, realBounds.size.height/4.0 +1);
	}
}

- (void) setMarbleSlot:(CMMarbleSlot *)mSlot
{
	if (self->marbleSlot_ != mSlot) {
		[self->marbleSlot_ removeFromParent];
		[self->marbleSlot_ release];
		mSlot.anchorPoint=ccp(0, 0);
		mSlot.position = ccp(482, 11);
		if (mSlot) {
			[self addChild:mSlot z:OVERLAY_LABEL_LAYER];
		}

		self->marbleSlot_ = [mSlot retain];
	}
}

- (void) setScoreDelegate:(NSObject<CMMarbleGameScoreModeProtocol> *)scoreDelegate
{
	if (self->scoreDelegate_ != scoreDelegate) {
		self->scoreDelegate_.gameDelegate = nil;
		[self->scoreDelegate_ release];
		self->scoreDelegate_ = [scoreDelegate retain];
		self->scoreDelegate_.gameDelegate = self;
	}
}


- (BOOL) playEffect
{
	return YES;
}

- (CGFloat) soundVolume
{
	return 1.0;
}

#pragma mark -
#pragma mark Actions and Helpers

-(void) createMenu
{
	// Default font size will be 22 points.
  //	[CCMenuItemFont setFontSize:22];
  //	[CCMenuItemFont setFontName:@"Arial"];

  CCControlButton *menuButton = defaultMenuButton();
  self->menuButton_ = menuButton;
  [self addChild:menuButton z:BUTTON_LAYER];
  [menuButton addTarget:self action:@selector(toggleMenu:) forControlEvents:CCControlEventTouchUpInside];
  self.menuLayer = [CMMenuLayer menuLayerWithLabel:@"Game Menu"];
  [self.menuLayer addButtonWithTitle:@"Main Menu" target:self action:@selector(backAction:)];
  [self.menuLayer addButtonWithTitle:@"Debug" target:self action:@selector(debugAction:)];
  self->toggleSimulationButton_ =  [self.menuLayer addButtonWithTitle:@"Stop" target:self action:@selector(toggleSimulationAction:)];
  [self.menuLayer addButtonWithTitle:@"Reset" target:self action:@selector(resetSimulationAction:)];
  [self.menuLayer addButtonWithTitle:@"Settings" target:self action:@selector(settingsAction:)];
	[self.menuLayer addButtonWithTitle:@"Back" target:self action:@selector(toggleMenu:)];
  [self addChild:self.menuLayer z:MENU_LAYER];
//#if __CC_PLATFORM_MAC
//	self.menuLayer.mousePriority = -1;
//#endif
  self.menuLayer.visible = NO;
}


- (void) toggleMenu:(id) sender
{
  
  self.menuLayer.visible = ~self.menuLayer.visible;
  
//  CGPoint actPosition = self->_menu.position;
//  if (actPosition.x == 0.0) {
//    actPosition.x = 1024;
//  }else{
//    actPosition.x = 0;
//  }
//  [self->_menu runAction:[CCMoveTo actionWithDuration:0.20 position:actPosition]];
}

- (void) backAction:(id) sender
{
  [self.simulationLayer stopSimulation];
  [[CCDirector sharedDirector] replaceScene: [CMMarbleMainMenuScene node]];
}

- (void) debugAction:(id) sender
{
  [self.simulationLayer.debugLayer setVisible: !self.simulationLayer.debugLayer.visible];
}

- (void) stopSimulationAction:(id) sender
{
  
}

- (void) startSimulationAction:(id) sender
{
  
}

- (void) replayAction:(id) sender
{
	self.resultMenu.visible = NO;
	self.simulationLayer.currentLevel = self.currentLevel;
	[self resetSimulationAction:nil];
}

- ( void) playNextAction:(id) sender
{
	self.resultMenu.visible=NO;
	[self incrementCurrentPlayerLevel];
	self.simulationLayer.currentLevel = self.currentLevel;
	[self resetSimulationAction:nil];
}

- (void) resetSimulationAction:(id) sender
{
	CMMarblePlayer *cP = [CMAppDelegate currentPlayer];

//	[CMAppDelegate setCurrentPlayer:cP];
  [self.simulationLayer resetSimulation];

	[self.marbleSlot clearMarbles];
	self.levelStartTime = [NSDate date];
	self.marblesInGame = [NSMutableSet set];
	for (NSUInteger i = 1; i<(MAX_DIFFERENT_MARBLES+1); i++) {
		[self.marblesInGame addObject:[NSNumber numberWithInteger:i]];
	}
	[self.simulationLayer prepareMarble];
	
}

- (void) toggleSimulationAction:(id) sender
{
  if(self.simulationLayer.isSimulationRunning){
    [self.simulationLayer stopSimulation];
    [self->toggleSimulationButton_ setTitle:@"Start" forState:CCControlStateNormal];
  }else{
    [self.simulationLayer startSimulation];
    [self->toggleSimulationButton_ setTitle:@"Stop" forState:CCControlStateNormal];
  }
}

- (void) settingsAction:(id) sender
{
  [[CCDirector sharedDirector] pushScene:[CMMarbleSettingsScene node]];


}

- (void) onEnter
{
  [super onEnter];
  [self.simulationLayer retextureMarbles];
}

- (void) onExit
{
	[self.simulationLayer onExit];
  [self.effectsNode removeAllChildrenWithCleanup:YES];
	[self.marbleEffectsNode removeAllChildrenWithCleanup:YES];
  [super onExit];
}



#pragma mark -
#pragma mark G A M E - Helper


- (NSArray*) getCollisionSets:(NSUInteger)minCollisions
{
	NSArray *collisionSets = [self.simulationLayer.collisionCollector collisionSetsWithMinMembers:minCollisions];
	
	for (NSSet *colSet in [collisionSets sortedArrayUsingComparator:
												 ^NSComparisonResult(NSArray* obj1, NSArray* obj2){
													 NSUInteger a = [obj1 count];
													 NSUInteger b = [obj2 count];
													 if(a<b){return NSOrderedAscending;}
													 if(a>b){return NSOrderedDescending;}
													 return NSOrderedSame;
												 }])
	{
	}
	
	return collisionSets;
}


- (void) checkMarbleCollisionsAt:(NSTimeInterval) time
{

	NSArray *removedMarbles = [self getCollisionSets:3];
	
	if (![removedMarbles count]) {
		return;
	}
	for (NSSet *currentCollisin in removedMarbles) {
		for (CMMarbleSprite *currentMarble in currentCollisin) {
			[currentMarble.marbleAction performActionFor:currentMarble];
		}

	}
	[self.scoreDelegate scoreWithMarbles:removedMarbles inLevel:self.currentStatistics];
//	[[SimpleAudioEngine sharedEngine] playEffect:DEFAULT_MARBLE_REMOVE];
	
	[self.simulationLayer removeCollisionSets:removedMarbles];
	
}

- (void) markerTimerCallback:(NSTimer*) timer
{
	self.remarkLabel = nil;
	self.effectTimer = nil;
}

- (void) marbleDelayCallback:(NSTimer*)timer
{
	self.marbleDelayTimer = nil;
	[self.simulationLayer prepareMarble];
}
- (void) incrementCurrentPlayerLevel
{
	CMMarblePlayer* currentPlayer = [CMAppDelegate currentPlayer];
	NSUInteger currentLevelIndex = [currentPlayer currentLevel] ;
		CMMarbleLevelSet * lS = [CMAppDelegate levelSet];
		NSArray *list = [lS levelList];
		NSInteger levelsInList = list.count;
		currentLevelIndex ++;
		currentLevelIndex = currentLevelIndex%levelsInList;
		currentPlayer.currentLevel = currentLevelIndex;
}


#pragma mark -
#pragma mark G A M E - Delegate

- (CMMenuLayer*) createStatisticsFor:(CMMPLevelStat*) stats
{
	CMMenuLayer* result = [CMMenuLayer menuLayerWithLabel:@"Results"];
	CCNode<CCLabelProtocol,CCRGBAProtocol>* leftLabel, *rightLabel;

	leftLabel = defaultButtonTitle(@"Label:");
	rightLabel = defaultButtonTitle(stats.name);
	[result addLeftNode:leftLabel right:rightLabel];
	
	leftLabel = defaultButtonTitle(@"Status:");
	NSString *statusLabel = nil;
	if (stats.status< kCMLevelStatus_Amateure) {
#if __CC_PLATFORM_MAC
		NSString *formatString = @"%@ - %ld Points needed";
#else
		NSString *formatString = @"%@ - %d Points needed";
#endif
		statusLabel = [NSString stringWithFormat:formatString,[stats statusString],self.currentLevel.amateurScore];
	}else{
		statusLabel = [stats statusString];
	}
	rightLabel = defaultButtonTitle(statusLabel);
	[result addLeftNode:leftLabel right:rightLabel];
	
	
	leftLabel = defaultButtonTitle(@"Score:");
	rightLabel = defaultButtonTitle([NSString stringWithFormat:@"%lld",stats.score]);
	[result addLeftNode:leftLabel right:rightLabel];
	
	leftLabel = defaultButtonTitle(@"Time:");
	rightLabel = defaultButtonTitle([self stringForSeconds:stats.time]);
	[result addLeftNode:leftLabel right:rightLabel];
	
	return result;
}

- (void) finishLevel
{

	CMMarblePlayer* currentPlayer = [CMAppDelegate currentPlayer];
	NSUInteger currentLevelIndex = [currentPlayer currentLevel] ;
	MarbleGameAppDelegate * appDel = CMAppDelegate;

	self.scoreLabel = defaultGameLabel([self currentScoreString]);
	self.timeLabel = defaultGameLabel([self stringForSeconds:self.currentStatistics.time]);

	CMMPLevelStat*oldStat = [appDel statisticsForPlayer:currentPlayer andLevel:self.currentLevel];
	CMMarbleGameLevelStatus currentStatus = [self.scoreDelegate statusOfLevel:self.currentLevel forStats:self.currentStatistics];
	self.currentStatistics.status = currentStatus;
	CMMenuLayer *statsMenu = [self createStatisticsFor:self.currentStatistics];
	if (self.resultMenu) {
		[self.resultMenu removeFromParent];
	}
	self.resultMenu = statsMenu;
	if ((currentStatus != kCMLevelStatus_Failed) && (currentStatus != kCMLevelStatus_Unfinished) ) {
		
		CMMPLevelStat *bestStat = [self.scoreDelegate betterStatOfOld:oldStat new:self.currentStatistics];
		if (bestStat == self.currentStatistics) {
			[appDel addStatistics:self.currentStatistics toPlayer:currentPlayer];
			NSString *label = nil;
			if (oldStat) {
				label = [NSString stringWithFormat:@"Personal Best (was %lld)",oldStat.score];
			}else{
				label = @"Personal Best";
			}
			[statsMenu addNode:defaultButtonTitle(label)];
		}
		CCControlButton *leftButton, *rightButton;
		leftButton = standardButtonWithTitle(@"Replay");
		rightButton = standardButtonWithTitle(@"Play Next");
		[leftButton addTarget:self action:@selector(replayAction:) forControlEvents:CCControlEventTouchUpInside];
		[rightButton addTarget:self action:@selector(playNextAction:) forControlEvents:CCControlEventTouchUpInside];
		[statsMenu addLeftNode:leftButton right:rightButton];
		[statsMenu addButtonWithTitle:@"Main Menu" target:self action:@selector(backAction:)];
		
		
	}else{
		[statsMenu addButtonWithTitle:@"Replay" target:self action:@selector(replayAction:)];
		[statsMenu addButtonWithTitle:@"Main Menu" target:self action:@selector(backAction:)];
		[[CMAppDelegate managedObjectContext] deleteObject:self.currentStatistics];
		currentPlayer.currentLevelStat = nil;
		self.currentStatistics = nil;
	}
	// display a end Menu
	[self addChild:statsMenu z:MENU_LAYER];
	statsMenu.visible = YES;
	NSError *error;
	[[CMAppDelegate managedObjectContext] save:&error];
}

/// returns index of the next Marble to be added to the game
- (NSUInteger) marbleIndex
{
	if (self.marblesInGame.count) {
		NSUInteger i = arc4random_uniform((unsigned int)[self.marblesInGame count]);
		NSNumber *q = [[self.marblesInGame allObjects]objectAtIndex:i];
		return [q integerValue];
	}else{
		return -1;
	}
}

/// returns the name of the current selected MarbleSet (User option)
- (NSString*) marbleSetName
{
	return [[NSUserDefaults standardUserDefaults]stringForKey:@"MarbleSet"];
}



- (void) marbleFiredWithID:(NSUInteger) ballIndex
{
	[self.marblesInGame addObject:[NSNumber numberWithInteger:ballIndex]];
	[self.scoreDelegate marbleFired];

}

- (void) marbleDroppedWithID:(NSUInteger) ballIndex
{
	if (self.marbleDelayTimer) {
		return;
	}else{
		self.marbleDelayTimer = [NSTimer scheduledTimerWithTimeInterval:MARBLE_CREATE_DELAY target:self selector:@selector(marbleDelayCallback:) userInfo:nil repeats:NO];
	}
	[self marbleFiredWithID:ballIndex];
	[self.scoreDelegate marbleDropped:self.currentStatistics];

}

- (CMMarbleLevel*) currentLevel
{
	CMMarbleLevel *result = nil;
	CMMarblePlayer* currentPlayer = [CMAppDelegate currentPlayer];
	NSUInteger currentLevelIndex = [currentPlayer currentLevel];
	CMMarbleLevelSet *set=[CMAppDelegate levelSet];
	
	result = [[set levelList]objectAtIndex:currentLevelIndex];
	
	return result;
}

- (void) updateTimeLabel
{
	if (self.simulationLayer.simulationRunning) {
		NSUInteger cc = self.simulationLayer.marbleBatchNode.children.count;
		NSInteger updateSecond = (NSInteger) -[self.levelStartTime timeIntervalSinceNow];
		if (self->lastUpdateSecond_ != cc) {
			self.timeLabel = defaultGameLabel([self currentTimeString]);
			self->lastUpdateSecond_ = cc;
		}
	}
}

- (void) updateScoreLabel
{
	if (self.simulationLayer.simulationRunning) {
		if (self->lastUpdateScore_ != self.currentStatistics.score) {
			self.scoreLabel = defaultGameLabel([self currentScoreString]);
			self->lastUpdateScore_ = (NSInteger)self.currentStatistics.score;
		}
	}
}



- (void) simulationStepDone:(NSTimeInterval)dt
{
	static NSTimeInterval lastLabelUpdate;
	static NSTimeInterval lastRougeMarbleCheck;
	static NSTimeInterval lastRougeSpriteCheck;
	lastLabelUpdate+= dt;
	lastRougeMarbleCheck += dt;
	lastRougeSpriteCheck += dt;
  if (lastLabelUpdate>.1) {
    	[self processEffectQueue];
  }
	if (lastLabelUpdate>.25) {
		lastLabelUpdate=0.0;
		[self updateScoreLabel];
		[self updateTimeLabel];

		if (self.removedMarbleQueue.count) {
			NSInteger ballIndex = [[self.removedMarbleQueue objectAtIndex:0]integerValue];
			[self.marbleSlot addMarbleWithID:ballIndex];
			[self.removedMarbleQueue removeObjectAtIndex:0];
		}
	}
	if (lastRougeMarbleCheck>1.0) {
		for (CMMarbleSprite *marble in self.simulationLayer.simulatedMarbles) {
			if (!CGRectContainsPoint(CGRectMake(0, 0, 1024, 800), marble.position)) {
				NSLog(@"Marble Outside");
				marble.position = MARBLE_RESPAWN_POINT;
				marble.chipmunkBody.vel = CGPointMake(0, 0);
			}
		}
		lastRougeMarbleCheck = 0.0;
	}
	if (lastRougeSpriteCheck >1.0) {
		NSArray * allSprites = self.simulationLayer.dynamicSprites;
		for (CMPhysicsSprite *sprite in allSprites) {
			if ((sprite.type != kGameBody_Mechanic) && !CGRectContainsPoint(CGRectMake(0,0, 1024, 718), sprite.position)) {
				sprite.position = sprite.originalPosition;
				sprite.chipmunkBody.vel = CGPointMake(0, 0);
				NSLog(@"Object outside %@",sprite);
			}
		}
    lastRougeSpriteCheck = 0.0;
	}
	
	[self checkMarbleCollisionsAt:dt];
}

- (void) imagesOnField:(NSSet*) fieldImages
{
	NSMutableSet *toBeRemoved = [NSMutableSet set];
	for (NSNumber *imageID in self.marblesInGame) {
    if (![fieldImages member:imageID]) {
			[toBeRemoved addObject:imageID];
		}
	}
	
	if (toBeRemoved.count ) {
		[self.marblesInGame minusSet:toBeRemoved];
		[self.simulationLayer removedMarbles:toBeRemoved];
	}

		[self.removedMarbleQueue addObjectsFromArray:[toBeRemoved allObjects]];

	if (!self.marblesInGame.count) {
		self.currentStatistics.time = -[self.levelStartTime  timeIntervalSinceNow];
		[self.simulationLayer stopSimulation];
    [self.simulationLayer cleanupMarbles];
		[self finishLevel];
	}

}

- (void) initializeLevel:(CMMarbleLevel *)level
{
	[self.effectsNode removeAllChildren];
	[self.spriteEffectsNode removeAllChildren];
	[self.marbleEffectsNode removeAllChildren];
	[self.removedMarbleQueue removeAllObjects];
	CCSprite *bkg = level.backgroundImage;
	if (bkg && !PHYSICS_PRODUCTION) {
		self.backgroundSprite=bkg;
	}
#if PHYSICS_PRODUCTION
	self.backgroundSprite = nil;
#endif
	
	CCSprite *fgs = level.overlayImage;
	if (fgs && !PHYSICS_PRODUCTION) {
		self.foregroundSprite = fgs;
	}
	
#if DEBUG_ALPHA_ON
	self.foregroundSprite.opacity = 128;
#endif
	self.currentStatistics = [CMAppDelegate temporaryStatisticFor:[CMAppDelegate currentPlayer] andLevel:level];
}

- (CMMarbleCollisionCollector*) collisionCollector
{
	return self.simulationLayer.collisionCollector;
}
- (void) effectRemoveTimer
{
	if (self.effectTimer) {
		return;
	}
	self.effectTimer = [NSTimer scheduledTimerWithTimeInterval:5
																											target:self
																										selector:@selector(markerTimerCallback:)
																										userInfo:self.remarkLabel
																										 repeats:NO];
}

- (void) fireEffect:(CCNode*) someEffectNode
{
	
	// dispatchEffect
	if ([someEffectNode isKindOfClass:[CCParticleSystem class]]) {
		[self.effectsNode addChild:someEffectNode z:20];
	}else{
	  [self.spriteEffectsNode addChild:someEffectNode z:20];
	}
  if ([someEffectNode conformsToProtocol:@protocol(CMObjectSoundProtocol)]) {
    CCNode<CMObjectSoundProtocol>*p = (CCNode<CMObjectSoundProtocol>*)someEffectNode;
    if (p.soundName) {
          [[SimpleAudioEngine sharedEngine]playEffect:p.soundName];
    }
  }
}

- (BOOL) canFire:(CCNode*)currentEffect togetherWith:(CCNode*)otherEffect
{
  BOOL canFire = YES;
  if ([currentEffect isKindOfClass:[CCParticleSystem class]]) {
    return canFire;
  }
  if ([otherEffect isKindOfClass:[CCParticleSystem class]]) {
    return canFire;
  }

  CGPoint cPos = currentEffect.position;
  CGPoint oPos = otherEffect.position;
  CGPoint dPos=cpvsub(cPos, oPos);
  CGFloat d = sqrt(cpvdot(dPos,dPos)); // square of the distance
  if (d<EFFECT_CLIP_DISTANCE_SQUARE) {
    canFire = NO;
  }
  return canFire;
}

- (void) processEffectQueue
{
	if (self.effectQueue.count) {
    NSMutableArray *effectsToFire = [NSMutableArray array];
//    if (self.effectQueue.count==1) {
//      CMMarbleMultiComboSprite *k = [self.effectQueue objectAtIndex:0];
//      [self fireEffect:k];
//      [self.effectQueue removeObject:k];
//    }else{
      for (CCNode* currentEffect in self.effectQueue) {
        // check if the position does not match as close to other triggered effects
//        if (!effectsToFire.count) {
//          [effectsToFire addObject:currentEffect];
//        }else{
          BOOL canFire = YES;
          for (CCNode* otherEffect in self.effectsNode.children) {
            canFire = [self canFire:currentEffect togetherWith:otherEffect];
            if (!canFire) {
              break;
            }
          }
          if(canFire){
            for (CCNode *otherEffect in effectsToFire) {
              canFire = [self canFire:currentEffect togetherWith:otherEffect];
              if (!canFire) {
                break;
              }
            }
          }
          if (canFire) {
            [effectsToFire addObject:currentEffect];
          }
//        }
      }
      // here we have filtered all of our effects by the distance to each other
      for (CCNode* effect in effectsToFire) {
        [self fireEffect:effect];
      }
      [self.effectQueue removeObjectsInArray:effectsToFire];
//    }
	}
}

- (void) addEffect:(CCNode*) effectsNode
{
  [self.effectQueue addObject:effectsNode];
}

- (void) removeEffect:(CCNode*) effectsNode
{
  [self.effectQueue removeObject:effectsNode];
//  if (effectsNode.parent) {
    [effectsNode removeFromParentAndCleanup:YES];
//  }
}

- (void) addMarbleEffect:(CCNode *)marbleEffect
{
	[self.marbleEffectsNode addChild:marbleEffect];
}

- (void) removeMarbleEffect:(CCNode *)marbleEffect
{
	[self.marbleEffectsNode removeChild:marbleEffect cleanup:YES];
}




- (void)triggerEffect:(CMMarbleEffectType)effect atPosition:(CGPoint)position overrideSound:(NSString *)soundName
{
	switch (effect) {
		case kCMMarbleEffect_Remove:
		{
			CMParticleSystemQuad *particle = [self particleSystemForName:MARBLE_REMOVE_EFFECT];
      particle.soundName = DEFAULT_MARBLE_REMOVE;
			particle.position = position;
			particle.autoRemoveOnFinish = YES;
			[self.effectQueue addObject:particle];
		}
			break;
    case kCMMarbleEffect_Explode:
    {
			CCParticleSystemQuad *particle = [self particleSystemForName:MARBLE_EXPLODE_EFFECT];
			particle.position = position;
			particle.autoRemoveOnFinish = YES;
			[self.effectQueue addObject:particle];
		}
      break;
		case kCMMarbleEffect_ComboHit:
		{
			CMMarbleMultiComboSprite * sprite = [CMMarbleMultiComboSprite spriteWithFile:DEFAULT_COMBO_EFFECT_FILE];
			sprite.soundName=DEFAULT_MARBLE_COMBO;
			sprite.position = position;
			sprite.gameDelegate = self;
			[self.effectQueue addObject:sprite];
		}
			break;

		case kCMMarbleEffect_MultiHit:
		{
			CMMarbleMultiComboSprite * sprite = [CMMarbleMultiComboSprite spriteWithFile:DEFAULT_MULTI_EFFECT_FILE];
			sprite.gameDelegate = self;
			sprite.soundName=DEFAULT_MARBLE_MULTI;
			sprite.position = position;
			[self.effectQueue addObject:sprite];
		}
			break;
		
		case kCMMarbleEffect_Score:
		{
			CGFloat score = self.scoreDelegate.lastScore;
//			NSLog(@"HitScore = %f (%@)",score,NSStringFromPoint(position));
			CMScoreSprite *scoreSprite = [[[CMScoreSprite alloc] initWithScore:score]autorelease];
			scoreSprite.position = position;
			[self.effectQueue addObject:scoreSprite];
		}
		break;

		case kCMMarbleEffect_NICE:
		{
      self.remarkLabel = defaultGameLabel(@"Nice");
			[self effectRemoveTimer];
		}
			break;

		case kCMMarbleEffect_RESPECT:
		{
			self.remarkLabel = defaultGameLabel(@"Respect");
			[self effectRemoveTimer];
		}
			break;

		case kCMMarbleEffect_PERFECT:
		{
			self.remarkLabel = defaultGameLabel(@"Perfect");
			[self effectRemoveTimer];
		}
			break;

		case kCMMarbleEffect_TRICK:
		{
			self.remarkLabel = defaultGameLabel(@"Trickshot");
			[self effectRemoveTimer];
		}
			break;

		case kCMMarbleEffect_LUCKY:
		{
			self.remarkLabel = defaultGameLabel(@"Lucky One");
			[self effectRemoveTimer];
		}
			break;
    case kCMMarbleEffect_ColorRemove:
    {
      [[SimpleAudioEngine sharedEngine] playEffect:DEFAULT_MARBLE_COLOR_REMOVE];
    }
			break;
		case kCMMarblePowerUp_MarbleSource:
		{
			CMMarbleEmitter *emitter = [[CMMarbleEmitter alloc]init];
			emitter.position = position;
			emitter.simulationLayer = self.simulationLayer;
			emitter.marblesToEmit = 10;
			emitter.marbleFrequency=30;
			emitter.velocity=120.0;
			emitter.velocityVariance=0.0;
			emitter.releaseOnFinish = YES;
			[emitter startEmitter];
         [[SimpleAudioEngine sharedEngine] playEffect:DEFAULT_MARBLE_BUBBLE];
		}
    break;
		default:
			break;
	}
}

- (void) triggerEffect:(CMMarbleEffectType)effect atPosition:(CGPoint) position
{
  [self triggerEffect:effect atPosition:position overrideSound:nil];
}

- (NSDictionary*) loadParticleDefinition:(NSString*)fileName
{
  NSString *path = [[CCFileUtils sharedFileUtils] fullPathForFilename:fileName];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	NSAssert( dict != nil, @"Particles: file not found");
  return dict;
}

- (NSDictionary*)particleDefinitionForName:(NSString *)file
{
  NSDictionary* result = [self.particleCache objectForKey:file];
  if (!result) {
    result = [self loadParticleDefinition:file];
    if (result) {
      [self.particleCache setObject:result forKey:file];
    }else{
      [self.particleCache setObject:[NSNull null] forKey:file];
    }
  }
  if ([result isKindOfClass:[NSNull class]]) {
    result = nil;
  }
  return result;
}

- (CMParticleSystemQuad*) particleSystemForName:(NSString*)fileName
{
  CMParticleSystemQuad *result = nil;
  NSDictionary *particleDef = [self particleDefinitionForName:fileName];
  if (particleDef) {
    result = [[[CMParticleSystemQuad alloc] initWithDictionary:particleDef]autorelease];
  }
  return result;
}
@end
