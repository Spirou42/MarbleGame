//
//  SceneHelper.h
//  ChipDonkey
//
//  Created by Carsten Müller on 7/2/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cocos2d.h"
@class CCSprite, CCControlButton;


CCSprite* defaultSceneBackground();
CCControlButton* standardButtonWithTitle(NSString* title);
CCControlButton* defaultMenuButton();
id<CCLabelProtocol,CCRGBAProtocol> defaultSceneLabel(NSString* labelText);
CGPoint menuStartPosition();
CGPoint centerOfScreen();
CCSprite* mainMenuOverlay();
CCSprite* mainMenuMenuPlate();
CCSprite* defaultLevelBackground();
CCSprite* defaultLevelOverlay();
CCNode<CCLabelProtocol,CCRGBAProtocol>* defaultGameLabel(NSString* labelText);