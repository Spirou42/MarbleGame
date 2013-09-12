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

#if __CC_PLATFORM_MAC
-(BOOL) ccMouseDown:(NSEvent *)event
{
	if (self.visible) {
		return YES;
	}
	return NO;
}

- (BOOL) ccMouseMoved:(NSEvent *)event
{
	if (self.visible) {
		return YES;
	}
	return NO;
}
#else
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (self.visible) {
		return YES;
	}
	return NO;
}

#endif

@end
