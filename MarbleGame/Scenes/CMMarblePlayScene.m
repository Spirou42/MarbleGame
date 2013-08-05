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
foregroundSprite=_foregroundSprite, overlaySprite=_overlaySprite;

- (id) init
{
	if( (self = [super init]) ){
		self.backgroundSprite = defaultSceneBackground();

    [self createMenu];
//		[self scheduleUpdate];
    self.simulationLayer =[CMMarbleSimulationLayer node];
		self.simulationLayer.gameDelegate = self;
		self.simulationLayer.currentLevel = [self currentLevel];

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

-(void) scheduleUpdate
{
	[super scheduleUpdate];
}
- (void) update:(ccTime)delta
{
	[super update:delta];
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

  [self.simulationLayer resetSimulation];
	self.currentStatistics = [[[CMMarbleLevelStatistics alloc] init] autorelease];
	
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
		self.currentStatistics.score += self.comboHits*10;
		self.comboHits -= [removedMarbles count];
	}
  
  // specialMoves
	
  for (NSNumber * delay in oldestHit) {
    CGFloat t = [delay floatValue];
    if (t>0.001) {
      self.comboMarkerLabel.string = @"Nice";
      if(t>0.05)
        self.comboMarkerLabel.string = @"Respect";
      if (t>0.10)
        self.comboMarkerLabel.string = @"Perfect";
      if (t>0.15)
        self.comboMarkerLabel.string = @"Trickshot";
      if (t>0.17) {
        self.comboMarkerLabel.string = @"Lucky One";
      }
      self.comboMarkerLabel.visible = YES;
      [NSTimer scheduledTimerWithTimeInterval:5
                                       target:self
                                     selector:@selector(markerTimerCallback:)
                                     userInfo:self.comboMarkerLabel
                                      repeats:NO];
      
    }
  }
	
	
	self.currentStatistics.score += (normalHits*3) + (multiHits*6);
	
	self.lastDisplayTime = time;
	[self.simulationLayer removeCollisionSets:removedMarbles];
	
}

- (void) markerTimerCallback:(NSTimer*) timer
{
	
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
	currentLevelIndex = (currentLevelIndex+1)%[appDel levelSet].levelList.count;
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
		[[CCDirector sharedDirector]replaceScene:[CMMarbleMainMenuScene node]];
		[self updatePlayerLevel];
		
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
