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

@implementation CMMarbleLevel

@synthesize backgroundFilename, overlayFilename, staticBodiesFilename, 
backgroundImage, overlayImage, shapeReader, name, 
baseURL,numberOfMarbles;

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
}

- (void) initGraphicsFromDict:(NSDictionary*) dict
{
	self.backgroundFilename     = [dict objectForKey:@"backgroundFilename"];
	self.overlayFilename        = [dict objectForKey:@"overlayFilename"];
	self.staticBodiesFilename   = [dict objectForKey:@"staticBodiesFilename"];
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

    [self initGraphicsFromDict:graphics];
		[self initPhysicsFromDict:physics];
		[self initAudioFromDict:audio];
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
	[super dealloc];
}

#pragma mark - Properties

- (CCSprite*) loadImageFrom:(NSString*) imageName
{
	if (!imageName || [imageName isEqualToString:@""]) {
		return nil;
	}
	return [CCSprite spriteWithFile:imageName];
}

- (CCSprite*) backgroundImage
{
	if (!self->backgroundImage) {
		self.backgroundImage = [self loadImageFrom:self.backgroundFilename];
	}
	return self->backgroundImage;
}

- (CCSprite*) overlayImage
{
	if(!self->overlayImage){
		self.overlayImage = [self loadImageFrom:self.overlayFilename];
	}
	return self->overlayImage;
}

- (CMSimpleShapeReader*) shapeReader
{
	if(!self->shapeReader){
		NSBundle *myBundle = [NSBundle bundleWithURL:self.baseURL];
		NSURL *resourceURL = [myBundle URLForResource:self.staticBodiesFilename withExtension:@"stb"];
		self.shapeReader =[[[CMSimpleShapeReader alloc] initWithContentsOfURL:resourceURL]autorelease];
	}
	return self->shapeReader;
}

- (void) releaseLevelData
{
	self.backgroundImage  = nil;
	self.overlayImage     = nil;
	self.shapeReader      = nil;
}
@end
