//
//  CMMarbleCollisionCollector.m
//  Chipmonkey
//
//  Created by Carsten Müller on 6/23/12.
//  Copyright (c) 2012 Carsten Müller. All rights reserved.
//

#import "CMMarbleCollisionCollector.h"

NSString *formerCollisionsKey = @"formerCollisions";
NSString *currentCollisionKey = @"currenrCollision";

@implementation CMMarbleCollisionCollector

@synthesize collisionData, collisionDelay;

- (void) initDefaults
{
	self.collisionData = [NSMutableDictionary dictionary];
	self.collisionDelay = 0.5;
}

- (id) init
{
	if((self = [super init])){
		[self initDefaults];
	}
	return self;
}

- (void) dealloc
{
	self.collisionData = nil;
	[super dealloc];
}

#pragma mark - Collisions

- (NSMutableDictionary*) createDictForObject:(id<NSCopying>) colObject
{
	NSMutableDictionary * result = [NSMutableDictionary dictionary];
	[result setObject:[NSMutableDictionary dictionary] forKey:formerCollisionsKey];
	[result setObject:[NSMutableArray array] forKey:currentCollisionKey];
	[self.collisionData setObject:result forKey:colObject];
	return result;
}

- (NSMutableArray*) currentCollisionsFor:(id<NSCopying>) colObject
{
	NSMutableDictionary* dict = [self.collisionData objectForKey:colObject];
	if (!dict) {
		dict = [self createDictForObject:colObject];
	}
	return [dict objectForKey:currentCollisionKey];
}

- (NSMutableDictionary*) formerCollisionsFor:(id<NSCopying>) colObject
{
	NSMutableDictionary *dict = [self.collisionData objectForKey:colObject];
	if(!dict){
		dict = [self createDictForObject:colObject];
	}
	return [dict objectForKey:formerCollisionsKey];
}

- (NSUInteger) countCollisionsFor:(id<NSCopying>)obj
{
	return [[self currentCollisionsFor:obj]count] + [[self formerCollisionsFor:obj]count];
}

- (void) object:(id<NSCopying>)first touching:(id<NSCopying>)second
{
	NSMutableArray * firstCollisions = [self currentCollisionsFor:first];
	NSMutableArray *secondCollisions = [self currentCollisionsFor:second];
	
	if (![firstCollisions containsObject:second]){
		[firstCollisions addObject:second];
	}
	
	if(![secondCollisions containsObject:first]){
		[secondCollisions addObject:first];	
	}
	// check former collisions
	NSMutableDictionary *firstFormer = [self formerCollisionsFor:first];
	NSMutableDictionary *secondFormer = [self formerCollisionsFor:second];
	
	[firstFormer removeObjectForKey:second];
	[secondFormer removeObjectForKey:first];
	
}

- (void) object:(id<NSCopying>)first releasing:(id<NSCopying>)second
{
	NSMutableArray *firstCollisions = [self currentCollisionsFor:first];
	NSMutableArray *secondCollisions = [self currentCollisionsFor:second];
	
	[firstCollisions removeObject:second];
	[secondCollisions removeObject:first];
	
	NSMutableDictionary * firstFormer = [self formerCollisionsFor:first];
	NSMutableDictionary * secondFormer = [self formerCollisionsFor:second];
	NSNumber *t = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];

	[firstFormer setObject:t forKey:second];
	[secondFormer setObject:t forKey:first];
}

- (void) cleanupFormerCollisions
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	for (id<NSCopying> obj in [self.collisionData allKeys]) {
    NSMutableDictionary * p = [self formerCollisionsFor:obj];
		for (id<NSCopying>  l in [[[p allKeys]copy]autorelease]) {
			NSTimeInterval t = [[p objectForKey:l]doubleValue];
			if ((now-t)>self.collisionDelay) {
				[p removeObjectForKey:l];
			}
		}
	}
}

- (NSMutableSet*) collectCollision:(NSMutableSet*) currentCollisions forObject:(id<NSCopying>) obj processed:(NSMutableSet*) proccessed
{
	if (!proccessed) {
		proccessed = [NSMutableSet set];
	}
	
	NSMutableSet *result = [currentCollisions mutableCopy];//[NSMutableSet setWithSet:currentCollisions];
	[result addObject:obj];
  [proccessed addObject:obj];
	for (id<NSCopying>  k in currentCollisions) {
    if (![proccessed containsObject:k]) {
			NSMutableSet *currentK = [NSMutableSet setWithArray:[self currentCollisionsFor:k]];
			[currentK addObjectsFromArray: [[self formerCollisionsFor:k]allKeys]];

			[result unionSet:[self collectCollision:currentK forObject:k processed:proccessed]];

		}
	}
	return [result autorelease];
}

- (NSArray*) collisionSetsWithMinMembers:(NSUInteger)minMembers
{
	NSMutableArray * result = [NSMutableArray array];
	NSMutableSet *processed = [NSMutableSet set];
	for (id<NSCopying> k in [self.collisionData allKeys]) {
		if (![processed containsObject:k]) {
			NSMutableSet *resultSet = nil;
			NSMutableSet *currentK = [NSMutableSet setWithArray:[self currentCollisionsFor:k]];
			[currentK addObjectsFromArray:[[self formerCollisionsFor:k]allKeys]];
			resultSet = [self collectCollision:currentK forObject:k processed:processed];			
			
			NSInteger total = [resultSet count];
			if (total >= minMembers) {
				[result addObject:resultSet];

			}

		}
	}
	return result;
}


- (void) removeObject:(id<NSCopying>)obj
{
	[self.collisionData removeObjectForKey:obj];
	for (id<NSCopying> p in [self.collisionData allKeys]) {
    NSMutableArray *current = [self currentCollisionsFor:p];
		NSMutableDictionary *former = [self formerCollisionsFor:p];
		[current removeObject:obj];
		[former removeObjectForKey:obj];
	}
}

- (void) reset
{
	self.collisionData = [NSMutableDictionary dictionary];
}

- (NSArray*) activeObjects
{
	NSMutableArray *result = [NSMutableArray array];
	for (id<NSCopying> obj in [self.collisionData allKeys]) {
		if ([self countCollisionsFor:obj]) {
			[result addObject:obj];
		}
	}
	return result;
}

- (NSTimeInterval) oldestCollisionTime:(NSSet *)collisionSet
{
	NSTimeInterval k = 0.0;
	for (id<NSCopying> obj in collisionSet) {
    NSArray *colTimes = [[self formerCollisionsFor:obj] allValues];
		for (NSNumber *n in colTimes) {
			if (k<[n doubleValue]) {
				k=[n doubleValue];
			}
		}	
	}
	return k;
}

@end
