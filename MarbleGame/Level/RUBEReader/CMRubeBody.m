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
#import "ObjectiveChipmunk.h"
#import "CMRubeImage.h"

@interface CMRubeBody ()
@property (nonatomic, retain) ChipmunkBody* cpBody;
@end

@implementation CMRubeBody

@synthesize name = name_, type = type_, angle = angle_, angularVelocity = angularVelocity_,
linearVelocity = linearVelocity_, position = position_, fixtures = fixtures_,
angularDamping=angularDamping_, linearDamping = linearDamping_, cpBody = cpBody_, attachedImages= attachedImages_;

- (void) initDefaults
{
  self.fixtures = [NSMutableArray array];
	self.attachedImages = [NSMutableArray array];
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
    [self createChipmunkBody];

	}
	return self;
}


- (void) dealloc
{
	self.name = nil;
	self.fixtures = nil;
	self.attachedImages = nil;
	[super dealloc];
}

//***********************************************************
#pragma mark - ChipmunkObject
//***********************************************************
- (NSArray*) chipmunkObjects
{
  NSMutableArray *result = [NSMutableArray array];
  if (self.cpBody && (self.type != kRubeBody_static)) {
    [result addObject:self.cpBody];
  }
  [result addObjectsFromArray:[self allShapes]];

  return result;
}

//***********************************************************
#pragma mark - Image Accessors
//***********************************************************

- (id) imageForType:(CMRubeImageType)type
{
	id result = nil;
	for (CMRubeImage* rImage in self.attachedImages) {
    if (rImage.type == type) {
			result = rImage;
			break;
		}
	}
	return result;
}

//***********************************************************
#pragma mark - Helper
//***********************************************************

- (CGFloat) moment
{
  CGFloat moment = 0.0f;
  for (CMRubeFixture *f in self.fixtures) {
    moment += [f momentForMass:self.mass];
  }
  return moment;
}
- (NSArray*) allShapes
{
  NSMutableArray *shapes = [NSMutableArray array];
  for (CMRubeFixture *fixture in self.fixtures) {
    id<NSFastEnumeration> fixtureShapes = [fixture chipmunkObjects];
    for (id s in fixtureShapes) {
      [shapes addObject:s];
    }
  }
  return shapes;
}

- (void) createChipmunkBody
{
  if (!self.fixtures.count) {
    return;
  }
  ChipmunkBody *body = nil;
  if (self.type ==kRubeBody_static) {
    body = [ChipmunkBody staticBody];
    body.pos = self.position;
  }else{
    CGFloat moment = [self moment];
    body = [ChipmunkBody bodyWithMass:self.mass andMoment:moment];
    body.pos = self.position;
  }
  id<NSFastEnumeration> myShapes = [self allShapes];
  for (ChipmunkShape* cs in myShapes) {
    cs.body = body;
    if (self.type == kRubeBody_static) {
      cs.collisionType = COLLISION_TYPE_BORDER;
    }
  }
  self.cpBody = body;
}
@end
