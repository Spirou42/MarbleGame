//
//  CMMarbleEmitter.h
//  MarbleGame
//
//  Created by Carsten Müller on 9/27/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//
// simple emitter for Marbles. This class creates single marbles with a specific frequency

#import <Foundation/Foundation.h>

@class  CMMarbleSimulationLayer;

@interface CMMarbleEmitter : NSObject

@property (nonatomic, assign) CMMarbleSimulationLayer *simulationLayer; ///< the simulation layer the emmiter is attached to

@property (nonatomic, assign) NSInteger marblesToEmit;        ///< number of marbles to be emitted into the playfiled
@property (nonatomic, assign) CGFloat marbleFrequency;        ///< marbles per second

@property (nonatomic, assign) CGPoint position;               ///< position of the emitter
@property (nonatomic, assign) CGPoint positionVariance;				///<, variance of the position

@property (nonatomic, assign) CGFloat velocity;               ///< start velocity of the marbles (positive)
@property (nonatomic, assign) CGFloat velocityVariance;       ///< velocity variance of the marbles

@property (nonatomic, assign) CGFloat angle;                  ///< angle of emittance (degree)
@property (nonatomic, assign) CGFloat angleVariance;          ///< variance of the emittance angle (degree)

@property (nonatomic, assign) CGFloat angularVelocity;        ///< angular Velocity in degrees per second
@property (nonatomic, assign) CGFloat angularVelocityVariance;///< variance in degrees per second


- (void) startEmitter;
- (void) stopEmitter;
@end
