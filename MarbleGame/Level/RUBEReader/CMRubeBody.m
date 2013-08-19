//
//  CMRubeBody.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/19/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMRubeBody.h"

@implementation CMRubeBody
@synthesize name = _name, type = _type, angle = _angle, angularVelocity = _angularVelocity,
linearVelocity = _linearVelocity, position = _position, fixtures = _fixtures;

- (void) dealloc
{
	self.name = nil;
	self.fixtures = nil;
	[super dealloc];
}
@end
