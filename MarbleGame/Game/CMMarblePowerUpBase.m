//
//  CMMarblePowerUpBase.m
//  MarbleGame
//
//  Created by Carsten Müller on 9/26/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMarblePowerUpBase.h"
#import "CMMarbleSprite.h"
@interface CMMarblePowerUpBase ()
@property (nonatomic,retain) CMParticleSystemQuad* particles;
@property (nonatomic,retain) NSTimer * actionRemoveTimer; // started in case the activeTime is not -1
@property (nonatomic, assign) NSTimeInterval startTime;
@end


@implementation CMMarblePowerUpBase
@synthesize parentMarble = parentMarble_, activeTime = activeTime_;
@synthesize particles=particles_, actionRemoveTimer = actionRemoveTimer_, startTime = startTime_;


- (id) init
{
  self = [super init];
  if(self){
    self.activeTime = -1.0;
    self.actionRemoveTimer = nil;
  }
  return self;
}

- (void) dealloc
{
	self.particles = nil;
  if (self.actionRemoveTimer) {
    [self.actionRemoveTimer invalidate];
  }
  self.actionRemoveTimer = nil;
	[super dealloc];
}
- (CGFloat) scoreValue
{
  return 0.0;
}

- (NSTimeInterval) timeValue
{
  return 0.0;
}

- (CMParticleSystemQuad*) particleEffect
{
	return self.particles;
}

- (void) performActionFor:(CMMarbleSprite *)marble
{
  if (self.actionRemoveTimer) {
    [self.actionRemoveTimer invalidate];
    self.actionRemoveTimer = nil;
  }
}
- (NSTimeInterval) remainingTime
{
  if (self.activeTime<0.0f) {
    return -1.0;
  }
  NSTimeInterval bla = self.activeTime - ([NSDate timeIntervalSinceReferenceDate] - self.startTime);
  return bla;
}

- (void) removeAction:(NSTimer*) someTimer;
{
  self.actionRemoveTimer = nil;
  self.parentMarble.marbleAction = nil;
}

- (void) setParentMarble:(CMMarbleSprite *)pMarble
{
  if (self->parentMarble_ != pMarble) {
    self->parentMarble_ = pMarble;
    if((pMarble != nil) && self.activeTime >0.0){
      NSTimer* remTimer = [NSTimer scheduledTimerWithTimeInterval:self.activeTime target:self selector:@selector(removeAction:) userInfo:nil repeats:NO];
      self.actionRemoveTimer = remTimer;
    }
    self.startTime = [NSDate timeIntervalSinceReferenceDate];
  }
}

- (void) update
{
  if (!self.parentMarble) {
    return;
  }
  self.particles.position = self.parentMarble.position;
}

@end
