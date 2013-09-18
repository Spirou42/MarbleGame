//
//  CMParticleSystemQuad.m
//  MarbleGame
//
//  Created by Carsten Müller on 9/18/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMParticleSystemQuad.h"

@implementation CMParticleSystemQuad
@synthesize soundName = soundName_;

- (void) dealloc
{
  self.soundName = nil;
  [super dealloc];
}
@end

@implementation CMParticleSystem

@synthesize soundName = soundName_;

- (void) dealloc
{
  self.soundName = nil;
  [super dealloc];
}
@end