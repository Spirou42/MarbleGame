//
//  HelloWorldLayer.h
//  CocosTest1
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
@class  CMMarbleCollisionCollector;
@interface CMMarbleSimulationLayer : CCLayerColor
{
	id <CMMarbleGameDelegate> _gameDelegate;
	CCTexture2D *_spriteTexture; // weak ref
	CCPhysicsDebugNode *_debugLayer; // weak ref
	
	ChipmunkSpace   *_space;
	CCNode          *_batchNode;
	NSString        *_currentMarbleSet;
	CCLayer         *_marbleSelectMenu;
	CCLayer         *_debugMenu;
 	CMMarbleCollisionCollector *_collisionCollector;
  BOOL 						_simulationRunning;
	NSMutableArray	*_simulatedMarbles;
	
	ChipmunkGrooveJoint *_dollyGroove;
	ChipmunkPinJoint		*_dollyServo;

	ChipmunkShape				*_dollyShape;
	ChipmunkBody				*_dollyBody;
	CGPoint							_lastMousePosition;
}
@property (nonatomic, assign) id<CMMarbleGameDelegate> gameDelegate;
@property (nonatomic, retain) ChipmunkSpace *space;
@property (nonatomic, assign) CCNode* batchNode;
@property (nonatomic, retain) NSString* currentMarbleSet;
@property (nonatomic, readonly) CCPhysicsDebugNode *debugLayer;
@property (nonatomic, assign,getter = isSimulationRunning) BOOL simulationRunning;
@property (nonatomic, retain) CMMarbleCollisionCollector *collisionCollector;
@property (nonatomic, retain) NSMutableArray* simulatedMarbles;

@property (nonatomic, retain) ChipmunkGrooveJoint *dollyGroove;
@property (nonatomic, retain) ChipmunkShape *dollyShape;
@property (nonatomic, retain) ChipmunkPinJoint* dollyServo;
@property (nonatomic, retain) ChipmunkBody *dollyBody;

// returns a CCScene that contains the HelloWorldLayer as the only child


+(CCScene *) scene;

- (void) prepareMarble;
-(void) startSimulation;
-(void) stopSimulation;
-(void) resetSimulation;

-(void) retextureMarbles;
- (void) removeCollisionSets:(NSArray*) layers;
@end
