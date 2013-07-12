//
//  PlayScene.h
//  CocosTest1
//
//  Created by Carsten Müller on 6/29/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CCScene.h"
@class CMMarbleSimulationLayer, CCScale9Sprite, CCControlButton;

@interface CMMarblePlayScene : CCScene
{
  @protected
  CMMarbleSimulationLayer* _simulationLayer;
  CCScale9Sprite    *_menu;
  CCControlButton   *_menuButton;
  CCControlButton   *_toggleSimulationButton;
  
}
@property (nonatomic,retain) CMMarbleSimulationLayer* simulationLayer;
@end
