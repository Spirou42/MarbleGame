//
//  CMMarbleMenuScene.m
//  
//
//  Created by Carsten Müller on 8/12/13.
//
//

#import "CMMarbleMenuScene.h"
#import "CCLabelBMFont+CMMarbleRealBounds.h"
#import "MarbleGameAppDelegate+GameDelegate.h"
#import "CMMarblePlayerOld.h"
#import "SceneHelper.h"
@implementation CMMarbleMenuScene
@synthesize  playerName;


- (id) init
{
	if ((self = [super init])) {
		CMMarblePlayerOld *currentPlayer = [CMAppDelegate currentPlayer];
		NSString *pn = [currentPlayer.name uppercaseString];
		self.playerName = defaultGameLabel(pn);
		
		[self addChild:self.backgroundSprite z:BACKGROUND_LAYER];
		[self addChild:self.overlaySprite z:OVERLAY_LAYER];
	}
	return self;
}

- (void) dealloc
{
	self.playerName = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Properties

- (void) setPlayerName:(CCNode<CCRGBAProtocol,CCLabelProtocol>* )pN
{
	if (self->_playerName != pN) {
		CGRect realBounds = CGRectZero;
		if ([pN isKindOfClass:[CCLabelBMFont class]]) {
			CCLabelBMFont*p = (CCLabelBMFont*)pN;
			realBounds = [p outerBounds];
		}else
			realBounds = pN.boundingBox;
		if (self->_playerName) {
			[self removeChild:self->_playerName];
			[self->_playerName release];
		}
		self->_playerName = [pN retain];
		if (self->_playerName) {
			[self addChild:self->_playerName z:11];
		}
		self->_playerName.opacity=0.75 * 255;
		CGPoint position = self.playerLabelPosition;
		self->_playerName.position=cpv(position.x, position.y-realBounds.size.height/2.0);
	}
}

- (CGPoint) playerLabelPosition
{
	return CGPointMake(258, 747);
}

- (CCSprite*) backgroundSprite
{
	return defaultSceneBackground();
}

- (CCSprite*) overlaySprite
{
	return mainMenuOverlay();
}


@end
