//
//  CMMarbleLevel.m
//  Chipmonkey
//
//  Created by Carsten Müller on 6/20/12.
//  Copyright (c) 2012 Carsten Müller. All rights reserved.
//

#import "CMMarbleLevel.h"
#import "CMSimpleShapeReader.h"
#import "cocos2d.h"
#import "CMRubeSceneReader.h"
#import "CMRubeBody.h"
#import "CMRubeImage.h"
#import "ChipmunkObject.h"
#import "CMMarbleEmitter.h"

@interface CMMarbleLevel ()
@property(retain, nonatomic) CMSimpleShapeReader *shapeReader ;						///< shapeReader is depricated now. will be replaced by the RubeReader
@property(retain, nonatomic) CMMarbleEmitter *cachedMarbleEmitter;
@end

@implementation CMMarbleLevel

@synthesize backgroundFilename = backgroundFilename_, overlayFilename = overlayFilename_, staticBodiesFilename = staticBodiesFilename_ ,
backgroundImage = backgroundImage_, overlayImage = overlayImage_, shapeReader = shapeReader_, name = name_,
baseURL = baseURL_,numberOfMarbles = numberOfMarbles_,scoreLimits = scoreLimits_,timeLimits = timeLimits_,
rubeFileName = rubeFileName_, rubeReader = rubeReader_;

- (void) initDefaults
{
	self.baseURL              = nil;
	self.backgroundImage      = nil;
	self.overlayImage         = nil;
	self.name                 = nil;
	self.backgroundFilename   = nil;
	self.overlayFilename      = nil;
	self.staticBodiesFilename = nil;
	self.shapeReader          = nil;
	self.rubeFileName					= nil;
  self.rubeReader           = nil;
  self.cachedMarbleEmitter  = nil;
}

- (void) initGraphicsFromDict:(NSDictionary*) dict
{
	self.backgroundFilename     = [dict objectForKey:@"backgroundFilename"];
	self.overlayFilename        = [dict objectForKey:@"overlayFilename"];
	self.staticBodiesFilename   = [dict objectForKey:@"staticBodiesFilename"];
	self.rubeFileName						= [dict objectForKey:@"RUBELevel"];
}

- (void) initPhysicsFromDict:(NSDictionary*) dict
{
	
}

- (void) initAudioFromDict:(NSDictionary*) dict
{
	
}

- (id) init
{
	if((self = [super init])){
		[self initDefaults];
	}
	return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
	if((self = [super init])){
		[self initDefaults];

		self.name               = [dict objectForKey:@"levelName"];
		self.numberOfMarbles    = [[dict objectForKey:@"numOfMarbles"] unsignedIntValue];
		NSDictionary *graphics  = [dict objectForKey:@"graphics"];
		NSDictionary *audio     = [dict objectForKey:@"audio"];
		NSDictionary *physics   = [dict objectForKey:@"physics"];
		self.scoreLimits				= [dict valueForKeyPath:@"scoreLimits.score"];
		self.timeLimits					= [dict valueForKeyPath:@"scoreLimits.time"];
    [self initGraphicsFromDict:graphics];
		[self initPhysicsFromDict:physics];
		[self initAudioFromDict:audio];
//		if (self.rubeFileName) {
//			// get a rube reader and try to read the file
//			CMMarbleRubeReader *reader = [[[CMMarbleRubeReader alloc]initWithContentsOfFile:self.rubeFileName]autorelease];
//		}
	}
	return self;
}

- (void) dealloc
{
	self.backgroundFilename     = nil;
	self.overlayFilename        = nil;
	self.staticBodiesFilename   = nil;
	self.backgroundImage        = nil;
	self.overlayImage           = nil;
	self.scoreLimits 						= nil;
	self.timeLimits							= nil;
	self.rubeFileName 					= nil;
  self.rubeReader             = nil;
  self.shapeReader            = nil;
  self.cachedMarbleEmitter    = nil;
	[super dealloc];
}

#pragma mark - Properties

- (NSInteger) amateurScore
{
	return [[self.scoreLimits objectForKey:@"Amateur"]integerValue];
}

- (NSInteger) professionalScore
{
	return [[self.scoreLimits objectForKey:@"Professional"]integerValue];
}

- (NSInteger) masterScore
{
	return [[self.scoreLimits objectForKey:@"Master"]integerValue];
}

- (NSTimeInterval) timeIntervalFromString:(NSString*)value
{
	NSTimeInterval result = 0.0;
	NSArray* segments = [value componentsSeparatedByString:@":"];
	if (segments.count ==2) {
		NSString *p1 = [segments objectAtIndex:0];
		NSString *p2 = [segments objectAtIndex:1];
		result = [p1 integerValue] * 60.0f + [p2 integerValue];
	}else if (segments.count == 1){
		NSString *p1 = [segments objectAtIndex:0];
		result = [p1 integerValue] * 1.0f;
	}
	return result;
}

- (NSTimeInterval) amateurTime
{
	return [self timeIntervalFromString:[self.timeLimits objectForKey:@"Amateur"]];
}

- (NSTimeInterval) professionalTime
{
	return [self timeIntervalFromString:[self.timeLimits objectForKey:@"Professional"]];
}

- (NSTimeInterval) masterTime
{
	return [self timeIntervalFromString:[self.timeLimits objectForKey:@"Master"]];
}

- (CMRubeSceneReader*) rubeReader
{
  if (self->rubeFileName_ && !self->rubeReader_) {
    CMRubeSceneReader *reader = [[[CMRubeSceneReader alloc]initWithContentsOfFile:self.rubeFileName]autorelease];
    self.rubeReader = reader;
  }
  return self->rubeReader_;
}

- (CMSimpleShapeReader*) shapeReader
{
	if(!self->shapeReader_){
		NSBundle *myBundle = [NSBundle bundleWithURL:self.baseURL];
		NSURL *resourceURL = [myBundle URLForResource:self.staticBodiesFilename withExtension:@"stb"];
		self.shapeReader =[[[CMSimpleShapeReader alloc] initWithContentsOfURL:resourceURL]autorelease];
	}
	return self->shapeReader_;
}

- (CCSprite*) backgroundImage
{
	if (self.isRubeLevel) {
		CMRubeBody *world = [self.rubeReader bodyWithName:@"World"];
		CMRubeImage *background = [world imageForType:kRubeImageType_Background];
		self.backgroundImage = background.sprite;
	}else
	if (!self->backgroundImage_) {
		self.backgroundImage = [self loadImageFrom:self.backgroundFilename];
	}
	return self->backgroundImage_;
}

- (CCSprite*) overlayImage
{
	if (self.isRubeLevel) {
		CMRubeBody *world = [self.rubeReader bodyWithName:@"World"];
		CMRubeImage *overlay = [world imageForType:kRubeImageType_Overlay];
		self.overlayImage = overlay.sprite;
	}else	if(!self->overlayImage_){
		self.overlayImage = [self loadImageFrom:self.overlayFilename];
	}
	return self->overlayImage_;
}

- (BOOL) isRubeLevel
{
  return (self->rubeFileName_ != nil);
}

#pragma mark - Level Object Accessors

- (NSArray*) worldShapes
{
	if (self.isRubeLevel) {
		CMRubeBody* world = [self.rubeReader bodyWithName:@"World"];
		return world.chipmunkShapes;
	}else{
    CGFloat borderRadius = 50;
    NSMutableArray *result = self.shapeReader.shapes;
    ChipmunkStaticSegmentShape *leftBorder = [ChipmunkStaticSegmentShape segmentWithBody:nil from:CGPointMake(-borderRadius, 0) to:CGPointMake(-borderRadius, 768) radius:borderRadius];
    ChipmunkStaticSegmentShape * rightBorder = [ChipmunkStaticSegmentShape segmentWithBody:nil from:CGPointMake(1024+borderRadius, 0) to:CGPointMake(1024+borderRadius, 768) radius:borderRadius];
    [result addObject:leftBorder];
    [result addObject:rightBorder];
		return result;
	}
}

- (NSArray*) staticSprites
{
	NSMutableArray *result = [NSMutableArray array];
	if(!self.isRubeLevel)
		return result;

	for (CMRubeBody* rBody in self.rubeReader.bodies) {
    if ((rBody.type==kRubeBody_static) && ![rBody.name isEqualToString:@"World"]) {
			[result addObject:rBody.physicsSprite];
		}
	}
	return result;
}

- (NSArray*) dynamicSprites
{
	NSMutableArray *result = [NSMutableArray array];
	if(!self.isRubeLevel)
		return result;
	
	for (CMRubeBody* rBody in self.rubeReader.bodies) {
    if ((rBody.type==kRubeBody_dynamic)) {
			[result addObject:rBody.physicsSprite];
		}
	}
	return result;
}


- (NSArray*) staticObjects
{
	if (self.isRubeLevel) {
		return self.rubeReader.staticChipmunkObjects;
	}else{
		return self.shapeReader.shapes;
	}
}
- (NSArray*) constrains
{
	if (self.isRubeLevel) {
		return self.rubeReader.joints;
	}
	return  nil;
}

- (CMMarbleEmitter*) createMarbleEmitter
{
  CMMarbleEmitter* emitter =[CMMarbleEmitter new];
  emitter.marbleFrequency = 8.0;
  emitter.marblesToEmit = self.numberOfMarbles;
  return emitter;
}

- (CMMarbleEmitter*) marbleEmitter
{
  if (!self.cachedMarbleEmitter) {
    self.cachedMarbleEmitter = [self createMarbleEmitter];
  }
  return self.cachedMarbleEmitter;
}


#pragma mark - Helpers

- (CCSprite*) loadImageFrom:(NSString*) imageName
{
	if (!imageName || [imageName isEqualToString:@""]) {
		return nil;
	}
	NSString *fileName =[imageName stringByAppendingPathExtension:@"png"];
	
	return [CCSprite spriteWithFile:fileName];
}





- (void) releaseLevelData
{
	self.backgroundImage  = nil;
	self.overlayImage     = nil;
	self.shapeReader      = nil;
  self.rubeReader       = nil;
}
@end
