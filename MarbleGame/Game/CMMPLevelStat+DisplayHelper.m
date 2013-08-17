//
//  CMMPLevelStat+DisplayHelpere.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/17/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMMPLevelStat+DisplayHelper.h"

@implementation CMMPLevelStat (DisplayHelper)
- (NSString*) statusString
{
	NSString *result = nil;
	switch (self.status) {
		case -1:
			result = @"Unfinished";	break;
		case 0:
			result = @"Failed"; break;
		case 1:
			result = @"Amateur"; break;
		case 2:
			result = @"Professional"; break;
		case 3:
			result = @"Master"; break;

		default:
			break;
	}
	return result;
}
@end
