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

#define BACKGROUND_LAYER (-1)
#define MARBLE_LAYER (1)
#define BUTTON_LAYER (5)
#define MENU_LAYER (BUTTON_LAYER-1)

@implementation CMMarblePlayScene
- (id) init
{
	if( (self = [super init]) ){
    [self addChild:defaultSceneBackground() z:BACKGROUND_LAYER];
    [self createMenu];
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

  CCControlButton *menuButton = standardButtonWithTitle(@"Menu");
  self->_menuButton = menuButton;
  menuButton.anchorPoint=ccp(1.0, 1.0);
  menuButton.position=ccp(1022, 765);
  [self addChild:menuButton z:BUTTON_LAYER];
  [menuButton addTarget:self action:@selector(toggleMenu:) forControlEvents:CCControlEventTouchUpInside];

  CCScale9Sprite *localMenu = [CCScale9Sprite spriteWithSpriteFrameName:DEFAULT_DDMENU_BACKGROUND capInsets:DDMENU_BACKGROUND_CAPS];
  self->_menu = localMenu;
  localMenu.preferredSize= CGSizeMake(1024, menuButton.contentSize.height+4);
  localMenu.anchorPoint = ccp(0.0, 1.0);
  localMenu.position = ccp(1024, 768);
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

@end
