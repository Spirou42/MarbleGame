//
//  CMMarbleSlot.h
//  MarbleGame
//
//  Created by Carsten Müller on 8/9/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//
// simple node to layout removed marbles from the level

#import "CCNode.h"

@interface CMMarbleSlot : CCNode

- (id) initWithSize:(CGSize) size;

- (void) addMarbleWithID:(NSUInteger) marbleID;

@end
