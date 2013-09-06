//
//  CMRubeImage.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/19/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMRubeImage.h"

@implementation CMRubeImage
@synthesize type = type_, name = name_;


-(void) dealloc
{
	self.name = nil;
	[super dealloc];
}
@end
