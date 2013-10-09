//
//  CMMarbleEmitter.m
//  MarbleGame
//
//  Created by Carsten Müller on 9/27/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMarbleEmitter.h"
#import "CMMarbleGameDelegate.h"
#import "CMMarbleSimulationLayer.h"
#import "CMMarbleSprite.h"

@interface CMMarbleEmitter ()
@property (nonatomic, retain) NSTimer* marbleTimer;
@property (nonatomic, assign) NSInteger firedMarbles;
@end


@implementation CMMarbleEmitter

@synthesize  simulationLayer = simulationLayer_, marblesToEmit = marblesToEmit_, marbleFrequency = marbleFrequency_,
position = position_,positionVariance = positionVariance_, velocity=velocity_,velocityVariance=velocityVariance_, angle=angle_, angleVariance=angleVariance_,
angularVelocity =angularVelocity_, angularVelocityVariance = angularVelocityVariance_, releaseOnFinish = releaseOnFinish_;

@synthesize marbleTimer=marbleTimer_, firedMarbles =firedMarbles_;

- (void) initializeDefaults
{
  self.simulationLayer = nil;
  self.marblesToEmit = 10;
  self.marbleFrequency = 1.0;
  self.position = MARBLE_FIRE_POINT;
	self.positionVariance = CGPointZero;
  self.velocity = MARBLE_FIRE_SPEED;
  self.velocityVariance = MARBLE_FIRE_SPEED/2.0;
  self.angle = 0.0;
  self.angleVariance = 360.0;
  self.angularVelocity = 0.0;
  self.angularVelocityVariance = 0.0;
  self.firedMarbles = 0;
	self.releaseOnFinish = NO;
}

- (id) init
{
  self = [super init];
  if (self) {
    [self initializeDefaults];
  }
  return self;
}

- (void) dealloc
{
  self.marbleTimer = nil;
  self.simulationLayer = nil;
  [super dealloc];
}
#pragma mark - Properties

- (void) setMarbleTimer:(NSTimer *)marbleTimer
{
  if (self->marbleTimer_ != marbleTimer) {
    if (self->marbleTimer_) {
      [self->marbleTimer_ invalidate];
      [self->marbleTimer_ release];
    }
    self->marbleTimer_ = [marbleTimer retain];
  }
}

#pragma mark - actions

- (CGPoint) velocityForMarbleAtAngle:(CGFloat) angle;
{
  CGPoint result = CGPointZero;
  CGPoint uVect = cpvforangle((angle * M_PI / 180.0f));
  CGFloat targetVelocity = self.velocity;
  CGFloat vv = self.velocityVariance*2.0;
  CGFloat velVar = arc4random_uniform(vv)-self.velocityVariance;
  targetVelocity+= velVar;
  if (targetVelocity<0.0) {
    return result;
  }
  result = cpvmult(uVect, targetVelocity);
  return result;
}


- (CGFloat) angleForMarble
{
  CGFloat result = self.angle;
  CGFloat av = self.angleVariance * 2.0;
  CGFloat vAngle = arc4random_uniform(av)-self.angleVariance;
  result +=vAngle;
  while (result<0.0) {
    result +=360.0;
  }
  while (result > 360.0) {
    result -=360.0;
  }
  return result;
}

- (CGPoint) positionForMarble
{
	CGPoint result = self.position;

	if (self.positionVariance.x != 0.0) {
		CGFloat xv = self.positionVariance.x / 2.0;
		result.x = result.x + (arc4random_uniform(xv)-self.positionVariance.x);
	}
	
	if (self.positionVariance.y != 0.0) {
		CGFloat yv = self.positionVariance.y / 2.0;
				result.y = result.y + (arc4random_uniform(yv)-self.positionVariance.y);
	}
	
	return result;
}

- (void) fireMarble:(NSTimer*) currentTimer
{
  NSObject<CMMarbleGameDelegate>* gameDelegate = self.simulationLayer.gameDelegate;
 	NSUInteger marbleIndex = [gameDelegate marbleIndex];
  NSString *marbleSet = [gameDelegate marbleSetName];
	CMMarbleSprite *ms = [[[CMMarbleSprite alloc]initWithBallSet:marbleSet ballIndex:marbleIndex mass:MARBLE_MASS andRadius:MARBLE_RADIUS]autorelease];
  ms.gameDelegate = gameDelegate;
  ChipmunkBody *dB = ms.chipmunkBody;
  dB.velLimit = MARBLE_MAX_VELOCITY;

  // emit position
  CGPoint emitPos = [self positionForMarble];;

  CGFloat emitAngle = [self angleForMarble];

  //emit velocity
  CGPoint marbleEmitVelocity = [self velocityForMarbleAtAngle:emitAngle];
	dB.vel = marbleEmitVelocity;

	dB.pos = self.position;
	self.firedMarbles++;
	if (self.firedMarbles > (self.marblesToEmit-1)) {
		self.marbleTimer = nil;
		if (self.releaseOnFinish) {
			[self autorelease];
		}
	}
  [self.simulationLayer marbleFired:ms];

}

- (void) startEmitter
{
	if(!self.marblesToEmit)
		return;
  if (!self.simulationLayer) {
    return;
  }
  if (self.marbleTimer) { // don't start if the timer is running
    return;
  }
  if (self.marbleFrequency == 0) { // all at once not implemented yet
    return;
  }

  self.firedMarbles = 0;
  NSTimeInterval timeBetweenMarbles = (1.0/self.marbleFrequency);
  NSTimer * fireTimer = [NSTimer scheduledTimerWithTimeInterval:timeBetweenMarbles target:self selector:@selector(fireMarble:) userInfo:nil repeats:YES];
  self.marbleTimer = fireTimer;
}

- (void) stopEmitter
{
  if (!self.simulationLayer) {
    return;
  }
  self.marbleTimer = nil;
}
@end
