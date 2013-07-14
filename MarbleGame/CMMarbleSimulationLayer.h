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



#define BORDER_FRICTION   1.0f
#define BORDER_ELASTICITY 0.1f
#define SPACE_GRAVITY     981.0f
#define MARBLE_MASS       20.0f
#define MARBLE_RADIUS 		15

@interface CMMarbleSimulationLayer : CCLayerColor
{
	CCTexture2D *_spriteTexture; // weak ref
	CCPhysicsDebugNode *_debugLayer; // weak ref
	
	ChipmunkSpace   *_space;
	CCNode          *_batchNode;
	NSString        *_currentMarbleSet;
	CCLayer         *_marbleSelectMenu;
	CCLayer         *_debugMenu;
  
  BOOL _simulationRunning;

}
@property (nonatomic,retain) ChipmunkSpace *space;
@property (nonatomic,assign) CCNode* batchNode;
@property (nonatomic,retain) NSString* currentMarbleSet;
@property (nonatomic,readonly) CCPhysicsDebugNode *debugLayer;
@property (nonatomic,assign,getter = isSimulationRunning) BOOL simulationRunning;
// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;


-(void) startSimulation;
-(void) stopSimulation;
-(void) resetSimulation;

-(void) retextureMarbles;
@end
