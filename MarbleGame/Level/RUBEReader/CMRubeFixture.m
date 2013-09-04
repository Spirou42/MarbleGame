//
//  CMRubeFixture.m
//  MarbleGame
//
//  Created by Carsten Müller on 8/19/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CMRubeFixture.h"
#import "CMMarbleRubeReader.h"

@implementation CMRubeFixture
@synthesize name = name_, friction = friction_, restitution = restitution_,
filterBits = filterBits_, filterMask = filterMask_, filterGroup = filterGroup_, type = type_,
circleCenter = circleCenter_, circleRadius = circleRadius_, vertices = vertices_;


- (void) initDefaults
{
  self.friction = 1.0;
  self.restitution = 1.0;
  self.filterBits = 1;
  self.filterMask = 0xffff;
  self.filterGroup = 0;
  self.sensor = NO;
  self.density = 1.0;
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
  [super dealloc];
}
@end
