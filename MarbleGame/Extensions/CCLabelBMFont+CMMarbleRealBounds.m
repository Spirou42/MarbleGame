//
//  CCLabelBMFont+CMMarbleRealBounds.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/6/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CCLabelBMFont+CMMarbleRealBounds.h"

@implementation CCLabelBMFont (CMMarbleRealBounds)
- (CGRect) outerBounds
{
	CGRect realBounds = CGRectZero;
	CGPoint minPoint = cpv(INFINITY, INFINITY);
	CGPoint maxPoint = cpv(0.0, 0.0);
	for (CCNode *aCharNode in self.children) {
    CGRect boundinBox = aCharNode.boundingBox;
		CGPoint s = boundinBox.origin;
		CGPoint p = boundinBox.origin;
		p.x += boundinBox.size.width;
		p.y += boundinBox.size.height;
		
		if (s.x < minPoint.x) {minPoint.x = s.x;}
		if (s.y < minPoint.y) {minPoint.y = s.y;}
		if (p.x > maxPoint.x) {maxPoint.x = p.x;}
		if (p.y > maxPoint.y) {maxPoint.y = p.y;}
		realBounds = CGRectMake(minPoint.x, minPoint.y, maxPoint.x-minPoint.x, maxPoint.y - minPoint.y);
		if (realBounds.size.height < self->_configuration->_commonHeight) {
			realBounds.size.height = self->_configuration->_commonHeight;
		}
	}
	return realBounds;
}
@end
