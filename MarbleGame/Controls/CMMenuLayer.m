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
nextFreeMenuPosition = _nextFreeMenuPosition, interElementSpacing = _interElementSpacing, menuLabel = _menuLabel;

- (CGPoint) nextMenuPositionFor:(CCNode*)currentNode
{
	CGPoint position = self.nextFreeMenuPosition;
	CGPoint p = position;
	p.y -= currentNode.contentSize.height+self.interElementSpacing;
	self.nextFreeMenuPosition = p;
	return position;
}

- (CCNode<CCLabelProtocol,CCRGBAProtocol>*) createMenuLabel
{
	CCNode <CCLabelProtocol, CCRGBAProtocol> *mLabel =  defaultMenuTitle(self.menuLabel);
	mLabel.anchorPoint = ccp(0.5, 0.5);
	mLabel.position = [self nextMenuPositionFor:mLabel];
	return mLabel;
}

- (void) defaults
{
	self.menuButtons = [NSMutableArray array];
	self.defaultButtonSize = CGSizeMake(150, 40);
	self.interElementSpacing = 10;
	self.contentSize = [[CCDirector sharedDirector] winSize];
	self.backgroundSprite = [CCSprite spriteWithFile:MENU_BACKGROUND_PLATE];
	self.backgroundSprite.anchorPoint=ccp(0.5, 0.5);
	self.backgroundSprite.position = ccp(self.contentSize.width/2.0, self.contentSize.height/2.0);

	self.nextFreeMenuPosition = ccp(self.backgroundSprite.contentSize.width/2.0, self.backgroundSprite.contentSize.height - 40.0 );
	[self addChild:self.backgroundSprite z:0];
	[self.backgroundSprite addChild:[self createMenuLabel] z:1];
	CGPoint p = self.nextFreeMenuPosition;
	p.y-=40;
	self.nextFreeMenuPosition = p;
}

- (id) init
{
	return [self initWithLabel:@"Menu"];
}

- (id) initWithLabel:(NSString *)mLabel
{
	self = [super init];
	if (self) {
		self.menuLabel = mLabel;
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
	[self addNode:button z:1];
	
}
- (void) addNode:(CCNode *)aNode
{
	[self addNode:aNode z:1];
}
- (void) addNode:(CCNode *)aNode z:(NSInteger) zLayer
{
	aNode.position = [self nextMenuPositionFor:aNode];
	[self.backgroundSprite addChild:aNode z:zLayer];
	[self.menuButtons addObject:aNode];
}
@end
