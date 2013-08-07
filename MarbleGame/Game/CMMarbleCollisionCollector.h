//
//  CMMarbleCollisionCollector.h
//  Chipmonkey
//
//  Created by Carsten Müller on 6/23/12.
//  Copyright (c) 2012 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMMarbleCollisionCollector : NSObject
{
	@protected
	NSMutableDictionary 	*collisionData;
	NSTimeInterval				collisionDelay;
}
@property (retain, nonatomic) NSMutableDictionary* collisionData;
@property (assign, nonatomic) NSTimeInterval collisionDelay;
- (void) object:(id<NSCopying>)first touching:(id<NSCopying>) second;
- (void) object:(id<NSCopying>)first releasing:(id<NSCopying>)second;


- (void) cleanupFormerCollisions;
- (void) removeObject:(id<NSCopying>)obj;
/// returns an NSArray of NSSets, one for each collision
- (NSArray*) collisionSetsWithMinMembers:(NSUInteger) minCollisions;
- (void) reset;
- (NSArray*) activeObjects;
- (NSTimeInterval) oldestCollisionTime:(NSSet*) collisionSet;
@end
