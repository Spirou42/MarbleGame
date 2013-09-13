//
//  CMEventEatingLayer.m
//  MarbleGame
//
//  Created by Carsten Müller on 9/12/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMEventEatingLayer.h"

@implementation CMEventEatingLayer
#pragma mark -
#pragma mark Event handling
- (BOOL)isPointInside:(CGPoint)location
{
	return CGRectContainsPoint([self boundingBox], location);
}

#if __CC_PLATFORM_MAC

- (BOOL)isMouseInside:(NSEvent *)event
{
	CGPoint eventLocation   = [[CCDirector sharedDirector] convertEventToGL:event];
	eventLocation           = [[self parent] convertToNodeSpace:eventLocation];
	
	return [self isPointInside:eventLocation];
}

-(BOOL) ccMouseDown:(NSEvent *)event
{
	if (self.visible && [self isMouseInside:event]) {
		return YES;
	}
	return NO;
}

- (BOOL) ccMouseMoved:(NSEvent *)event
{
	if (self.visible && [self isMouseInside:event]) {
		return YES;
	}
	return NO;
}
#else
- (BOOL)isTouchInside:(UITouch *)touch
{
	CGPoint touchLocation   = [touch locationInView:[touch view]];                      // Get the touch position
	touchLocation           = [[CCDirector sharedDirector] convertToGL:touchLocation];  // Convert the position to GL space
	touchLocation           = [[self parent] convertToNodeSpace:touchLocation];         // Convert to the node space of this class
	
	return [self isPointInside:touchLocation];
}
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (self.visible && [self isTouchInside:event]) {
		return YES;
	}
	return NO;
}

#endif

@end
