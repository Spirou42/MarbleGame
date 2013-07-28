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

#define BACKGROUND_LAYER (-1)
#define MARBLE_LAYER (1)
#define BUTTON_LAYER (5)
#define MENU_LAYER (BUTTON_LAYER-1)

@implementation CMMarblePlayScene

@synthesize  normalHits = _normalHits,comboHits=_comboHits,multiHits=_multiHits,
currentStatistics = _currentStatistics, statisticsOverlay=_statisticsOverlay,
comboMarkerLabel = _comboMarkerLabel, lastDisplayTime = _lastDisplayTime;

- (id) init
{
	if( (self = [super init]) ){
    [self addChild:defaultSceneBackground() z:BACKGROUND_LAYER];
    [self createMenu];
		[self scheduleUpdate];
    self.simulationLayer =[CMMarbleSimulationLayer node];
    self.simulationLayer.mousePriority=1;


	}
	return self;
}

- (void) setSimulationLayer:(CMMarbleSimulationLayer *)simLay
{
  if( self->_simulationLayer != simLay){
    [self removeChild:self->_simulationLayer cleanup:YES];
    [self->_simulationLayer release];
    self->_simulationLayer = [simLay retain];
    [self addChild:simLay z:MARBLE_LAYER];
  }
}

- (CMMarbleSimulationLayer*) simulationLayer
{
  return self->_simulationLayer;
}

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
@end
