//
//  CMMarbleMultiComboSprite.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/7/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMarbleMultiComboSprite.h"
#import "CMLiquidAction.h"
#import "CMParticleSystemQuad.h"

#define TIME_DIF(swings,fullTime) (fullTime/(swings*2.0))
#define MOVES 2

@interface CMMarbleMultiComboSprite ()
@property (nonatomic,assign) CMParticleSystemQuad* particleSystem;
@property (nonatomic, assign) CGPoint originalPosVar;
@end



@implementation CMMarbleMultiComboSprite

@synthesize originalPosVar=originalPosVar_, offset=offset_;

- (void) removeSelf
{
	[self.gameDelegate removeEffect:self.particleSystem];
	[self removeFromParent];
}

-(void) onEnterTransitionDidFinish

//- (void) onEnter
{
	// create some action to
	CGSize l = self.contentSize;
	
	
	CGPoint targetPosition = self.position;
	targetPosition.y +=300;
	// Move
	id actionMove = [CCMoveTo actionWithDuration:DEFAULT_COMBO_MOVE_DURATION position:targetPosition];
	// Scale
	id actionScale = [CCScaleTo actionWithDuration:DEFAULT_COMBO_SCALE_DURATION scale:DEFAULT_COMBO_SCALE_TARGET];
	// rotate
	id actionRotate = [CCRotateBy actionWithDuration:DEFAULT_COMBO_SCALE_DURATION angle:360*1];
	
	// Skew
	id actionSkewStart = [CCEaseSineOut actionWithAction:[CCSkewBy actionWithDuration:TIME_DIF(MOVES, DEFAULT_COMBO_SCALE_DURATION)/2.0 skewX:20 skewY:l.height/8.0]];
	id actionSkewMiddle = [CCEaseSineInOut actionWithAction:[CCSkewBy actionWithDuration:TIME_DIF(MOVES, DEFAULT_COMBO_SCALE_DURATION) skewX:-40 skewY:-l.height/4.0]];
	id actionSkewEnd = [CCEaseSineIn actionWithAction:[CCSkewBy actionWithDuration:TIME_DIF(MOVES, DEFAULT_COMBO_SCALE_DURATION)/2.0 skewX:20 skewY:l.height/8.0]];
	id skewAction = [CCRepeat actionWithAction:[CCSequence actions:actionSkewStart, actionSkewMiddle, actionSkewEnd, nil] times:MOVES];

	// drift
	id actionDriftStart = [CCEaseSineOut actionWithAction:[CCMoveBy actionWithDuration:TIME_DIF(MOVES, DEFAULT_COMBO_SCALE_DURATION)/2.0 position:CGPointMake(l.width/6, 0)]];
	id actionDriftMiddle = [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:TIME_DIF(MOVES, DEFAULT_COMBO_SCALE_DURATION) position:CGPointMake(-l.width/3, 0)]];
	id actionDriftEnd = [CCEaseSineIn actionWithAction:[CCMoveBy actionWithDuration:TIME_DIF(MOVES, DEFAULT_COMBO_SCALE_DURATION)/2.0 position:CGPointMake(l.width/6, 0)]];
	id driftAction = [CCRepeat actionWithAction:[CCSequence actions:actionDriftStart, actionDriftMiddle,actionDriftEnd, nil] times:MOVES];
	
	// all
	id allActions = [CCSpawn actions:actionMove, actionScale,driftAction/*,skewAction,actionRotate*/,nil];
	id callAction = [CCCallFunc actionWithTarget:self selector:@selector(removeSelf)];

	[self runAction:[CCSequence actions:allActions,callAction, nil]];
	

	CMParticleSystemQuad *emitter = [CMParticleSystemQuad particleWithFile:MARBLE_SPEZIAL_EFFECT];
	emitter.posVar=CGPointMake(l.width/2.0,0);
	self.originalPosVar = emitter.posVar;
	self.particleSystem = emitter;
	self.offset = CGPointMake(0, -20);
	CGPoint k = cpvadd(self.position, self.offset);

	emitter.position =k ;
	
	[self.gameDelegate addEffect:emitter];
	
//	[self addChild:emitter z:1];
}

- (void) setPosition:(CGPoint)position
{
	[super setPosition:position];
	CGPoint v = self.offset;
	v.x *= self.scaleX;
	v.y *= self.scaleY;
	CGPoint k = cpvadd(self.position, v);

	self.particleSystem.position = k;
}

//- (void) setRotation:(float)rotation
//{
//	[super setRotation:rotation];
//	self.particleSystem.rotation = rotation;
//}
//-(void) setScale:(float)scale
//{
//	[super setScale:scale];
//	self.particleSystem.scale = scale;
//}
- (void) setScaleX:(float)scaleX
{
	[super setScaleX:scaleX];
	CGPoint pv = self.particleSystem.posVar;
	pv.x = self.originalPosVar.x * scaleX;
	self.particleSystem.posVar = pv;
}

//- (void) setSkewX:(float)skewX
//{
//	[super setSkewX:skewX];
//	self.particleSystem.skewX = skewX;
//}

//- (void) setSkewY:(float)skewY
//{
//	[super setSkewY:skewY];
//		self.particleSystem.skewY = skewY;
//}
//
//- (void) setScaleY:(float)scaleY
//{
//	[super setScaleY:scaleY];
//	self.particleSystem.scaleY = scaleY;
//}
//
- (void) dealloc
{
	self.soundName=nil;

	[super dealloc];
}
@end
