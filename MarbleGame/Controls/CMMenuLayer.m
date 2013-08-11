//
//  CMMenuNode.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/10/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMenuLayer.h"
#import "SceneHelper.h"
#import "cocos2d.h"
@implementation CMMenuLayer

@synthesize  backgroundSprite=_backgroundSprite, menuButtons=_menuButtons, defaultButtonSize=_defaultButtonSize,
nextFreeMenuPosition = _nextFreeMenuPosition, interElementSpacing = _interElementSpacing;

- (void) defaults
{
	self.menuButtons = [NSMutableArray array];
	self.defaultButtonSize = CGSizeMake(150, 40);
	self.interElementSpacing = 10;
	self.contentSize = [[CCDirector sharedDirector] winSize];
	self.backgroundSprite = [CCSprite spriteWithFile:MENU_BACKGROUND_PLATE];
	self.backgroundSprite.anchorPoint=ccp(0.5, 0.5);
	self.backgroundSprite.position = ccp(self.contentSize.width/2.0, self.contentSize.height/2.0);
	[self addChild:self.backgroundSprite];
}

- (id) init
{
	self = [super init];
	if(self){
		[self defaults];
	}
	return self;
}

- (void) dealloc
{
	self.backgroundSprite = nil;
	self.menuButtons = nil;
	[super dealloc];
}

#pragma mark - 
#pragma mark Button handling

- (void) addButtonWithTitle:(NSString *)buttonTitle target:(id)target action:(SEL)selector
{
	CCControlButton *button = standardButtonWithTitleSize(buttonTitle, self.defaultButtonSize);
	[button addTarget:target action:selector forControlEvents:CCControlEventTouchUpInside];
	
}
@end
