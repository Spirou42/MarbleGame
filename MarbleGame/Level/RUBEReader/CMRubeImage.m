//
//  CMRubeImage.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/19/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMRubeImage.h"
#import "CMRubeSceneReader.h"
#import "cocos2d.h"


@interface CMRubeImage()
@property (nonatomic,retain) CCSprite* cachedSprite;
@end

@implementation CMRubeImage
@synthesize type = type_, name = name_,cachedSprite = cachedSprite_;


- (void) initDefaults
{
	self.name = nil;
	self.type = kRubeImageType_Unknown;
	self.rubeOpacity = 1.0;
	self.rubeScale = 1.0;
	self.rubeAspectScale = 1.0;
	self.rubeAngle = 0.0;
	self.rubeCenter = CGPointZero;
	self.rubeBodyIndex = NSNotFound;
	self.filename = nil;
	self.rubeRenderOrder = 0;
}

- (NSString*) stringFromImageType:(CMRubeImageType)imageType
{
	NSString *result = nil;
	switch (imageType) {
		case kRubeImageType_Background:
		result =@"Background";
		break;
		case kRubeImageType_Overlay:
		result = @"Overlay";
		break;
//		case kRubeImageType_Sprite:
//		result = @"Sprite";
//		break;
		case kRubeImageType_Unknown:
		default:
    result = @"Unkown";
    break;
	}
	return result;
}

- (CMRubeImageType) imageTypeFromString:(NSString*)string
{
	CMRubeImageType result = kRubeImageType_Unknown;
	NSString *typeString = [string uppercaseString];
	if ([typeString isEqualToString:@"UNDEFINED"]) {
		result = kRubeImageType_Unknown;
	}else if([typeString isEqualToString:@"BACKGROUND"]){
		result = kRubeImageType_Background;
	}else if ([typeString isEqualToString:@"OVERLAY"]){
		result = kRubeImageType_Overlay;
	}
//  else
//		if ([typeString isEqualToString:@"SPRITE"]){
//		result = kRubeImageType_Sprite;
//	}
	return result;
}

- (void) initializeCustomProperties:(NSDictionary*) dict
{
	self.type = [self imageTypeFromString:[dict objectForKey:@"imageType"]];
}

- (id) initWithDictionary:(NSDictionary *)dict
{
	self = [super init];
	if (self) {
		[self initDefaults];
		self.name = [dict objectForKey:@"name"];
		self.rubeOpacity = [[dict objectForKey:@"opacity"]floatValue];
		self.rubeRenderOrder = [[dict objectForKey:@"renderOrder"]integerValue];
		self.rubeScale = [[dict objectForKey:@"scale"]floatValue];
		self.rubeAspectScale = [[dict objectForKey:@"aspectScale"]floatValue];
		self.rubeAngle = [[dict objectForKey:@"angle"]floatValue];
		self.rubeBodyIndex = [[dict objectForKey:@"body"]integerValue];
		self.rubeCenter =pointFromRUBEPoint([dict objectForKey:@"center"]);
		self.filename = [dict objectForKey:@"file"];
		[self initializeCustomProperties:customPropertiesFrom([dict objectForKey:@"customProperties"])];
		
	}
	return self;
}

-(void) dealloc
{
	self.name = nil;
	self.filename = nil;
	[super dealloc];
}

#pragma mark - Sprite Access

- (void) createSprite
{
	CCSprite *theSprite = [CCSprite spriteWithFile:self.filename];
//	NSLog(@"created a sprite %@ (%@)",theSprite,NSStringFromSize(theSprite.contentSize));
  theSprite.opacity = 255.0*self.rubeOpacity;
	self.cachedSprite = theSprite;
}

- (CCSprite*) sprite
{
	if (!self->cachedSprite_) {
		[self createSprite];
	}
	return self.cachedSprite;
}
@end
