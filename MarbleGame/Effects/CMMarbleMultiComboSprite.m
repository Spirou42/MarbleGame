//
//  CMMarbleMultiComboSprite.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/7/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMarbleMultiComboSprite.h"
#import "CMLiquidAction.h"

#define TIME_DIF(swings,fullTime) (fullTime/(swings*2.0))
#define MOVES 2

@implementation CMMarbleMultiComboSprite

@synthesize soundFileName = soundFileName_;

- (void) removeSelf
{
	[self removeFromParent];
}

- (void) animate
{
	// create some action to
	CGSize l = self.contentSize;
	
	
	CGPoint targetPosition = self.position;
	targetPosition.y +=300;
	id actionMove = [CCMoveTo actionWithDuration:DEFAULT_COMBO_MOVE_DURATION position:targetPosition];
	id actionScale = [CCScaleTo actionWithDuration:DEFAULT_COMBO_SCALE_DURATION scale:DEFAULT_COMBO_SCALE_TARGET];
	
	id actionSkewStart = [CCEaseSineOut actionWithAction:[CCSkewBy actionWithDuration:TIME_DIF(MOVES, DEFAULT_COMBO_SCALE_DURATION)/2.0 skewX:+20 skewY:0]];
	id actionSkewMiddle = [CCEaseSineInOut actionWithAction:[CCSkewBy actionWithDuration:TIME_DIF(MOVES, DEFAULT_COMBO_SCALE_DURATION) skewX:-40 skewY:0]];
	id actionSkewEnd = [CCEaseSineIn actionWithAction:[CCSkewBy actionWithDuration:TIME_DIF(MOVES, DEFAULT_COMBO_SCALE_DURATION)/2.0 skewX:+20 skewY:0]];
	id skewAction = [CCRepeat actionWithAction:[CCSequence actions:actionSkewStart, actionSkewMiddle, actionSkewEnd, nil] times:MOVES];

	id actionDriftStart = [CCEaseSineOut actionWithAction:[CCMoveBy actionWithDuration:TIME_DIF(MOVES, DEFAULT_COMBO_SCALE_DURATION)/2.0 position:CGPointMake(l.width/6, 0)]];
	id actionDriftMiddle = [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:TIME_DIF(MOVES, DEFAULT_COMBO_SCALE_DURATION) position:CGPointMake(-l.width/3, 0)]];
	id actionDriftEnd = [CCEaseSineIn actionWithAction:[CCMoveBy actionWithDuration:TIME_DIF(MOVES, DEFAULT_COMBO_SCALE_DURATION)/2.0 position:CGPointMake(l.width/6, 0)]];
	id driftAction = [CCRepeat actionWithAction:[CCSequence actions:actionDriftStart, actionDriftMiddle,actionDriftEnd, nil] times:MOVES];
	
	id allActions = [CCSpawn actions:actionMove, actionScale, driftAction,skewAction,nil];
	id callAction = [CCCallFunc actionWithTarget:self selector:@selector(removeSelf)];

	[self runAction:[CCSequence actions:allActions,callAction, nil]];
	
	CCParticleSystem *emitter = [CCParticleSun node];
	emitter.posVar=CGPointMake(l.width/2.0,0);
	emitter.position = CGPointMake(l.width/2.0,38);
	ccBlendFunc p = emitter.blendFunc;
//	p.src = GL_SRC_ALPHA;
	emitter.blendFunc = p;
	//	NSLog(@"%d %d",emitter.blendFunc.src,emitter.blendFunc.dst);
	[self addChild:emitter z:10];
//	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];

}

- (void) dealloc
{
	self.soundFileName=nil;
	[super dealloc];
}
@end
