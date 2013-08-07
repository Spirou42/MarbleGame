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
#import "CMMarbleLevelStatistics.h"
#import "CMMarbleLevel.h"
#import "CMMarbleLevelSet.h"
#import "CMMarblePlayer.h"
#import "MarbleGameAppDelegate+GameDelegate.h"
#import "CCLabelBMFont+CMMarbleRealBounds.h"

#define BACKGROUND_LAYER 	(-1)
#define MARBLE_LAYER 			(1)
#define FOREGROUND_LAYER 	(2)
#define OVERLAY_LAYER 		(3)
#define BUTTON_LAYER 			(5)
#define MENU_LAYER 				(6)

@implementation CMMarblePlayScene

@synthesize  normalHits = _normalHits,comboHits=_comboHits,multiHits=_multiHits,
currentStatistics = _currentStatistics, statisticsOverlay=_statisticsOverlay,
comboMarkerLabel = _comboMarkerLabel, lastDisplayTime = _lastDisplayTime, marbleDelayTimer,
marblesInGame=_marblesInGame,levelStartTime = _levelStartTime, backgroundSprite=_backgroundSprite,
foregroundSprite=_foregroundSprite, overlaySprite=_overlaySprite,
scoreLabel=_scoreLabel, timeLabel = _timeLabel, remarkLabel= _remarkLabel;

- (NSString*) currentTimeString
{
	NSTimeInterval dt = -[self.levelStartTime timeIntervalSinceNow];
	NSString* result = [NSString stringWithFormat:@"%02ld:%02ld",(NSInteger)dt/60,(NSInteger)dt%60];
	return result;
}
- (NSString*) currentScoreString
{
	NSString *result = [NSString stringWithFormat:@"%010ld",(long)self.currentStatistics.score];
	return result;
}

- (id) init
{
	if( (self = [super init]) ){
		self.backgroundSprite = defaultSceneBackground();

    [self createMenu];
//		[self scheduleUpdate];
    self.simulationLayer =[CMMarbleSimulationLayer node];
		self.simulationLayer.gameDelegate = self;
		self.simulationLayer.currentLevel = [self currentLevel];
		self.scoreLabel = defaultGameLabel(@"0");
		self.timeLabel = defaultGameLabel(@"00:00");

#ifdef __CC_PLATFORM_MAC
    self.simulationLayer.mousePriority=1;
#else
    self.simulationLayer.touchPriority=1;
#endif
		
		[self resetSimulationAction:nil];
		self.levelStartTime = [NSDate date];
	}
	return self;
}
- (void) dealloc
{
	self.levelStartTime = nil;
	[self.marbleDelayTimer invalidate];
	self.marbleDelayTimer = nil;
	self.currentStatistics = nil;
	self.simulationLayer = nil;
	self.marblesInGame = nil;
	self.backgroundSprite = nil;
	self.foregroundSprite = nil;
	self.overlaySprite = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Properties

- (void) setSimulationLayer:(CMMarbleSimulationLayer *)simLay
{
  if( self->_simulationLayer != simLay){
    [self removeChild:self->_simulationLayer cleanup:YES];
    [self->_simulationLayer release];
    self->_simulationLayer = [simLay retain];
		if (simLay) {
			[self addChild:simLay z:MARBLE_LAYER];
		}

  }
}

- (CMMarbleSimulationLayer*) simulationLayer
{
  return self->_simulationLayer;
}

- (void) setBackgroundSprite:(CCSprite *)bS
{
	if (self->_backgroundSprite != bS) {
		[self removeChild:self->_backgroundSprite cleanup:YES];
		[self->_backgroundSprite release];
		self->_backgroundSprite = [bS retain];
		self->_backgroundSprite.anchorPoint = cpv(0.5, 0.5);
		self->_backgroundSprite.position = centerOfScreen()
		;		if (bS) {
			[self addChild:bS z:BACKGROUND_LAYER];
		}
	}
}

- (void) setForegroundSprite:(CCSprite *)fS
{
	if (self->_foregroundSprite != fS) {
		[self removeChild:self->_foregroundSprite cleanup:YES];
		[self->_foregroundSprite release];
		self->_foregroundSprite = [fS retain];
		self->_foregroundSprite.anchorPoint = cpv(0.5, 0.5);
		self->_foregroundSprite.position = centerOfScreen();
		if (fS) {
			[self addChild:fS z:FOREGROUND_LAYER];
		}
	}
}

- (void) setOverlaySprite:(CCSprite *)oS
{
	if (self->_overlaySprite != oS) {
		[self removeChild:self->_overlaySprite cleanup:YES];
		[self->_overlaySprite release];
		self->_overlaySprite = [oS retain];
		self->_overlaySprite.anchorPoint=cpv(0.0, 1.0);
		self->_overlaySprite.position=cpv(0.0, 768);
		if (oS) {
			[self addChild:oS z:OVERLAY_LAYER];
		}
	}
}

- (void) setScoreLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol> *)sL
{
	if (self->_scoreLabel != sL) {
		CGRect realBounds = CGRectZero;
		if ([sL isKindOfClass:[CCLabelBMFont class]]) {
			CCLabelBMFont*p = (CCLabelBMFont*)sL;
			realBounds = [p outerBounds];
		}else
			realBounds = sL.boundingBox;
		
		if (self->_scoreLabel) {
			[self removeChild:self->_scoreLabel];
			[self->_scoreLabel release];
		}
		self->_scoreLabel = [sL retain];
		self->_scoreLabel.anchorPoint = cpv(1.0, 0.5);
		if (self->_scoreLabel) {
			[self addChild:self->_scoreLabel z:11];
		}

		self->_scoreLabel.opacity=0.75 * 255;
		self->_scoreLabel.position=cpv(238, 747-realBounds.size.height/2.0);
	}
}
- (void) setTimeLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol> *)tL
{
	if (self->_timeLabel != tL) {
		CGRect realBounds = CGRectZero;
		if ([tL isKindOfClass:[CCLabelBMFont class]]) {
			CCLabelBMFont*p = (CCLabelBMFont*)tL;
			realBounds = [p outerBounds];
		}else
			realBounds = tL.boundingBox;
		
		if (self->_timeLabel) {
			[self removeChild:self->_timeLabel];
			[self->_timeLabel release];
		}
		self->_timeLabel = [tL retain];
		if (self->_timeLabel) {
			[self addChild:self->_timeLabel z:11];
		}

		self->_timeLabel.opacity=0.75 * 255;
		self->_timeLabel.position=cpv(896, 747-realBounds.size.height/2.0);
	}
}

- (void) setRemarkLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol> *)rL
{
	if (self->_remarkLabel != rL) {
		CGRect realBounds = CGRectZero;
		if ([rL isKindOfClass:[CCLabelBMFont class]]) {
			CCLabelBMFont*p = (CCLabelBMFont*)rL;
			realBounds = [p outerBounds];
		}else
			realBounds = rL.boundingBox;
		if (self->_remarkLabel) {
			[self removeChild:self->_remarkLabel];
			[self->_remarkLabel release];
		}
		
		self->_remarkLabel = [rL retain];
		self->_remarkLabel.anchorPoint=cpv(0.5, 0.5);
		if (self->_remarkLabel) {
			[self addChild:self->_remarkLabel z:11];
		}

		self->_remarkLabel.opacity=0.75 * 255;
		self->_remarkLabel.position=cpv(384, 749-realBounds.size.height/2.0);
	}
}




#pragma mark -
#pragma mark other

-(void) createMenu
{
	// Default font size will be 22 points.
  //	[CCMenuItemFont setFontSize:22];
  //	[CCMenuItemFont setFontName:@"Arial"];

  CCControlButton *menuButton = defaultMenuButton();
  self->_menuButton = menuButton;
  [self addChild:menuButton z:BUTTON_LAYER];
  [menuButton addTarget:self action:@selector(toggleMenu:) forControlEvents:CCControlEventTouchUpInside];

  CCScale9Sprite *localMenu = [CCScale9Sprite spriteWithSpriteFrameName:DEFAULT_DDMENU_BACKGROUND capInsets:DDMENU_BACKGROUND_CAPS];
  self->_menu = localMenu;
  localMenu.preferredSize= CGSizeMake(1024, menuButton.contentSize.height+4);
  localMenu.anchorPoint = ccp(0.0, 1.0);
  localMenu.position = ccp(1024, menuButton.position.y+2);
  [self addChild:localMenu z:MENU_LAYER];

  
  // BackButton
  CCControlButton *backButton = standardButtonWithTitle(@"Back");
  backButton.preferredSize=CGSizeMake(100, 40);
  [backButton needsLayout];
  [backButton addTarget:self action:@selector(backAction:) forControlEvents:CCControlEventTouchUpInside];
  [localMenu addChild:backButton];
  CGPoint buttonPos = ccp(backButton.contentSize.width/2.0 + 10, localMenu.contentSize.height/2.0+1);
  backButton.position = buttonPos;
  buttonPos.x += backButton.contentSize.width;
  
  // DebugButton
  CCControlButton *debugButton = standardButtonWithTitle(@"Debug");
  debugButton.preferredSize=CGSizeMake(100, 40);
  [debugButton needsLayout];
  [debugButton addTarget:self action:@selector(debugAction:) forControlEvents:CCControlEventTouchUpInside];
  debugButton.position = buttonPos;
  [localMenu addChild:debugButton];
  buttonPos.x += debugButton.contentSize.width;
  
  // toggleSimulation
  CCControlButton *toggleButton = standardButtonWithTitle(@"Stop");
  toggleButton.preferredSize=CGSizeMake(100, 40);
  [toggleButton needsLayout];
  [toggleButton addTarget:self action:@selector(toggleSimulationAction:) forControlEvents:CCControlEventTouchUpInside];
  toggleButton.position = buttonPos;
  [localMenu addChild:toggleButton];
  buttonPos.x += toggleButton.contentSize.width;
  self->_toggleSimulationButton = toggleButton;
  
  // resetSimulation
  CCControlButton *resetButton = standardButtonWithTitle(@"Reset");
  resetButton.preferredSize=CGSizeMake(100, 40);
  [resetButton needsLayout];
  [resetButton addTarget:self action:@selector(resetSimulationAction:) forControlEvents:CCControlEventTouchUpInside];
  resetButton.position = buttonPos;
  [localMenu addChild:resetButton];
  buttonPos.x += resetButton.contentSize.width;
  
  // settings
  CCControlButton *settingsButton = standardButtonWithTitle(@"Settings");
  settingsButton.preferredSize=CGSizeMake(100, 40);
  [settingsButton needsLayout];
  [settingsButton addTarget:self action:@selector(settingsAction:) forControlEvents:CCControlEventTouchUpInside];
  settingsButton.position = buttonPos;
  [localMenu addChild:settingsButton];
  buttonPos.x += settingsButton.contentSize.width;
}



- (void) toggleMenu:(id) sender
{
  CGPoint actPosition = self->_menu.position;
  if (actPosition.x == 0.0) {
    actPosition.x = 1024;
  }else{
    actPosition.x = 0;
  }
  [self->_menu runAction:[CCMoveTo actionWithDuration:0.20 position:actPosition]];
}

- (void) backAction:(id) sender
{
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

- (void) resetSimulationAction:(id) sender
{
	CMMarblePlayer *cP = [CMAppDelegate currentPlayer];

	[CMAppDelegate setCurrentPlayer:cP];
  [self.simulationLayer resetSimulation];
	self.currentStatistics = [[[CMMarbleLevelStatistics alloc] init] autorelease];
	self.levelStartTime = [NSDate date];
	self.marblesInGame = [NSMutableSet set];
	for (NSUInteger i = 1; i<10; i++) {
		[self.marblesInGame addObject:[NSNumber numberWithInteger:i]];
	}
	[self.simulationLayer prepareMarble];
	
}

- (void) toggleSimulationAction:(id) sender
{
  if(self.simulationLayer.isSimulationRunning){
    [self.simulationLayer stopSimulation];
    [self->_toggleSimulationButton setTitle:@"Start" forState:CCControlStateNormal];
  }else{
    [self.simulationLayer startSimulation];
    [self->_toggleSimulationButton setTitle:@"Stop" forState:CCControlStateNormal];
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
  [super onExit];
}

#pragma mark -
#pragma mark G A M E


- (void) simulationStepDone:(NSTimeInterval)dt
{
	static NSTimeInterval lastLabelUpdate;
	lastLabelUpdate+= dt;
	if (lastLabelUpdate>.25) {
		lastLabelUpdate=0.0;
		self.scoreLabel = defaultGameLabel([self currentScoreString]);
		self.timeLabel = defaultGameLabel([self currentTimeString]);
	}
	
	[self checkMarbleCollisionsAt:dt];
}
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
- (CGPoint) centerOfMarbles:(id<NSFastEnumeration>) marbleSet
{
  CGPoint result = CGPointZero;
  NSUInteger t = 0;
  for (CALayer* mLayer in marbleSet) {
    result.x += mLayer.position.x;
    result.y += mLayer.position.y;
    t++;
  }
  result.x /=t;
  result.y /=t;
  return result;
}

- (void) checkMarbleCollisionsAt:(NSTimeInterval) time
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	__block NSUInteger normalHits = 0;
	__block NSUInteger multiHits = 0;
	__block NSMutableArray *oldestHit = [NSMutableArray array];
	NSArray *removedMarbles = [self getCollisionSets:3];
	if (![removedMarbles count]) {
		return;
	}
  
  // collect info
	[removedMarbles enumerateObjectsUsingBlock:
	 ^(NSSet* obj, NSUInteger idx, BOOL* stop){
		 NSTimeInterval k = [self.simulationLayer.collisionCollector oldestCollisionTime:obj];
		 if (k) {
			 k= now - k;
		 }
		 [oldestHit addObject:[NSNumber numberWithDouble:k]];
		 if ([obj count] == 3) {
			 normalHits ++;
		 }else if ([obj count] > 3) { // multi Hit

			 //       CGPoint p= [self centerOfMarbles:obj];
			 //       UIImage *c = [self multiDecorationImage];
			 //       CGSize contentSize = [c size];
			 //       CMDecorationLayer *decLayer = [[[CMDecorationLayer alloc]initWithContent:(id)[c CGImage] andSize:contentSize]autorelease];
			 //       decLayer.backgroundColor = nil;
			 //       [decLayer addToSuperlayer:self.playgroundView.layer withPosition:p];

			 multiHits ++;
		 }
	 }];
	
  
  
	//	if (multiHits) {
	//		self.fourMarkerView.hidden=NO;
	//		[NSTimer scheduledTimerWithTimeInterval:5
	//																		 target:self
	//																	 selector:@selector(markerTimerCallback:)
	//																	 userInfo:self.fourMarkerView
	//																		repeats:NO];
	//	}
	
	
  
  // Combo Hits
  self.comboHits += [removedMarbles count];
	CGFloat comboMultiplier = 0.0f;
	if (self.comboHits>1) {
    NSMutableSet *allMarbles =[NSMutableSet set];
    for (NSSet*t in removedMarbles) {
      [allMarbles addObjectsFromArray:[t allObjects]];
    }
//    CGSize contentSize = CGSizeZero;
		//    CGPoint l = [self centerOfMarbles:allMarbles];
		//    UIImage *p = [self comboDecorationImage];
		//    contentSize = [p size];
		//    CMDecorationLayer *decLayer = [[[CMDecorationLayer alloc] initWithContent:(id)[p CGImage] andSize:contentSize]autorelease];
		//    decLayer.backgroundColor = nil;
		//    [decLayer addToSuperlayer:self.playgroundView.layer withPosition:l];
		//		if (self.comboMarkerView.hidden) {
		//			self.comboMarkerView.hidden = NO;
		//			[NSTimer scheduledTimerWithTimeInterval:5
		//																			 target:self
		//																		 selector:@selector(markerTimerCallback:)
		//																		 userInfo:self.comboMarkerView
		//																			repeats:NO];
		//
		//		}
		//		CGFloat comboScore = self.comboHits*MARBLE_HIT_SCORE * MARBLE_COMBO_MULTIPLYER;
		comboMultiplier += MARBLE_COMBO_MULTIPLYER;
//		self.currentStatistics.score += comboScore;
//		NSLog(@"Combo: %d (%f)",self.comboHits,comboScore);
		self.comboHits -= [removedMarbles count];
	}
  if (comboMultiplier <MARBLE_COMBO_MULTIPLYER) {
		comboMultiplier = 1.0f;
	}
  // specialMoves
	CGFloat specialMultiplier=1.0;
	NSString * specialString = nil;
  for (NSNumber * delay in oldestHit) {
    CGFloat t = [delay floatValue];
    if (t>0.001) {
			specialMultiplier = MARBLE_SPEZIAL_NICE;
			specialString = @"Nice";
      self.remarkLabel = defaultGameLabel(specialString);
      if(t>0.05){
					specialMultiplier = MARBLE_SPEZIAL_RESPECT;
				specialString =@"Respect";
    	  self.remarkLabel = defaultGameLabel(specialString);
			}
      if (t>0.10){
				specialMultiplier = MARBLE_SPEZIAL_PERFECT;
				specialString =@"Perfect";
  	    self.remarkLabel = defaultGameLabel(specialString);
			}
      if (t>0.15){
				specialMultiplier = MARBLE_SPEZIAL_TRICK;
				specialString =@"Trickshot";
	      self.remarkLabel = defaultGameLabel(specialString);
			}
      if (t>0.17) {
				specialMultiplier = MARBLE_SPEZIAL_LUCKY;
				specialString =@"Lucky One";
	      self.remarkLabel = defaultGameLabel(specialString);
      }
      self.remarkLabel.visible = YES;
      [NSTimer scheduledTimerWithTimeInterval:5
                                       target:self
                                     selector:@selector(markerTimerCallback:)
                                     userInfo:self.remarkLabel
                                      repeats:NO];
      
    }
  }
	CGFloat normalScore = (normalHits*MARBLE_HIT_SCORE);
	CGFloat multiScore = (multiHits*MARBLE_HIT_SCORE*MARBLE_MULTY_MUTLIPLYER);
	CGFloat totalScore = (normalScore + multiScore) * specialMultiplier * comboMultiplier;
	NSLog(@"normal: %d (%f), multi: %d (%f) combo: %f special: %@ (%f) Total: %f",normalHits, normalScore, multiHits,multiScore ,comboMultiplier, specialString,specialMultiplier,totalScore);

	self.currentStatistics.score += totalScore;
	
	self.lastDisplayTime = time;
	[self.simulationLayer removeCollisionSets:removedMarbles];
	
}

- (void) markerTimerCallback:(NSTimer*) timer
{
	self.remarkLabel = nil;
}

- (void) marbleDelayCallback:(NSTimer*)timer
{
	self.marbleDelayTimer = nil;
	[self.simulationLayer prepareMarble];
}
 - (void) updatePlayerLevel
{
	CMMarblePlayer* currentPlayer = [CMAppDelegate currentPlayer];
	NSUInteger currentLevelIndex = [currentPlayer currentLevel];
	MarbleGameAppDelegate * appDel = CMAppDelegate;
	CMMarbleLevelSet * lS = [appDel levelSet];
	NSArray *list = [lS levelList];
	NSInteger levelsInList = list.count;
	currentLevelIndex ++;
	currentLevelIndex = currentLevelIndex%levelsInList;
	currentPlayer.currentLevel = currentLevelIndex;

	appDel.currentPlayer =  currentPlayer;
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
		NSLog(@"Removing: %@",toBeRemoved);
		[self.marblesInGame minusSet:toBeRemoved];
		[self.simulationLayer removedMarbles:toBeRemoved];
	}

	for (NSNumber *t in toBeRemoved) {
		[self.currentStatistics marbleCleared:t];
	}

	if (!self.marblesInGame.count) {
		self.currentStatistics.time = -[self.levelStartTime  timeIntervalSinceNow];
		NSLog(@"LevelStatistics: %@",self.currentStatistics);
		[self.simulationLayer stopSimulation];
		[self updatePlayerLevel];
		[[CCDirector sharedDirector]replaceScene:[CMMarbleMainMenuScene node]];
	}
}

- (void) addChild:(CCNode *)node z:(NSInteger)z
{
	[super addChild:node z:z];
}

- (void) initializeLevel:(CMMarbleLevel *)level
{
	CCSprite *bkg = level.backgroundImage;
	if (bkg) {
		self.backgroundSprite=bkg;
	}else{
		self.backgroundSprite = defaultLevelBackground();
	}
	
	CCSprite *fgs = level.overlayImage;
	self.foregroundSprite = fgs;

	self.overlaySprite = defaultLevelOverlay();
}

#pragma mark -
#pragma mark Game Delegate

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
	self.currentStatistics.marblesInLevel++;
	[self.marblesInGame addObject:[NSNumber numberWithInteger:ballIndex]];
}

- (void) marbleDroppedWithID:(NSUInteger) ballIndex
{
	if (self.marbleDelayTimer) {
		return;
	}else{
		self.marbleDelayTimer = [NSTimer scheduledTimerWithTimeInterval:MARBLE_CREATE_DELAY target:self selector:@selector(marbleDelayCallback:) userInfo:nil repeats:NO];
	}
	[self marbleFiredWithID:ballIndex];
	self.currentStatistics.score += MARBLE_THROW_SCORE;
	self.comboHits = 0;
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
@end
