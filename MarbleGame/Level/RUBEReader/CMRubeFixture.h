//
//  CMRubeFixture.h
//  MarbleGame
//
//  Created by Carsten Müller on 8/19/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  kFixtureCircle,
  kFixturePolygon,
  kFixtureChain
}CMRubeFixtureType;


@protocol ChipmunkObject;


@interface CMRubeFixture : NSObject <ChipmunkObject>


@property (nonatomic, retain) NSString* name;
@property (nonatomic, assign) CGFloat friction;
@property (nonatomic, assign) CGFloat restitution;
@property (nonatomic, assign) NSInteger filterBits, filterMask,filterGroup;
@property (nonatomic, assign, getter = isSensor) BOOL sensor;
@property (nonatomic, assign) CGFloat density;
@property (nonatomic, assign) CMRubeFixtureType type;
@property (nonatomic, assign) CGPoint circleCenter;
@property (nonatomic, assign) CGFloat circleRadius;
@property (nonatomic, retain) NSArray *vertices;



- (id) initWithDictionary:(NSDictionary*) dict;
- (CGFloat) momentForMass:(CGFloat) mass;

- (NSArray*) chipmunkObjects;
@end
