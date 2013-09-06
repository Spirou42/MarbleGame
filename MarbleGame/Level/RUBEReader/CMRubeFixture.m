//
//  CMRubeFixture.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/19/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMRubeFixture.h"
#import "CMMarbleRubeReader.h"
#import "ObjectiveChipmunk.h"
//#import "ChipmunkObject.h"

@interface CMRubeFixture ()
@property NSMutableArray *cachedChipmunkObjects;
@property (nonatomic, assign) cpVect *vBuffer;
@end

@implementation CMRubeFixture
@synthesize name = name_, friction = friction_, restitution = restitution_,
filterBits = filterBits_, filterMask = filterMask_, filterGroup = filterGroup_, type = type_,
circleCenter = circleCenter_, circleRadius = circleRadius_, vertices = vertices_;

@synthesize cachedChipmunkObjects = cachedChipmunkObjects_, vBuffer = vBuffer_;

- (void) initDefaults
{
  self.friction = 1.0;
  self.restitution = 1.0;
  self.filterBits = 1;
  self.filterMask = 0xffff;
  self.filterGroup = 0;
  self.sensor = NO;
  self.density = 1.0;
  self.vBuffer = NULL;
  self.cachedChipmunkObjects = nil;
}

- (void) initializeCircle:(NSDictionary*) dict
{
  self.type = kFixtureCircle;
  self.circleCenter = pointFromRUBEPoint([dict objectForKey:@"center"]);
  self.circleRadius = [[dict objectForKey:@"radius"]floatValue];
  self.vertices = nil;
}

- (void) initializePolygon:(NSDictionary*) dict
{
  self.type = kFixturePolygon;
  self.vertices = pointsFromRUBEPointArray([dict objectForKey:@"vertices"]);
  self.circleRadius = 0.0;
  self.circleCenter = CGPointZero;
  self.vBuffer = [self createVBufferFor:self.vertices];
}

- (void) initializeChain:(NSDictionary*) dict
{
  self.type = kFixtureChain;
  self.vertices = pointsFromRUBEPointArray([dict objectForKey:@"vertices"]);
  self.circleCenter = CGPointZero;
  self.circleRadius = 0.0;
}

- (id) initWithDictionary:(NSDictionary*) dict
{
  NSArray *allKeys = [dict allKeys];
  self = [super init];
  if(self){
    [self initDefaults];
    self.name = [dict objectForKey:@"name"];
    self.friction = [[dict objectForKey:@"friction"]floatValue];
    self.restitution = [[dict objectForKey:@"restitution"]floatValue];

    if ([allKeys containsObject:@"filter-categoryBits"]) {
      self.filterBits = [[dict objectForKey:@"filter-categoryBits"] integerValue];
    }

    if ([allKeys containsObject:@"filter-maskBits"]) {
      self.filterMask = [[dict objectForKey:@"filter-maskBits"] integerValue];
    }
    if ([allKeys containsObject:@"filter-groupIndex"]) {
      self.filterGroup = [[dict objectForKey:@"filter-groupIndex"] integerValue];
    }
    
    if ([allKeys containsObject:@"circle"]) {
      [self initializeCircle:[dict objectForKey:@"circle"]];
    } else if ([allKeys containsObject:@"polygon"]){
      [self initializePolygon:[dict objectForKey:@"polygon"]];
    } else if ([allKeys containsObject:@"chain"]){
      [self initializeChain:[dict objectForKey:@"chain"]];
    }
  }
  return self;
}


- (void) dealloc
{
  self.name = nil;
  self.vertices = nil;
  self.cachedChipmunkObjects = nil;
  self.vBuffer = NULL;
  [super dealloc];
}
#pragma mark - Properties

- (cpVect*) vBuffer
{
  return self->vBuffer_;
}

- (void) setVBuffer:(CGPoint *)vBuffer
{

  if (self->vBuffer_ != vBuffer) {
    if (self->vBuffer_) { // clear vBuffer
      free(self->vBuffer_);
    }

    self->vBuffer_ = vBuffer;
  }
}

#pragma mark - Helper

- (cpVect*) createVBufferFor:(NSArray*) vertices
{
  size_t bufferSize = vertices.count * sizeof(cpVect);
  cpVect* buffer = (cpVect*) malloc(bufferSize);
  NSInteger end = vertices.count -1;
  for (NSUInteger i=0; i<vertices.count; i++) {
#if __CC_PLATFORM_MAC
    buffer[i] =  [[vertices objectAtIndex:end-i]pointValue];
#else
    buffer[i] =  [[vertices objectAtIndex:end-i]CGPointValue];
#endif
  }
  return buffer;
}

- (CGFloat) momentForMass:(CGFloat)mass
{
  CGFloat result = 0.0f;
  switch (self.type) {
    case kFixtureCircle:
    {
      result = cpMomentForCircle(mass, 0.0f, self.circleRadius, self.circleCenter);
    }
      break;
    case kFixturePolygon:
    {
      result = cpMomentForPoly(mass, (int)self.vertices.count, self.vBuffer, cpv(0, 0));
    }
      break;
    case kFixtureChain:
    {
      for ( NSUInteger i=1; i<self.vertices.count; i++) {
#if __CC_PLATFORM_MAC
        cpVect a = [[self.vertices objectAtIndex:i-1] pointValue];
        cpVect b = [[self.vertices objectAtIndex:i]pointValue];
#else
        cpVect a = [[self.vertices objectAtIndex:i-1] CGPointValue];
        cpVect b = [[self.vertices objectAtIndex:i]CGPointValue];

#endif
        result += cpMomentForSegment(mass, a, b);
      }
    }
      break;
    default:
      break;
  }
  return result;
}

#pragma mark - ChipmunkObject

- (NSMutableArray*) createChipmunkObjects
{
  NSMutableArray* result = [NSMutableArray array];
  switch (self.type) {
    case kFixtureCircle:
    {
      ChipmunkCircleShape* circleShape =[ChipmunkCircleShape circleWithBody:nil radius:self.circleRadius offset:self.circleCenter];
      [result addObject:circleShape];
    }
      break;
    case kFixturePolygon:
    {
      ChipmunkPolyShape* polyShape = [ChipmunkPolyShape polyWithBody:nil count:(int)self.vertices.count verts:self.vBuffer offset:CGPointZero];
      [result addObject:polyShape];
    }
      break;
    case kFixtureChain:
    {
      for (NSUInteger i=0; i<(self.vertices.count-1); i++) {
#if __CC_PLATFORM_MAC
        CGPoint a = [[self.vertices objectAtIndex:i] pointValue];
        CGPoint b = [[self.vertices objectAtIndex:i+1] pointValue];
#else
        CGPoint a = [[self.vertices objectAtIndex:i] CGPointValue];
        CGPoint b = [[self.vertices objectAtIndex:i+1] CGPointValue];
#endif
        ChipmunkSegmentShape *shape = [ChipmunkSegmentShape segmentWithBody:nil from:a to:b radius:1.0];
        [self.cachedChipmunkObjects addObject:shape];
      }
    }
      break;
    default:
      break;
  }
  for (ChipmunkShape* shape in result) {
    shape.friction = self.friction;
    shape.elasticity = self.restitution;
  }
  return result;
}

- (NSArray*) chipmunkObjects
{
  if (!self->cachedChipmunkObjects_) {
    self.cachedChipmunkObjects = [self createChipmunkObjects];
  }
  return self.cachedChipmunkObjects;
}

@end
