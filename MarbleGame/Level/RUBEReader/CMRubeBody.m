//
//  CMRubeBody.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/19/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMRubeBody.h"
#import "CMRubeSceneReader.h"
#import "CMRubeFixture.h"
#import "ChipmunkObject.h"
#import "ObjectiveChipmunk.h"
#import "CMRubeImage.h"
#import "cocos2d.h"
#import "CMPhysicsSprite.h"

@interface CMRubeBody ()
@property (nonatomic, retain) ChipmunkBody* cpBody;
@property (nonatomic, retain) CMPhysicsSprite* cachedPhysicsSprite;
@end

@implementation CMRubeBody

@synthesize name = name_, type = type_, angle = angle_, angularVelocity = angularVelocity_,
linearVelocity = linearVelocity_, position = position_, fixtures = fixtures_, mass = mass_,
angularDamping=angularDamping_, linearDamping = linearDamping_, cpBody = cpBody_, attachedImages= attachedImages_,
cachedPhysicsSprite = cachedPhysicsSprite_, soundName = soundName_,fixedRotation=fixedRotation_;

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
	self.cachedPhysicsSprite = nil;
  self.mass = 0.0;
}

- (NSString*) stringFromBodyType:(CMGameBodyType)bodyType
{
	NSString *result = nil;
	switch (bodyType) {
		case kGameBody_Emitter:
			result =@"Emitter";
			break;
		case kGameBody_Respawn:
			result = @"Respawn";
			break;
		case kGameBody_Undefined:
			result = @"Undefined";
			break;
		case kGameBody_World:
			result = @"World";
			break;
		case kGameBody_Mechanic:
			result = @"Mechanic";
			break;
	}
	return result;
}

- (CMGameBodyType) bodyTypeFromString:(NSString*)string
{
	CMGameBodyType result = kGameBody_Undefined;
	NSString *typeString = [string uppercaseString];
	if ([typeString isEqualToString:@"UNDEFINED"]) {
		result = kGameBody_Undefined;
	}else if([typeString isEqualToString:@"WORLD"]){
		result = kGameBody_World;
	}else if ([typeString isEqualToString:@"MARBLEEMITTER"]){
		result = kGameBody_Emitter;
	}else if ([typeString isEqualToString:@"MARBLERESPAWN"]){
		result = kGameBody_Respawn;
	}else if ([typeString isEqualToString:@"MECHANIC"]){
		result = kGameBody_Mechanic;
	}
	return result;
}


- (void) initializeCustomProperties:(NSDictionary*)dict
{
	if ([dict allKeys].count > 0) {
		NSString *p = [dict objectForKey:@"bodyType"];
		self.gameType = [self bodyTypeFromString:p];
		self.layerName = [dict objectForKey:@"Layer"];
	}
}

- (id) initWithDictionary:(NSDictionary *)dict
{
	self = [super init];
	if (self) {
    [self initDefaults];
		self.name = [dict objectForKey:@"name"];
		self.position = pointFromRUBEPoint([dict objectForKey:@"position"]);
		self.type = (CMRubeBodyType)[[dict objectForKey:@"type"] integerValue];
    self.angle =  [[dict objectForKey:@"angle"]floatValue];
    self.angularVelocity = [[dict objectForKey:@"angularVelocity"]floatValue];
    self.linearVelocity = pointFromRUBEPoint([dict objectForKey:@"linearVelocity"]);
    self.mass = [[dict objectForKey:@"massData-mass"]floatValue];
		self.fixedRotation = [[dict objectForKey:@"fixedRotation"]boolValue];
    // now iterate over all our fixtures and create them
		[self initializeCustomProperties:customPropertiesFrom([dict objectForKey:@"customProperties"])];
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
	self.cachedPhysicsSprite = nil;
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
#pragma mark - Properties
//***********************************************************

- (CMPhysicsSprite*) physicsSprite
{
	if ((self.gameType == kGameBody_Respawn) || (self.gameType == kGameBody_Emitter)) {
		return nil;
	}
	if (!self->cachedPhysicsSprite_) {
		[self createPhysicsSprite];
	}
	CGPoint pos = self.position;
	self->cachedPhysicsSprite_.position = pos;
	self->cachedPhysicsSprite_.originalPosition = pos;
	return self->cachedPhysicsSprite_;
}

- (NSArray*) chipmunkShapes
{
	NSMutableArray *result = [NSMutableArray array];
	for (CMRubeFixture* a in self.fixtures) {
    [result addObjectsFromArray:a.chipmunkObjects];
	}
	return result;
}
- (ChipmunkBody*) body
{
	return self->cpBody_;
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

- (void) attachImage:(CMRubeImage*) rubeImage
{
	[self.attachedImages addObject:rubeImage];
}


//***********************************************************
#pragma mark - Helper
//***********************************************************

- (CGFloat) moment
{
  CGFloat moment = 0.0f;
	if (self.fixtures.count) {
		for (CMRubeFixture *f in self.fixtures) {
			moment += [f momentForMass:self.mass];
		}
	}else{
		moment = cpMomentForCircle(100, 1, 1, ccp(0, 0));
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
/*  if (!self.fixtures.count) {
    return;
  }*/
  ChipmunkBody *body = nil;
  if (self.type ==kRubeBody_static) {
    body = [ChipmunkBody staticBody];
    body.pos = self.position;
  }else{
    CGFloat moment = [self moment];
    body = [ChipmunkBody bodyWithMass:self.mass andMoment:moment];
    body.pos = self.position;
		if (self.fixedRotation) {
			body.angVelLimit=0.0;
			body.velLimit = 0.0;
		}
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

- (void) createPhysicsSprite
{
	// retrieve the sprite image
	CMRubeImage *spriteImage = [self imageForType:kRubeImageType_Background];
	NSString *spriteName = spriteImage.filename;
	if (!spriteName) {
		return;
	}
	CMPhysicsSprite * result = [CMPhysicsSprite spriteWithFile:spriteName];
	result.layerName = self.layerName;
	result.type = self.gameType;
	result.opacity = 255*spriteImage.rubeOpacity;

	result.chipmunkBody = self.cpBody;
	[result addShapes:self.chipmunkShapes];
//	NSLog(@"created: %@ (%@)",result, NSStringFromSize(result.contentSize));
	result.scale = spriteImage.rubeScale / result.contentSize.height;
	if (spriteImage.rubeAspectScale != 1.0) {
    	result.scaleX *= spriteImage.rubeAspectScale;
	}

	CMRubeImage *overlayImage = [self imageForType:kRubeImageType_Overlay];
	if (overlayImage) {
		CCSprite *overlaySprite = [CCSprite spriteWithFile:overlayImage.filename];


		overlaySprite.rotation=CC_DEGREES_TO_RADIANS(overlayImage.rubeAngle);

//		p.x = 100;
//		overlaySprite.position= p;
		result.overlayNode = overlaySprite;
		result.overlayOffset = overlayImage.rubeCenter;

	}
	
	self.cachedPhysicsSprite = result;
}
@end
