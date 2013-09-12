//
//  SceneHelper.m
//  ChipDonkey
//
//  Created by Carsten Müller on 7/2/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "SceneHelper.h"
#import "cocos2d.h"
#import "CCControlExtension.h"

CCSprite* spriteWithName(NSString* filename)
{
	CCSprite *background = [CCSprite spriteWithFile:filename];
	background.anchorPoint=ccp(0, 0);
	return background;
}


inline CCSprite* defaultSceneBackground()
{
	return spriteWithName(DEFAULT_BACKGROUND_IMAGE);
}

inline CCSprite* mainMenuOverlay()
{
	return spriteWithName(MAIN_MENU_OVERLAY);
}
inline CCSprite* mainMenuMenuPlate()
{
	CCSprite *s =spriteWithName(@"MainMenu-Menu.png");
	s.anchorPoint = cpv(0.5, 0.5);
	return s;
}

inline CCSprite* defaultMenuPlate()
{
	CCSprite *s =spriteWithName(@"Menu-Background.png");
	s.anchorPoint = cpv(0.5, 0.5);
	return s;
}

inline CCSprite* defaultLevelBackground()
{
	return spriteWithName(@"LevelBackground-Default.png");
}

inline CCSprite *defaultLevelOverlay()
{
  CCSprite *result =spriteWithName(@"Level-Overlay.png");
	return result;
}

inline CCControlButton* standardButtonWithTitle(NSString* title)
{
	return standardButtonWithTitleSize(title,CGSizeMake(150,40));
}

inline CCControlButton* standardButtonWithTitleSize(NSString* title, CGSize size)
{
	NSString* buttonOffName = NORMAL_BUTTON_BACKGROUND;
	NSString* buttonOnName = ACTIVE_BUTTON_BACKGROUND;
	CGRect buttonCaps = BUTTON_BACKGROUND_CAPS;
	CCScale9Sprite *backgroundButton =  [CCScale9Sprite spriteWithSpriteFrameName:buttonOffName capInsets:buttonCaps]; // [CCScale9Sprite spriteWithFile:@"button.png"];
	CCScale9Sprite *backgroundHighlightedButton = [CCScale9Sprite spriteWithSpriteFrameName:buttonOnName capInsets:buttonCaps]; //[CCScale9Sprite spriteWithFile:@"buttonHighlighted.png"];
	CCNode<CCLabelProtocol,CCRGBAProtocol> *titleLabel = defaultButtonTitle(title);
	
	CCControlButton *button = [CCControlButton buttonWithLabel:titleLabel backgroundSprite:backgroundButton];
	button.zoomOnTouchDown = NO;
	button.preferredSize= size;

	[button setBackgroundSprite:backgroundHighlightedButton forState:CCControlStateHighlighted];
	button.marginLR = 20.0;
	return button;
}

inline CCControlSlider* defaultRedSlider()
{
  CCSprite *backgroundSprite,*valueSprite,*thumbSprite;

	backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"Slider-Track-Normal"];
	valueSprite = [CCSprite spriteWithSpriteFrameName:@"Slider-Track-Selected"];
	thumbSprite = [CCSprite spriteWithSpriteFrameName:@"Slider-Thumb"];

	CCControlSlider *slider  = [CCControlSlider sliderWithBackgroundSprite:backgroundSprite progressSprite:valueSprite thumbSprite:thumbSprite];
	slider.thumbInset = 2;
  //	CGPoint p = CGPointMake(parent.contentSize.width/2.0, parent.contentSize.height/2.0);
  //	slider.anchorPoint=CGPointMake(0.5, 0.5);
  //	slider.position = p;
  slider.mousePriority=-10;
  return slider;
}


inline CCControlSlider* defaultGreenSlider()
{
  CCSprite *backgroundSprite,*valueSprite,*thumbSprite;

	backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"Slider-Track-Normal"];
	valueSprite = [CCSprite spriteWithSpriteFrameName:@"Slider-Track-SelectedGreen"];
	thumbSprite = [CCSprite spriteWithSpriteFrameName:@"Slider-Thumb"];

	CCControlSlider *slider  = [CCControlSlider sliderWithBackgroundSprite:backgroundSprite progressSprite:valueSprite thumbSprite:thumbSprite];
	slider.thumbInset = 2;
//	CGPoint p = CGPointMake(parent.contentSize.width/2.0, parent.contentSize.height/2.0);
//	slider.anchorPoint=CGPointMake(0.5, 0.5);
//	slider.position = p;
  return slider;
}

inline CCControlButton* defaultMenuButton()
{
  CCControlButton* result = standardButtonWithTitle(@"M");
	result.preferredSize=CGSizeMake(40, 40);
  result.anchorPoint=ccp(1.0, 1.0);
  result.position=ccp(990, 762);
  return result;
}

inline CCNode<CCLabelProtocol,CCRGBAProtocol>* defaultMenuTitle(NSString* labelText)
{
  CGSize winSize = [[CCDirector sharedDirector] winSize];
  
  CCNode<CCLabelProtocol,CCRGBAProtocol> *label = [CCLabelBMFont labelWithString:labelText fntFile:DEFAULT_MENU_FONT];
																									 
  label.color=DEFAULT_MENU_TITLE_COLOR;
  label.position = ccp(winSize.width/2.0, winSize.height-label.contentSize.height );
  return label;
}

inline CCNode<CCLabelProtocol,CCRGBAProtocol>* defaultButtonTitle(NSString* title)
{
	return [CCLabelBMFont labelWithString:title fntFile:DEFAULT_BUTTON_FONT];
}

inline CCNode<CCLabelProtocol,CCRGBAProtocol>* defaultGameLabel(NSString* labelText)
{
	CCLabelBMFont *result = [CCLabelBMFont labelWithString:labelText fntFile:@"Simpleton17Glow.fnt" width:0.0 alignment:kCCTextAlignmentLeft imageOffset:cpv(0.0,0.0)];
	return result;
}

inline CGPoint menuStartPosition()
{
  CGSize winSize = [[CCDirector sharedDirector] winSize];
  CGPoint menuPosition = ccp(winSize.width/2.0, winSize.height/3.0*2.0);
  return menuPosition;
}

inline CGPoint centerOfScreen()
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	CGPoint menuPosition = ccp(winSize.width/2.0, winSize.height/2.0);
  return menuPosition;
}

CGSize screenSize()
{
	return [[CCDirector sharedDirector] winSize];
}