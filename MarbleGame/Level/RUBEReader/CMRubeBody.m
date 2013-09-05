//
//  CMRubeBody.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/19/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMRubeBody.h"
#import "CMMarbleRubeReader.h"
#import "CMRubeFixture.h"
#import "ChipmunkObject.h"

@implementation CMRubeBody

@synthesize name = _name, type = _type, angle = _angle, angularVelocity = _angularVelocity,
linearVelocity = _linearVelocity, position = _position, fixtures = _fixtures,
angularDamping=_angularDamping, linearDamping = _linearDamping;

- (void) initDefaults
{
  self.fixtures = [NSMutableArray array];
  self.name = nil;
  self.position = CGPointZero;
  self.type = kFixtureCircle;
  self.angle = 0.0;
  self.angularVelocity = 0.0;
  self.linearVelocity = CGPointZero;
  self.linearDamping = 0.0;
  self.mass = 0.0;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
	self = [super init];
	if (self) {
    [self initDefaults];
		self.name = [dict objectForKey:@"name"];
		self.position = pointFromRUBEPoint([dict objectForKey:@"position"]);
		self.type = [[dict objectForKey:@"type"] integerValue];
    self.angle =  [[dict objectForKey:@"angle"]floatValue];
    self.angularVelocity = [[dict objectForKey:@"angularVelocity"]floatValue];
    self.linearVelocity = pointFromRUBEPoint([dict objectForKey:@"linearVelocity"]);
    self.mass = [[dict objectForKey:@"massData-mass"]floatValue];
    // now iterate over all our fixtures and create them
    for (NSDictionary *fixtureDict in [dict objectForKey:@"fixture"]) {
      CMRubeFixture *fixture = [[CMRubeFixture alloc] initWithDictionary:fixtureDict];
      [self.fixtures addObject:fixture];
      [fixture release];
    }
	}
	return self;
}


- (void) dealloc
{
	self.name = nil;
	self.fixtures = nil;
	[super dealloc];
}

//***********************************************************
#pragma mark - ChipmunkObject
//***********************************************************
- (id <NSFastEnumeration>) chipmunkObjects
{
  return [NSArray array];
}

//***********************************************************
#pragma mark - Helper
//***********************************************************


@end
