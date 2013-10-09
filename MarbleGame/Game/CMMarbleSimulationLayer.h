//
//  CMMarbleSimulationLayer.h
//  MarbleGame
//
//  Created by Carsten Müller on 6/28/13.
//  Copyright Carsten Müller 2013. All rights reserved.
//

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"



// Importing Chipmunk headers
#import "ObjectiveChipmunk.h"
#import "CMMarbleGameDelegate.h"


#define USE_NEW_COLLISION_DETECTOR 1
@class  CMMarbleCollisionCollector, CMMarbleLevel, CMMarbleSprite;
@interface CMMarbleSimulationLayer : CCLayerColor

@property (nonatomic, assign) id<CMMarbleGameDelegate> gameDelegate;

// Physics
@property (nonatomic, retain) ChipmunkSpace *space;								/// physics world
@property (nonatomic, readonly) CCPhysicsDebugNode *debugLayer;		/// debug helper

// Sprites
@property (nonatomic, assign) CCNode* marbleBatchNode;						///< node holding all moving Marbles
@property (nonatomic, assign) CCNode* otherSpritesNode;						///< node for all other Sprites no matter if they are dynamic or static

@property (nonatomic, retain) NSString* currentMarbleSet;					///< current marble theme

// Simulation
@property (nonatomic, assign,getter = isSimulationRunning) BOOL simulationRunning;
@property (nonatomic, retain) CMMarbleCollisionCollector *collisionCollector;
@property (nonatomic, retain) NSMutableArray* simulatedMarbles;


// Level
@property (nonatomic, assign) CMMarbleLevel *currentLevel;				///< the current Level
@property (nonatomic, retain) NSArray* bounds;										///< dynamically created shapes outside of the current level to prevent marbles from falling through.
@property (nonatomic, retain) NSArray* worldShapes;							///< all static shapes from the current level.


/// Marble throwing
@property (nonatomic, retain) ChipmunkGrooveJoint *dollyGroove;
@property (nonatomic, retain) ChipmunkShape *dollyShape;
@property (nonatomic, retain) ChipmunkPivotJoint* dollyServo;
@property (nonatomic, retain) ChipmunkBody *dollyBody;


@property (nonatomic, assign) NSUInteger currentMarbleIndex;

@property (nonatomic, assign) NSTimeInterval lastMarbleSoundTime;


// returns a CCScene that contains the HelloWorldLayer as the only child


+(CCScene *) scene;

- (void) prepareMarble;
-(void) startSimulation;
-(void) stopSimulation;
-(void) resetSimulation;

-(void) retextureMarbles;
- (void) removeCollisionSets:(NSArray*) layers;
- (void) removedMarbles:(NSSet*) removedOnes;
- (void) cleanupMarbles;
- (void) marbleFired:(CMMarbleSprite*)marble;
@end
