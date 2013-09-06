//
//  CMMarbleRubeReader.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/19/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMarbleRubeReader.h"
#import "CMRubeBody.h"
#import "CMRubeFixture.h"
#import "cocos2d.h"
#import "ChipmunkObject.h"

@implementation CMMarbleRubeReader
@synthesize  bodies = _bodies, images = _images, joints = _joints, gravity = _gravity;

- (void) initDefaults
{
	self.bodies = [NSMutableArray array];
	self.images = [NSMutableArray array];
	self.joints = [NSMutableArray array];
}

- (id) initWithContentsOfFile:(NSString *)filePath
{
	NSString* fullPath = [[CCFileUtils sharedFileUtils]fullPathForFilenameIgnoringResolutions:filePath];
												
	NSURL * fileURL = [NSURL fileURLWithPath:fullPath];
	return [self initWithContentsOfURL:fileURL];
}

- (void) initializeWithDictionary:(NSDictionary*) dict
{
	// initialize myself
	self.gravity = pointFromRUBEPoint([dict objectForKey:@"gravity"]);
	
	// iterate through all bodies creating them
	for (NSDictionary* bodyDict in [dict objectForKey:@"body"]) {
    CMRubeBody *aBody = [[CMRubeBody alloc]initWithDictionary:bodyDict];
		[self.bodies addObject:aBody];
    [aBody release];
	}
}

- (id) initWithContentsOfURL:(NSURL *)fileURL
{
	self = [super init];
	if (self) {
		[self initDefaults];
		// read URL into PLIST
		NSData *JSONData = [NSData dataWithContentsOfURL:fileURL];
		NSError *error;
		id rubeJson = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error];
//		NSLog(@"Json: %@",rubeJson);
		[self initializeWithDictionary:rubeJson];
	}
	return self;
}


- (void) dealloc
{
	self.bodies = nil;
	self.images = nil;
	self.joints = nil;
	[super dealloc];
}
#pragma mark - Properties

- (NSArray*) staticBodies
{
  NSMutableArray *results = [NSMutableArray array];
  for (CMRubeBody* body in self.bodies) {
    if (body.type == kRubeBody_static) {
      [results addObject:body];
    }
  }
  return results;
}

- (NSArray*) staticShapes
{
  NSMutableArray *results = [NSMutableArray array];
  for (CMRubeBody * body in self.bodies) {
    if (body.type == kRubeBody_static) {
      // collect fixtures of the body;
      for (CMRubeFixture *fix in body.fixtures) {
        for (id k in fix.chipmunkObjects) {
          [results addObject:k];
        }
      }
    }
  }
  return results;
}

- (NSArray*) staticChipmunkObjects
{
  NSMutableArray *result = [NSMutableArray array];
  for (CMRubeBody *b in [self staticBodies]) {
    [result addObjectsFromArray:[b chipmunkObjects]];
  }
  return result;
}


#pragma mark - ChipmunkObject
- (NSArray*) chipmunkObjects
{
  return [NSArray array];
}

@end


CGPoint pointFromRUBEPoint(id input)
{
	if ([input isKindOfClass:[NSString class]] || [input isKindOfClass:[NSNumber class]]) {
		return CGPointMake(0, 0);
	}
	NSDictionary* dict = (NSDictionary*) input;
	CGPoint resultPoint = CGPointMake(0, 0);
	CGFloat x = [[dict objectForKey:@"x"] floatValue];
	CGFloat y = [[dict objectForKey:@"y"] floatValue];
	resultPoint = CGPointMake(x, y);
	return resultPoint;
}

NSArray* pointsFromRUBEPointArray(NSDictionary* dict)
{
	NSMutableArray *result = [NSMutableArray array];
	NSArray *xArray = [dict objectForKey:@"x"];
	NSArray *yArray = [dict objectForKey:@"y"];
	for (NSUInteger i = 0; i<xArray.count; i++) {
		CGFloat x = [[xArray objectAtIndex:i] floatValue];
		CGFloat y = [[yArray objectAtIndex:i] floatValue];
		CGPoint cPoint = CGPointMake(x, y);
#if __CC_PLATFORM_MAC
		[result addObject:[NSValue valueWithPoint:cPoint]];
#else
		[result addObject:[NSValue valueWithCGPoint:cPoint]];
#endif
	}
	return result;
}