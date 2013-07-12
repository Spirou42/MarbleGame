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

CCSprite* defaultSceneBackground()
{
	CCSprite *background = [CCSprite spriteWithFile:DEFAULT_BACKGROUND_IMAGE];
	background.anchorPoint=ccp(0, 0);
	return background;
}

CCControlButton* standardButtonWithTitle(NSString* title)
{
	NSString* buttonOffName = NORMAL_BUTTON_BACKGROUND;
	NSString* buttonOnName = ACTIVE_BUTTON_BACKGROUND;
	CGRect buttonCaps = BUTTON_BACKGROUND_CAPS;
	CCScale9Sprite *backgroundButton =  [CCScale9Sprite spriteWithSpriteFrameName:buttonOffName capInsets:buttonCaps]; // [CCScale9Sprite spriteWithFile:@"button.png"];
	CCScale9Sprite *backgroundHighlightedButton = [CCScale9Sprite spriteWithSpriteFrameName:buttonOnName capInsets:buttonCaps]; //[CCScale9Sprite spriteWithFile:@"buttonHighlighted.png"];
  //	CCLabelTTF *titleButton = [CCLabelTTF labelWithString:title fontName:DEFAULT_BUTTON_FONT fontSize:DEFAULT_BUTTON_FONT_SIZE];
  CCLabelTTF *titleButton = [CCLabelTTF labelWithString:title
                                               fontName:DEFAULT_BUTTON_FONT
                                               fontSize:DEFAULT_BUTTON_FONT_SIZE
                                             dimensions:DEFAULT_BUTTON_TITLESIZE
                                             hAlignment:kCCTextAlignmentCenter
                                             vAlignment:kCCVerticalTextAlignmentCenter
                             ];
  
	[titleButton setColor:ccc3(10, 10, 10)];
	
	CCControlButton *button = [CCControlButton buttonWithLabel:titleButton backgroundSprite:backgroundButton];
	button.zoomOnTouchDown = NO;
	button.preferredSize=CGSizeMake(150, 40);
	button.labelAnchorPoint=ccp(0.5, 0.5);
	[button setBackgroundSprite:backgroundHighlightedButton forState:CCControlStateHighlighted];
	[button setTitleColor:DEFAULT_BUTTON_TITLE_COLOR forState:CCControlStateNormal];
	[button setTitleColor:SELECTED_BUTTON_TITLE_COLOR forState:CCControlStateHighlighted];
	
	return button;
}