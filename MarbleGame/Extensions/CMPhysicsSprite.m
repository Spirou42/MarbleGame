//
//  CMPhysicsSprite.m
//  MarbleGame
//
//  Created by Carsten Müller on 9/14/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMPhysicsSprite.h"
@interface CMPhysicsSprite ()
@property (nonatomic,retain) NSMutableArray *assignedShapes;
@end


@implementation CMPhysicsSprite
@synthesize assignedShapes = assignedShapes_, overlayNode = overlayNode_;
@synthesize soundName = soundName_;
@dynamic shapes;

- (void) initializeDefaults
{
	self.assignedShapes = [NSMutableArray array];
}

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(BOOL)rotated
{
	self = [super initWithTexture:texture rect:rect rotated:rotated];
	if (self) {
		self.assignedShapes = [NSMutableArray array];
	}
	return self;
}


- (void) dealloc
{
	self.assignedShapes = nil;
	[super dealloc];
}

#pragma mark - Methods

- (void) addShape:(ChipmunkShape *)someShape
{
	[self.assignedShapes addObject:someShape];
}

- (void) addShapes:(id<NSFastEnumeration>)shapes
{
	for (id a in shapes) {
    [self.assignedShapes addObject:a];
	}
}

- (NSArray*) shapes
{
	return self.assignedShapes;
}

#pragma mark - ChipmunkObject

- (id <NSFastEnumeration>) chipmunkObjects
{
	NSMutableArray* result = [NSMutableArray array];
	if (self.chipmunkBody.isStatic) {
		[result addObjectsFromArray:self.shapes];
	}else{
		[result addObject:self.chipmunkBody];
		[result addObjectsFromArray:self.shapes];
	}
	return result;
}

- (void) updateTransform
{
	[super updateTransform];
//	self.overlayNode.position = self.position;
}

- (void) draw
{
//	self.overlayNode.position = self.position;
	[super draw];
}

#pragma mark -
#pragma mark NSCopying

- (id) copyWithZone:(NSZone *)zone
{
	return [self retain];
	//	id result = [[[self class]alloc]initWithSpriteFrameName:self.frameName mass:self.chipmunkBody.mass andRadius:self.radius];
	//	return result;
}

@end
