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
nextFreeMenuPosition = _nextFreeMenuPosition, interElementSpacing = _interElementSpacing, menuLabel = _menuLabel,
interColumnSpacing = _interColumnSpacing;

+ (id) menuLayerWithLabel:(NSString *)menuLabel
{
  return [[[[self class] alloc]initWithLabel:menuLabel]autorelease];
}

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
	self.interColumnSpacing = 20;
	self.color = ccc3(0, 0, 0);
	self.opacity = 50;
	self.contentSize = [[CCDirector sharedDirector] winSize];
	self.backgroundSprite = [CCSprite spriteWithFile:MENU_BACKGROUND_PLATE];
	self.backgroundSprite.anchorPoint=ccp(0.5, 0.5);
	self.backgroundSprite.position = ccp(self.contentSize.width/2.0, self.contentSize.height/2.0);
#if __CC_PLATFORM_MAC
	self.mouseEnabled = YES;
#endif
	self.touchEnabled = YES;
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

- (CCControlButton*) addButtonWithTitle:(NSString *)buttonTitle target:(id)target action:(SEL)selector
{
	CCControlButton *button = standardButtonWithTitleSize(buttonTitle, self.defaultButtonSize);
	[button addTarget:target action:selector forControlEvents:CCControlEventTouchUpInside];
	button.marginLR = 20.0f;
	button.preferredSize=CGSizeMake(400, 50);
	[self addNode:button z:1];
	return button;
	
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

- (void) addLeftNode:(CCNode *)lNode right:(CCNode *)rNode
{
	CCNode *refNode = nil;
	if (lNode.contentSize.height < rNode.contentSize.height) {
		refNode = rNode;
	}else{
		refNode = lNode;
	}
	
	CGPoint lPos = [self nextMenuPositionFor:refNode];
	CGPoint rPos = lPos;
	
	lPos.x -= self.interColumnSpacing/2.0;
	rPos.x += self.interColumnSpacing/2.0;
	lNode.anchorPoint=CGPointMake(1.0, 0.5);
	lNode.position = lPos;
	rNode.anchorPoint = CGPointMake(0.0, 0.5);
	rNode.position = rPos;
	[self.backgroundSprite addChild:lNode z:1];
	[self.backgroundSprite addChild:rNode z:1];
}
- (void) draw
{
	[super draw];
}

#pragma mark -
#pragma mark Event handling

#if __CC_PLATFORM_MAC
-(BOOL) ccMouseDown:(NSEvent *)event
{
	if (self.visible) {
		return YES;
	}
	return NO;
}

- (BOOL) ccMouseMoved:(NSEvent *)event
{
	if (self.visible) {
		return YES;
	}
	return NO;
}
#else
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (self.visible) {
		return YES;
	}
	return NO;
}

#endif

@end
