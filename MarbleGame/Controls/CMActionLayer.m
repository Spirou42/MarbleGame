//
//  CMActionLayer.m
//  MarbleGame
//
//  Created by Carsten Müller on 10/12/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMActionLayer.h"

@implementation CMActionLayer

- (id) init{
	self = [super init];
	if (self) {
		self.touchEnabled = YES;
		self.touchPriority=1;
#if __CC_PLATFORM_MAC
		self.mouseEnabled = YES;
		self.mousePriority = 1;
#endif
	}
	return self;
}
- (void)onEnter
{
//#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
//	CCTouchDispatcher * dispatcher  = [CCDirector sharedDirector].touchDispatcher;
//	[dispatcher addTargetedDelegate:self priority:_defaultTouchPriority swallowsTouches:YES];
//#endif
	[super onEnter];
}

- (void)onExit
{
//#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
//	CCTouchDispatcher * dispatcher  = [CCDirector sharedDirector].touchDispatcher;
//	[dispatcher removeDelegate:self];
//#endif
	
	[super onExit];
}

#pragma mark CCTargetedTouch Delegate Methods

#if __CC_PLATFORM_IOS

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (![self isTouchInside:touch]
			|| ![self isEnabled]
			|| ![self visible]
			|| ![self hasVisibleParents])
	{
		return NO;
	}
	
	_state              = CCControlStateHighlighted;
//	_pushed             = YES;
	self.highlighted    = YES;
	
	[self sendActionsForControlEvents:CCControlEventTouchDown];
	
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (![self isEnabled]
			/*|| ![self isPushed]*/
			|| [self isSelected])
	{
		if ([self isHighlighted])
		{
			[self setHighlighted:NO];
		}
		return;
	}
	
	BOOL isTouchMoveInside = [self isTouchInside:touch];
	if (isTouchMoveInside && ![self isHighlighted])
	{
		_state = CCControlStateHighlighted;
		
		[self setHighlighted:YES];
		
		[self sendActionsForControlEvents:CCControlEventTouchDragEnter];
	} else if (isTouchMoveInside && [self isHighlighted])
	{
		[self sendActionsForControlEvents:CCControlEventTouchDragInside];
	} else if (!isTouchMoveInside && [self isHighlighted])
	{
		_state = CCControlStateNormal;
		
		[self setHighlighted:NO];
		
		[self sendActionsForControlEvents:CCControlEventTouchDragExit];
	} else if (!isTouchMoveInside && ![self isHighlighted])
	{
		[self sendActionsForControlEvents:CCControlEventTouchDragOutside];
	}
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	_state              = CCControlStateNormal;
//	_pushed             = NO;
	self.highlighted    = NO;
	
	if ([self isTouchInside:touch])
	{
		[self sendActionsForControlEvents:CCControlEventTouchUpInside];
	} else
	{
		[self sendActionsForControlEvents:CCControlEventTouchUpOutside];
	}
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	_state              = CCControlStateNormal;
//	_pushed             = NO;
	self.highlighted    = NO;
	
	[self sendActionsForControlEvents:CCControlEventTouchCancel];
}

#else

- (BOOL)ccMouseDown:(NSEvent *)event
{
	if (![self isMouseInside:event]
			|| ![self visible]
			|| ![self hasVisibleParents])
	{
		return NO;
	}
	
	_state              = CCControlStateHighlighted;
//	_pushed             = YES;
	self.highlighted    = YES;
	
	[self sendActionsForControlEvents:CCControlEventTouchDown];
	
	return YES;
}


- (BOOL)ccMouseDragged:(NSEvent *)event
{
	if (![self isEnabled]
			/*|| ![self isPushed]*/
			|| [self isSelected])
	{
		if ([self isHighlighted])
		{
			[self setHighlighted:NO];
		}
		return NO;
	}
	
	BOOL isMouseMoveInside = [self isMouseInside:event];
	if (isMouseMoveInside && ![self isHighlighted])
	{
		_state = CCControlStateHighlighted;
		
		[self setHighlighted:YES];
		
		[self sendActionsForControlEvents:CCControlEventTouchDragEnter];
	} else if (isMouseMoveInside && [self isHighlighted])
	{
		[self sendActionsForControlEvents:CCControlEventTouchDragInside];
	} else if (!isMouseMoveInside && [self isHighlighted])
	{
		_state = CCControlStateNormal;
		
		[self setHighlighted:NO];
		
		[self sendActionsForControlEvents:CCControlEventTouchDragExit];
	} else if (!isMouseMoveInside && ![self isHighlighted])
	{
		[self sendActionsForControlEvents:CCControlEventTouchDragOutside];
	}
	
	return YES;
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
	if (![self visible] || ![self hasVisibleParents])
	{
		return NO;
	}
	_state              = CCControlStateNormal;
//	_pushed             = NO;
	self.highlighted    = NO;
	
	if ([self isMouseInside:event])
	{
		[self sendActionsForControlEvents:CCControlEventTouchUpInside];
		return YES;
	} else
	{
		[self sendActionsForControlEvents:CCControlEventTouchUpOutside];
	}
	
	return NO;
}
#endif

@end
