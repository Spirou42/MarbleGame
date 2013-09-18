//
//  CMMarbleSlot.h
//  MarbleGame
//
//  Created by Carsten Müller on 8/9/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//
// simple node to layout removed marbles from the level

#import "CCNode.h"

@protocol CMMarbleGameDelegate;

@interface CMMarbleSlot : CCNode

@property (nonatomic, assign) id<CMMarbleGameDelegate> gameDelegate;

- (id) initWithSize:(CGSize) size;
- (id) initWithSize:(CGSize)size andDelegate:(id<CMMarbleGameDelegate>)delegate;
- (void) addMarbleWithID:(NSUInteger) marbleID;
- (void) clearMarbles;
@end
