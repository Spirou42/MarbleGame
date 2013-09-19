//
//  SceneHelper.h
//  ChipDonkey
//
//  Created by Carsten Müller on 7/2/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cocos2d.h"
@class CCSprite, CCControlButton,CCControlSlider;


CCSprite* defaultSceneBackground();
CCControlButton* standardButtonWithTitle(NSString* title);
CCControlButton* standardButtonWithTitleSize(NSString* title, CGSize size);
CCControlButton* defaultMenuButton();
CCControlSlider* defaultGreenSlider();
CCControlSlider* defaultRedSlider();

CGPoint menuStartPosition();
CGPoint centerOfScreen();
CCSprite* mainMenuOverlay();
CCSprite* defaultMenuPlate();
CCSprite* defaultLevelBackground();
CCSprite* defaultLevelOverlay();
CCNode<CCLabelProtocol,CCRGBAProtocol>* defaultGameLabel(NSString* labelText);
CCNode<CCLabelProtocol,CCRGBAProtocol>* defaultButtonTitle(NSString* title);
CCNode<CCLabelProtocol,CCRGBAProtocol>* defaultMenuTitle(NSString* labelText);