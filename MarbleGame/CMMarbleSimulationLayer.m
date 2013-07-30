//
//  HelloWorldLayer.m
//  CocosTest1
//
//  Created by Carsten Müller on 6/28/13.
//  Copyright Carsten Müller 2013. All rights reserved.
//

#import "AppDelegate.h"

// Import the interfaces
#import "CMMarbleSimulationLayer.h"
#import "CMMarbleSprite.h"
#import "CMMarbleMainMenuScene.h"
#import "CMMarbleCollisionCollector.h"
#import "CMMarblePlayScene.h"
#import "SceneHelper.h"
#import "CMMarbleSprite.h"
enum {
	kTagParentNode = 1,
};
@interface CCMenu (MyLayout)
- (void) adjustContentSize;
@end

static NSString *borderType = @"borderType";
#pragma mark - HelloWorldLayer

@interface CMMarbleSimulationLayer ()
-(void) addNewSpriteAtPosition:(CGPoint)pos;
-(void) initPhysics;

@property (nonatomic,assign) CGPoint lastMousePosition;
@end


@implementation CMMarbleSimulationLayer

@synthesize space = _space, batchNode=_bathNode, currentMarbleSet=_currentMarbleSet, debugLayer=_debugLayer,
simulationRunning=_simulationRunning, collisionCollector=_collisionCollector,simulatedMarbles=_simulatedMarbles,
dollyGroove = _dollyGroove, dollyShape = _dollyShape, dollyServo = _dollyServo, dollyBody = _dollyBody,
gameDelegate = _gameDelegate, lastMousePosition = _lastMousePosition;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	CMMarbleSimulationLayer *layer = [CMMarbleSimulationLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
  // WithColor:ccc4(255, 128, 0, 255)
	if( (self=[super init])) {
    
		// enable events
#ifdef __CC_PLATFORM_IOS
		self.touchEnabled = YES;
		self.accelerometerEnabled = NO;
#elif defined(__CC_PLATFORM_MAC)
		self.mouseEnabled = YES;
#endif
		
		self.simulatedMarbles = [NSMutableArray array];
		// init physics
		[self initPhysics];
		

		// Use batch node. Faster currently the batch node is not supported cause i use a custome shader. This will change in the future.

#if 0
		self.batchNode= [CCSpriteBatchNode batchNodeWithFile:@"Balls.png" capacity:100];
#else
    self.batchNode = [CCNode node];
#endif
		[self addChild:self.batchNode z:0 tag:kTagParentNode];
		
//		[self addNewSpriteAtPosition:ccp(200,200)];
//		[self prepareMarble];

		// this starts the update process automatically
    self.simulationRunning = YES;
	}
	
	return self;
}



- (void)dealloc
{
  
	self.space = nil;
  self.collisionCollector = nil;
	self.currentMarbleSet = nil;
	self.simulatedMarbles = nil;
	self.dollyGroove = nil;
	self.dollyShape.body = nil;
	self.dollyShape = nil;
	self.dollyServo = nil;
	
	[super dealloc];
	
}

#pragma mark -
#pragma mark Physics

-(void) initPhysics
{
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	self.space = [[[ChipmunkSpace alloc] init] autorelease];
	
	self.space.gravity = cpv(0.0, -SPACE_GRAVITY);
	CGRect p = CGRectZero;
	p.size = s;
	CGRect newBounds = CGRectInset(p,0,0);
	[self.space addBounds:newBounds
							thickness:20.0
						 elasticity:BORDER_ELASTICITY
							 friction:BORDER_FRICTION
								 layers:CP_ALL_LAYERS
									group:CP_NO_GROUP
					collisionType:borderType];
	
	[self.space addCollisionHandler:self typeA:[CMMarbleSprite class] typeB:[CMMarbleSprite class]
														begin:@selector(beginMarbleCollision:space:)
												 preSolve:nil
												postSolve:@selector(postMarbleCollision:space:)
												 separate:@selector(separateMarbleCollision:space:)];
	
	_debugLayer = [CCPhysicsDebugNode debugNodeForCPSpace:self.space.space];
	_debugLayer.visible = NO;
	[self addChild:_debugLayer z:100];

	self.collisionCollector = [[[CMMarbleCollisionCollector alloc] init]autorelease];
	self.collisionCollector.collisionDelay = 0.2;
	
	
//	self.dollyBody = [ChipmunkBody bodyWithMass:1.0 andMoment:cpMomentForBox(1.0, 20.0, 20.0)];
//	self.dollyBody.pos=cpv(512, 748);
//	self.dollyShape = [[[ChipmunkPolyShape alloc]initBoxWithBody:self.dollyBody width:20.0 height:20.0]autorelease];
//	self.dollyServo = [self.space add:[ChipmunkPivotJoint pivotJointWithBodyA:self.space.staticBody bodyB:self.dollyBody pivot:self.dollyBody.pos]];
//	self.dollyServo.maxForce=1e4;
//	self.dollyServo.maxBias = 1e6;
//	
//	
//	cpVect start = cpv(10, 748);
//	cpVect end = cpv(1004,748);
//	cpVect anchor = cpv(0,0);
//	self.dollyGroove= [ChipmunkGrooveJoint grooveJointWithBodyA:self.space.staticBody bodyB:self.dollyBody groove_a:start groove_b:end anchr2:anchor];
//	[self.space addConstraint:self.dollyGroove];
//	[self.space addShape:self.dollyShape];
//	[self.space addBody:self.dollyBody];
	
}


- (BOOL) beginMarbleCollision:(cpArbiter*) arbiter space:(ChipmunkSpace*) space
{
	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, firstMarble, secondMarble);
	CMMarbleSprite *firstMarbleLayer = firstMarble.data;
	CMMarbleSprite *secondMarbleLayer = secondMarble.data;
	
	
	if (firstMarbleLayer.ballIndex == secondMarbleLayer.ballIndex) {
		[self.collisionCollector object:firstMarbleLayer touching:secondMarbleLayer];
		firstMarbleLayer.touchesNeighbour = YES;
		secondMarbleLayer.touchesNeighbour = YES;
	}
  return YES;
}

- (void) postMarbleCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)sp
{
	
	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, firstMarble, secondMarble);
//	[self processSound:arbiter first:firstMarble second:secondMarble];
}

- (void) separateMarbleCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space
{
	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, firstMarble, secondMarble);
	CMMarbleSprite *firstMarbleLayer = firstMarble.data;
	CMMarbleSprite *secondMarbleLayer = secondMarble.data;
	
	if (firstMarbleLayer.ballIndex == secondMarbleLayer.ballIndex) {
		[self.collisionCollector object:firstMarbleLayer releasing:secondMarbleLayer];
		firstMarbleLayer.touchesNeighbour=NO;
		secondMarbleLayer.touchesNeighbour=NO;
	}
	
}

-(void) update:(ccTime) delta
{
	// Should use a fixed size step based on the animation interval.
	int steps = 2;
	CGFloat dt = [[CCDirector sharedDirector] animationInterval]/(CGFloat)steps;
	
	for(int i=0; i<steps; i++){
		[self.space step:dt];
    //		cpSpaceStep(_space, dt);
	}
	if (self.parent) {
		CMMarblePlayScene * scene = (CMMarblePlayScene*) self.parent;
		[scene simulationStepDone:delta];
	}
	[self.collisionCollector cleanupFormerCollisions];
}

- (void) removeCollisionSets:(NSArray*) layers
{
	NSMutableSet *alreadyRemoved = [NSMutableSet set];
	
	for (NSSet *colSet in layers) {
    for (CMMarbleSprite *layer in colSet) {
			if (![alreadyRemoved containsObject:layer]) {
				[alreadyRemoved addObject:layer];
				
//				[self.space remove:layer];
				
				[self.simulatedMarbles removeObject:layer];
//				[self.batchNode removeChild:layer];
				layer.shouldDestroy = YES;
				[self.collisionCollector removeObject:layer];
			}
		}
	}
	if ([alreadyRemoved count]) {
		NSMutableSet *imageSet = [NSMutableSet set];
		for (CMMarbleSprite *aLayer in self.simulatedMarbles) {
			[imageSet addObject:[NSNumber numberWithInteger:aLayer.ballIndex]];
		}
//		[self.delegate imagesOnField:imageSet];
	}
	
}

#pragma mark -
#pragma mark Properties

- (void) setSimulationRunning:(BOOL)run
{
  if (self->_simulationRunning != run) {
    CCScheduler *s =self.scheduler;
    self->_simulationRunning = run;
    if (run) {
      [self scheduleUpdate];
    }else{
      [s unscheduleUpdateForTarget:self];
    }
  }
}

- (void) setDollyGroove:(ChipmunkGrooveJoint *)dG
{
	if (dG != self.dollyGroove) {
		if (self.dollyGroove) {
			[self.space removeConstraint:self.dollyGroove];
		}
		if (dG) {
			[self.space addConstraint:dG];
		}
		[self.dollyGroove release];
		self->_dollyGroove = [dG retain];
	}
}

- (void) setDollyServo:(ChipmunkPinJoint *)dS
{
	if (dS != self.dollyServo) {
		if (self.dollyServo) {
			[self.space removeConstraint:self.dollyServo];
		}
		if (dS) {
			[self.space addConstraint:dS];
		}
		[self.dollyServo release];
		self->_dollyServo = [dS retain];
	}
}



#pragma mark -
#pragma mark actions

- (void) prepareMarble
{
	NSUInteger marbleIndex = [self.gameDelegate marbleIndex];
  NSString *marbleSet = [self.gameDelegate marbleSetName];
	CMMarbleSprite *ms = [[[CMMarbleSprite alloc]initWithBallSet:marbleSet ballIndex:marbleIndex mass:MARBLE_MASS andRadius:MARBLE_RADIUS]autorelease];
	[self.batchNode addChild:ms];
	[ms createOverlayTextureRect];
	[self.space add:ms];

	ChipmunkBody *dB = ms.shape.body;
  self.dollyBody = dB;
	dB.pos = cpv(self.lastMousePosition.x, MARBLE_GROOVE_Y);
	// create the Groove
	cpVect start = cpv(0, MARBLE_GROOVE_Y);
	cpVect end = cpv(1024,MARBLE_GROOVE_Y);
	cpVect anchor = cpv(0,0);

	self.dollyGroove= [ChipmunkGrooveJoint grooveJointWithBodyA:self.space.staticBody bodyB:dB groove_a:start groove_b:end anchr2:anchor];
//  self.dollyGroove.errorBias = pow(1.0-0.1, 60);

	// create the Servo
//	self.dollyServo = [ChipmunkPivotJoint pivotJointWithBodyA:self.space.staticBody bodyB:dollyBody pivot:dollyBody.pos];
	self.dollyServo = [ChipmunkPinJoint pinJointWithBodyA:self.space.staticBody bodyB:dB anchr1:dB.pos anchr2:cpv(0.0, 0.0)];
//  dB.pos = cpv(self.lastMousePosition.x, MARBLE_GROOVE_Y);
	
//	self.dollyServo.maxForce=1e6;
//	self.dollyServo.maxBias = INFINITY;
  self.dollyServo.errorBias = pow(1.0-0.1, 400);
	self.dollyServo.dist = 0.001;
//	self.dollyServo.anchr1 = self.lastMousePosition;
	
}


-(void) addNewSpriteAtPosition:(CGPoint)pos
{
	// physics body
  static int marbleIndex = 1;
  NSString *marbleSet =[[NSUserDefaults standardUserDefaults]stringForKey:@"MarbleSet"];
	NSLog(@"MarbleSet: %@",marbleSet);
  
	CMMarbleSprite *ms = [[[CMMarbleSprite alloc]initWithBallSet:marbleSet ballIndex:marbleIndex mass:MARBLE_MASS andRadius:MARBLE_RADIUS]autorelease];
//	marbleIndex= ((marbleIndex+1)%9);
  if (!marbleIndex) {
    marbleIndex=1;
  }
	[self.space add:ms];
	ms.position = pos;
	[self.batchNode addChild:ms];
	[ms createOverlayTextureRect];
  
}
- (void) startMarble
{
	self.dollyGroove = nil;
	self.dollyServo = nil;
  cpVect velocity =  self.dollyBody.vel;
  cpVect velocityNew =cpvmult(velocity, .5);
  self.dollyBody.vel = velocityNew;
	[self.gameDelegate marbleInGame];
}

- (void) moveMarble:(CMEvent*)movedEvent
{
  //	NSLog(@"MouseMoved: %@",movedEvent);
  //	self.marbleThrowerShape.body.pos = cpv(movedEvent.locationInWindow.x,748);
  //	_dollyServo.anchr1 = cpv(_touchTarget.x, 100);
#ifdef __CC_PLATFORM_MAC
	self.lastMousePosition = cpv(movedEvent.locationInWindow.x, MARBLE_GROOVE_Y);
#else
  UITouch *firstTouch =[[movedEvent.allTouches allObjects]objectAtIndex:0];
	self.lastMousePosition = cpv( [firstTouch locationInView:firstTouch.view].x , MARBLE_GROOVE_Y);
#endif
	self.dollyServo.anchr1 = self.lastMousePosition;
  //  self.dollyBody.pos = cpv(movedEvent.locationInWindow.x, MARBLE_GROOVE_Y);
  
}

#ifdef __CC_PLATFORM_MAC
-(BOOL) ccMouseDown:(CMEvent *)event
{
  [self startMarble];
	return YES;
}

- (BOOL) ccMouseMoved:(CMEvent*) movedEvent
{
  [self moveMarble:movedEvent];
	return YES;
}
#else

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  [self moveMarble:event];
//  NSLog(@"tMoved %@ %@",touches,event);
}

- (void) ccTouchesEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
  [self startMarble];
//  NSLog(@"tEnded %@ %@",touch,event);
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [self moveMarble:event];
}

#endif
#pragma mark -
#pragma mark Simulation

- (void) startSimulation
{
  self.simulationRunning = YES;
}

- (void) stopSimulation
{
  self.simulationRunning = NO;
}

- (void) resetSimulation
{
  self.simulationRunning=NO;
  [self.batchNode removeAllChildren];
  self.simulationRunning = YES;
}
- (void) retextureMarbles
{
  NSString *marbleSet =[[NSUserDefaults standardUserDefaults]stringForKey:@"MarbleSet"];
  for (CMMarbleSprite *marble in self.batchNode.children) {
    marble.setName=marbleSet;
  }
}


@end

@implementation CCMenu (MyLayout)

-(void) adjustContentSize
{
	CGRect contentRect = CGRectZero;
	for (CCNode *childNode in self.children) {
    
    CGRect childRect = childNode.boundingBox;
		contentRect = CGRectUnion(contentRect, childRect);
	}
	CGPoint offset = contentRect.origin;
	for (CCNode *childNode in self.children) {
    CGPoint pos = childNode.position;
		pos.x -=offset.x;
		pos.y -=offset.y;
    //		childNode.position = pos;
	}
	self.contentSize = contentRect.size;
	[self alignItemsHorizontallyWithPadding:10.0];
}


@end
