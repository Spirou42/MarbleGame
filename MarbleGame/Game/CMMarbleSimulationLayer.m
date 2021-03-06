//
//  CMMarbleSimulationLayer.m
//  MarbleGame
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
#import "CMMarbleLevel.h"
#import "CMSimpleShapeReader.h"
#import "CCLabelBMFont+CMMarbleRealBounds.h"
#import "CMMarbleMultiComboSprite.h"
#import "CMMarbleBatchNode.h"
#import "CocosDenshion.h"
#import "SimpleAudioEngine.h"
#import "CMRubeSceneReader.h"
#import "ObjectiveChipmunk.h"
#import "CMRubeBody.h"
#import "CMObjectSoundProtocol.h"
#import "CMMarblePowerUpBomb.h"
#import "CMMarblePowerUpBallBomb.h"
#import "CMMarbleEmitter.h"
#import "CMPhysicsJointSprite.h"

enum {
	kTagParentNode = 1,
};
@interface CCMenu (MyLayout)
- (void) adjustContentSize;
@end

static NSString *borderType = @"borderType";
#pragma mark - HelloWorldLayer

@interface CMMarbleSimulationLayer ()

-(void) initPhysics;

@property (nonatomic, assign) CGPoint lastMousePosition;

- (void) initializeLevel;
@end


@implementation CMMarbleSimulationLayer

@synthesize space = space_, marbleBatchNode=marbleBatchNode_,objectsSpritesNode = objectsSpritesNode_, currentMarbleSet=currentMarbleSet_, debugLayer=debugLayer_,
simulationRunning=simulationRunning_, collisionCollector=collisionCollector_,simulatedMarbles=simulatedMarbles_,
dollyGroove = dollyGroove_, dollyServo = dollyServo_, dollyBody = dollyBody_,
gameDelegate = gameDelegate_, lastMousePosition = lastMousePosition_,currentLevel=currentLevel_,
currentMarbleIndex = currentMarbleIndex_,worldShapes=staticShapes_,
lastMarbleSoundTime = _lastMarbleSoundTime,dynamicSprites = dynamicSprites_, staticSprites = staticSprites_,constraints = constraints_;

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
//		self->_simulationRunning=YES;
		self.simulatedMarbles = [NSMutableArray array];
		self.dynamicSprites = [NSMutableArray array];
		self.staticSprites = [NSMutableArray array];
		self.constraints = [NSMutableArray array];
		self.otherObjects = [NSMutableArray array];
		// init physics
		[self initPhysics];
		
		self.othersSpriteNode = [CCNode node];
		[self addChild:self.othersSpriteNode z:0];
		
		self.physicsSpritesNode = [CCNode node];
		[self addChild:self.physicsSpritesNode z:1];
		
		// Use batch node. Faster currently the batch node is not supported cause i use a custome shader. This will change in the future.

#if 1
		self.marbleBatchNode= [CMMarbleBatchNode batchNodeWithFile:@"Balls.png" capacity:100];
#else
    self.marbleBatchNode = [CCNode node];
#endif
		[self addChild:self.marbleBatchNode z:2 tag:kTagParentNode];

		
		self.objectsSpritesNode = [CCNode node];
		[self addChild:self.objectsSpritesNode z:3];

		// this starts the update process automatically
    [self scheduleUpdate];
    self.simulationRunning = YES;
	}
	
	return self;
}

- (void)dealloc
{
	// invalidate timer
	[self.currentLevel.marbleEmitter stopEmitter];

	// remove dynamic sprites
	[self.space remove:self.dynamicSprites];
	self.dynamicSprites = nil;

	// remove static Sprites;
	[self.space remove:self.staticSprites];
	self.staticSprites = nil;

	[self.space remove:self.constraints];
	self.constraints = nil;
	
	self.worldShapes = nil;
//	[self.space remove:self.bounds];

	self.space = nil;
  self.collisionCollector = nil;
	self.currentMarbleSet = nil;
	self.simulatedMarbles = nil;
	self.dollyGroove = nil;
	self.dollyServo = nil;

	self.bounds = nil;

	[super dealloc];
	
}
- (id) retain
{
  return [super retain];
}
-(oneway void) release
{
  [super release];
}

-( id) autorelease
{
  return[super autorelease];
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
  p.size.height = 768;// - 54;
  p.origin.y = 0;//54;
	CGRect newBounds = CGRectInset(p,-400,-400);
	self.bounds = [[self.space addBounds:newBounds
														thickness:60.0
													 elasticity:BORDER_ELASTICITY
														 friction:BORDER_FRICTION
															 layers:CP_ALL_LAYERS
																group:CP_NO_GROUP
												collisionType:COLLISION_TYPE_BORDER]autorelease];
	
	[self.space addCollisionHandler:self typeA:COLLISION_TYPE_MARBLE typeB:COLLISION_TYPE_MARBLE
														begin:@selector(beginMarbleCollision:space:)
												 preSolve:nil
												postSolve:@selector(postBorderCollision:space:)
												 separate:@selector(separateMarbleCollision:space:)];
  

	[self.space setDefaultCollisionHandler:self
																	 begin:nil
																preSolve:nil
															 postSolve:@selector(postBorderCollision:space:)
																separate:nil];
  self.space.iterations = 10;
//	self.space.collisionBias = pow(1.0-0.1, 400);
	debugLayer_ = [CCPhysicsDebugNode debugNodeForCPSpace:self.space.space];
	debugLayer_.visible = NO;
#if PHYSICS_PRODUCTION
	debugLayer_.visible = YES;
	debugLayer_.staticBodyColor = ccc4f(0.0, 1.0, 0.0, 0.5);
	debugLayer_.bodysToDraw = kChipmunkType_Dynamic|kChipmunkType_Static|kChipmunkType_Constraint;
	debugLayer_.constraintColor = ccc4f(0.8, 0.8, 0.1, .5);
#endif
	[self addChild:debugLayer_ z:100];
	self.space.damping = 0.8;
	
	self.collisionCollector = [[[CMMarbleCollisionCollector alloc] init]autorelease];
	self.collisionCollector.collisionDelay = 0.2;
}

#pragma mark Collision handlers

- (BOOL) beginMarbleCollision:(cpArbiter*) arbiter space:(ChipmunkSpace*) space
{
	
	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, firstMarble, secondMarble);
	CMMarbleSprite *firstMarbleLayer = firstMarble.data;
	CMMarbleSprite *secondMarbleLayer = secondMarble.data;
	CMMarbleSprite *db = self.dollyBody.data;
	if ((firstMarbleLayer == db) || (secondMarbleLayer == db)) {
		return YES;
	}
	
	if (firstMarbleLayer.ballIndex == secondMarbleLayer.ballIndex) {
		[self.collisionCollector object:firstMarbleLayer touching:secondMarbleLayer];
		firstMarbleLayer.touchesNeighbour = YES;
		secondMarbleLayer.touchesNeighbour = YES;
	}
  return YES;
}

- (void) postMarbleCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)sp
{
	NSLog(@"postMarble");
	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, firstMarble, secondMarble);
	if (cpArbiterIsFirstContact(arbiter)) {
		[self processSound:arbiter first:firstMarble second:secondMarble];
	}

}

- (void) separateMarbleCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space
{
	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, firstMarble, secondMarble);
	CMMarbleSprite *firstMarbleLayer = firstMarble.data;
	CMMarbleSprite *secondMarbleLayer = secondMarble.data;
	CMMarbleSprite *db = self.dollyBody.data;
	if ((firstMarbleLayer == db) || (secondMarbleLayer == db)) {
		return;
	}
	if (firstMarbleLayer.ballIndex == secondMarbleLayer.ballIndex) {
		[self.collisionCollector object:firstMarbleLayer releasing:secondMarbleLayer];
		firstMarbleLayer.touchesNeighbour=NO;
		secondMarbleLayer.touchesNeighbour=NO;
	}
}

- (void) postBorderCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space
{
  CHIPMUNK_ARBITER_GET_SHAPES(arbiter, firstObj, secondObj);
	if (cpArbiterIsFirstContact(arbiter)) {
//		NSLog(@"postBorder");
		[self processSound:arbiter first:firstObj second:secondObj];
	}
	
}

-(void) update:(ccTime) delta
{
	// Should use a fixed size step based on the animation interval.
  if (!self->simulationRunning_) {
		[self.gameDelegate simulationStepDone:delta];
    return;
  }
	MarbleGameAppDelegate *appDel = CMAppDelegate;
	
	NSInteger steps = appDel.simulationSteps;
	// [[CCDirector sharedDirector] animationInterval]
	CGFloat dt =delta/(CGFloat)steps;
//	NSLog(@"delta:%2.1f",1/delta);
	for(int i=0; i<steps; i++){
		[self.space step:dt];
	}
	[self.gameDelegate simulationStepDone:delta];
	[self.collisionCollector cleanupFormerCollisions];
}

- (void) removeCollisionSets:(NSArray*) layers
{
	NSMutableSet *alreadyRemoved = [NSMutableSet set];
	
	for (NSSet *colSet in layers) {
    for (CMMarbleSprite *layer in colSet) {
			if (![alreadyRemoved containsObject:layer]) {
				[alreadyRemoved addObject:layer];
				[self.simulatedMarbles removeObject:layer];
				layer.shouldDestroy = YES;
				[self.collisionCollector removeObject:layer];
			}
		}
	}
	if ([alreadyRemoved count]) {
		NSMutableSet *imageSet = [NSMutableSet set];
		for (CMMarbleSprite *marbleSprite in self.simulatedMarbles) {
			[imageSet addObject:[NSNumber numberWithInteger:marbleSprite.ballIndex]];
		}
		[self.gameDelegate imagesOnField:imageSet];
	}
	
}

////////////////////////////////////////////////////////////////////////
#pragma mark - SOUND


- (NSString*) soundForFirstShape:(ChipmunkShape*)firstMarble secondShape:(ChipmunkShape*) secondMarble
{
	//	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, firstMarble, secondMarble);
	CMMarbleSprite *firstMarbleLayer = firstMarble.data;
	CMMarbleSprite *secondMarbleLayer = secondMarble.data;
	
	// sound to play
	NSString *firstShapeSound = nil;
	NSString *secondShapeSound = nil;
	if ([firstMarble conformsToProtocol:@protocol(CMObjectSoundProtocol)]) {
		id<CMObjectSoundProtocol> sobj = (id<CMObjectSoundProtocol>)firstMarble;
		firstShapeSound = sobj.soundName;
	}
	if ([secondMarble conformsToProtocol:@protocol(CMObjectSoundProtocol)]) {
		id<CMObjectSoundProtocol> sobj = (id<CMObjectSoundProtocol>)secondMarble;
		secondShapeSound = sobj.soundName;
	}
	
	if (!firstShapeSound) {
		if ([firstMarbleLayer conformsToProtocol:@protocol(CMObjectSoundProtocol)]) {
			id<CMObjectSoundProtocol> sObj = (id<CMObjectSoundProtocol>)firstMarbleLayer;
			firstShapeSound = sObj.soundName;
		}
	}
	
	if (!secondShapeSound) {
		if ([secondMarbleLayer conformsToProtocol:@protocol(CMObjectSoundProtocol)]) {
			id<CMObjectSoundProtocol> sObj = (id<CMObjectSoundProtocol>)secondMarbleLayer;
			secondShapeSound = sObj.soundName;
		}
	}
	
	NSString *resultSound = DEFAULT_MARBLE_KLICK;
	
	if (firstShapeSound && ![firstShapeSound isEqualToString:DEFAULT_MARBLE_KLICK]) {
		resultSound = firstShapeSound;
	}
	if (secondShapeSound && ![secondShapeSound isEqualToString:DEFAULT_MARBLE_KLICK]) {
		resultSound = secondShapeSound;
	}
	return resultSound;
}

- (CGFloat) panForShape:(ChipmunkShape*) firstShape secondShape:(ChipmunkShape*)secondShape
{
	CGFloat result = 0.0;
	ChipmunkShape *theShape = nil;
	if (!firstShape.body.isStatic) {
		theShape = firstShape;
	}else if(!secondShape.body.isStatic){
		theShape = secondShape;
	}
	
	CGFloat panPos = 0.0;
  CGFloat bodyX = theShape.body.pos.x;
  if (bodyX<342.0f) {
    panPos = -DEFAULT_PAN_LIMIT;
  }else if (bodyX>682.0f){
    panPos = DEFAULT_PAN_LIMIT;
  }

	result = panPos;
	
	return result;
}

- (void) processSound:(cpArbiter*)arbiter first:(ChipmunkShape*) firstMarble second:(ChipmunkShape*) secondMarble
{
	if (!self.gameDelegate.playEffect) {
		return;
	}

	//	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, firstMarble, secondMarble);
	CMMarbleSprite *firstMarbleLayer = firstMarble.data;
	CMMarbleSprite *secondMarbleLayer = secondMarble.data;

	NSString *resultSound = [self soundForFirstShape:firstMarble secondShape:secondMarble];
	
	CGFloat pan = [self panForShape:firstMarble secondShape:secondMarble];
	if ((self.lastMarbleSoundTime - firstMarbleLayer.lastSoundTime) < 1/2) {

		return;
	}

	CGFloat fSpeed = cpvlength(firstMarble.body.vel);
	CGFloat sSpeed = cpvlength(secondMarble.body.vel);
  if (!secondMarbleLayer) {
    sSpeed = 1.0;
  }
//	if ((fSpeed < 1.0) || (sSpeed < 1.0) ) {
//		return;
//	}
	
	NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
	if ([resultSound isEqualToString:@"Klick.mp3"] &&  (currentTime -self.lastMarbleSoundTime)<(1.0f/15.0f) ) {
		return;
	}
	cpFloat impulse = cpvlength(cpArbiterTotalImpulseWithFriction(arbiter));
//	if ([resultSound isEqualToString:@"Boing.mp3"]) {
//		NSLog(@"Sound: %@ I(%f)",resultSound,impulse);
//	}
	if (impulse<100) {
		return;
	}else
		if(impulse>10000.0f){
		impulse = 10000.0f;
	}

	float volume = MIN(impulse/10000.0f , 1.0f);

	volume *= self.gameDelegate.soundVolume;
//	if ([resultSound isEqualToString:@"Boing.mp3"]) {
//			NSLog(@"Sound: %@ (%f)",resultSound,volume);
//	}

	if(volume > 0.1f){
    CGFloat pitch = 1.0;

		[[SimpleAudioEngine sharedEngine] playEffect:resultSound pitch:1.0 pan:pan gain:volume];
		self.lastMarbleSoundTime = currentTime;
		firstMarbleLayer.lastSoundTime = self.lastMarbleSoundTime;
		secondMarbleLayer.lastSoundTime = self.lastMarbleSoundTime;
	}
}

#pragma mark -
#pragma mark Properties

- (void) scheduleUpdate
{
  [super scheduleUpdate];
}

- (void) unscheduleUpdate
{
  [super unscheduleUpdate];
}

- (void) setSimulationRunning:(BOOL)run
{
  NSLog(@"isRunning In %d (%d)",self.isRunning,run);
  if (self->simulationRunning_ != run) {
    self->simulationRunning_ = run;
  }
  NSLog(@"isRunning Out %d (%d)",self.isRunning,run);
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
		[self->dollyGroove_ release];
		self->dollyGroove_ = [dG retain];
	}
}

- (void) setDollyServo:(ChipmunkPivotJoint *)dS
{
	if (dS != self.dollyServo) {
		if (self.dollyServo) {
			[self.space removeConstraint:self.dollyServo];
		}
		if (dS) {
			[self.space addConstraint:dS];
		}
		[self->dollyServo_ release];
		self->dollyServo_ = [dS retain];
	}
}

- (void) setCurrentLevel:(CMMarbleLevel *)cL
{
	if (cL != self->currentLevel_) {
    [self.space remove:self.dynamicSprites];
    [self.dynamicSprites removeAllObjects];
		self->currentLevel_ = cL;
	}
}

- (void) setWorldShapes:(NSArray *)staticShapes
{
	if (staticShapes != self->staticShapes_) {
		if (self->staticShapes_) {
			[self.space remove:self->staticShapes_];
		}
    if (!self.currentLevel.isRubeLevel) {
      ChipmunkBody * staticBody = self.space.staticBody;
      for (ChipmunkShape *shape in staticShapes) {
        shape.body = staticBody;
        [self.space add:shape];
      }
    }else{
			if (staticShapes) {
				[self.space add:staticShapes];
			}

      cpSpace *aSpace = self.space.space;
      cpSpaceReindexStatic(aSpace);
    }
		[self->staticShapes_ release];
		self->staticShapes_ = [staticShapes retain];
	}
}

- (NSArray*) worldShapes
{
	return self.space.staticBody.shapes;
}


#pragma mark -
#pragma mark actions

- (void) prepareMarble
{
	static int marbleCounter = 0;
	
	marbleCounter ++;
	
	NSUInteger marbleIndex = [self.gameDelegate marbleIndex];
  NSString *marbleSet = [self.gameDelegate marbleSetName];
	CMMarbleSprite *ms = [[[CMMarbleSprite alloc]initWithBallSet:marbleSet ballIndex:marbleIndex mass:MARBLE_MASS andRadius:MARBLE_RADIUS]autorelease];
  ms.gameDelegate = self.gameDelegate;
	ms.chipmunkBody.velLimit = MARBLE_MAX_VELOCITY;
	[self.marbleBatchNode addChild:ms];
//	[ms createOverlayTextureRect];
	[self.space add:ms];

	ChipmunkBody *dB = ms.chipmunkBody;
  self.dollyBody = dB;
	dB.pos = cpv(self.lastMousePosition.x, MARBLE_GROOVE_Y);
	// create the Groove
	cpVect start = cpv(0, MARBLE_GROOVE_Y);
	cpVect end = cpv(1024,MARBLE_GROOVE_Y);
	cpVect anchor = cpv(0,0);

	self.dollyGroove= [ChipmunkGrooveJoint grooveJointWithBodyA:self.space.staticBody bodyB:dB groove_a:start groove_b:end anchr2:anchor];

	// create the Servo
	self.dollyServo = [ChipmunkPivotJoint pivotJointWithBodyA:self.space.staticBody bodyB:self.dollyBody pivot:self.dollyBody.pos];
  self.dollyServo.errorBias = pow(1.0-0.1, 400);
	self.currentMarbleIndex = marbleIndex;
	
	if ((marbleCounter % POWER_UP_EXPLOSION_FREQUENCY) == 0) {
		CMMarblePowerUpBomb *bombEffect = [CMMarblePowerUpBomb powerupWithMarble:ms];
    bombEffect.activeTime = 60.0;
    ms.marbleAction = bombEffect;
	}else if ((marbleCounter % (int)(POWER_UP_EXPLOSION_FREQUENCY * 1.6))==0 ){
		CMMarblePowerUpBallBomb *bombEffect = [CMMarblePowerUpBallBomb powerupWithMarble:ms];
    bombEffect.activeTime = 3*60.0;
		ms.marbleAction = bombEffect;
	}
}


- (void) startMarble
{
  if (self.dollyBody) {
    self.dollyGroove = nil;
    self.dollyServo = nil;
    cpVect velocity =  self.dollyBody.vel;
    cpVect velocityNew =cpvmult(velocity, .66);
    self.dollyBody.vel = velocityNew;
    [self.gameDelegate marbleDroppedWithID:self.currentMarbleIndex];
    [self.simulatedMarbles addObject:self.dollyBody.data];
    self.dollyBody = nil;
  }
}

- (void) moveMarble:(CMEvent*)movedEvent
{

#ifdef __CC_PLATFORM_MAC
	self.lastMousePosition = cpv(movedEvent.locationInWindow.x, MARBLE_GROOVE_Y);
#else
  UITouch *firstTouch =[[movedEvent.allTouches allObjects]objectAtIndex:0];
	self.lastMousePosition = cpv( [firstTouch locationInView:firstTouch.view].x , MARBLE_GROOVE_Y);
#endif
	self.dollyServo.anchr1 = self.lastMousePosition;
}

#ifdef __CC_PLATFORM_MAC
-(BOOL) ccMouseDown:(CMEvent *)event
{
  [self startMarble];
	return YES;
}

- (BOOL) ccRightMouseDown:(NSEvent *)event
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
}

- (void) ccTouchesEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
  [self startMarble];
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [self moveMarble:event];
}

#endif
- (void) onExit
{
  self.simulationRunning = NO;
  /// todo:  the marble timer has to be restarted in onEnter
	[self.currentLevel.marbleEmitter stopEmitter];
  [super onExit];
}

- (void) onEnter
{
  self.simulationRunning = YES;
  [super onEnter];
}


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
	[self.currentLevel.marbleEmitter stopEmitter];
  [self.marbleBatchNode removeAllChildren];
  [self.simulatedMarbles removeAllObjects];
	[self initializeLevel];
  self.simulationRunning = YES;
}

- (void) cleanupMarbles
{

}

- (void) retextureMarbles
{
  NSString *marbleSet =[[NSUserDefaults standardUserDefaults]stringForKey:@"MarbleSet"];
  for (CMMarbleSprite *marble in self.marbleBatchNode.children) {
    marble.marbleSetName=marbleSet;
  }
}
#pragma mark -
#pragma mark Level Initialisation
#pragma mark -

- (CCNode*) nodeForLayerName:(NSString*)layerName
{
	CCNode *result = nil;
	if ([layerName isEqualToString:@"Objects"]) {
    result = self.objectsSpritesNode;
	}else if ([layerName isEqualToString:@"Marbles"]){
		result = self.marbleBatchNode;
	}else if ([layerName isEqualToString:@"Physics"]){
		result = self.physicsSpritesNode;
	}else if ([layerName isEqualToString:@"Other"]){
		result = self.othersSpriteNode;
	}
	if (result == nil) {
    result = self.objectsSpritesNode;
	}
	return result;
}

- (void) initializeLevel
{
	[self.space remove:self.dynamicSprites];
	[self.dynamicSprites removeAllObjects];
	
	[self.space remove:self.staticSprites];
	[self.staticSprites removeAllObjects];

	[self.space remove:self.constraints];
	[self.constraints removeAllObjects];
	
	[self.space remove:self.otherObjects];
	[self.otherObjects removeAllObjects];

	[self.space remove: self.space.bodies];

	self.worldShapes = [self.currentLevel worldShapes];
	[self.objectsSpritesNode removeAllChildren];
	[self.marbleBatchNode removeAllChildren];
	[self.physicsSpritesNode removeAllChildren];
	[self.othersSpriteNode removeAllChildren];
	[self.gameDelegate initializeLevel:self.currentLevel];
  
	NSUInteger p = self.currentLevel.numberOfMarbles;
	
	{
    // request all dynamics, if this is a Rube level
		for (id a in self.currentLevel.dynamicSprites) {
			[self.dynamicSprites addObject:a];
			[self.space add:a];
#if !PHYSICS_PRODUCTION

			if ([a isKindOfClass:[CMPhysicsSprite class]]) {
				CMPhysicsSprite *p = (CMPhysicsSprite*)a;
				CCNode *targetNode = [self nodeForLayerName:p.layerName];
				[targetNode addChild:p];
				if (p.overlayNode) {
					[targetNode addChild:p.overlayNode z:10];
				}
			}
#endif
		}
		
		// request all static Sprites
		for (id a in self.currentLevel.staticSprites) {
			[self.staticSprites addObject:a];
			[self.space add:a];
#if !PHYSICS_PRODUCTION

			if ([a isKindOfClass:[CMPhysicsSprite class]]) {
				CMPhysicsSprite *p = (CMPhysicsSprite*)a;
				CCNode *targetNode = [self nodeForLayerName:p.layerName];
				[targetNode addChild:a];
				if (p.overlayNode) {
					[targetNode addChild:p.overlayNode z:10];
				}
			}
#endif
		}
		
		// all other dynamic objects
		for (id somObject in self.currentLevel.nonSpriteObjects) {
			[self.space add:somObject];
			[self.otherObjects addObject:somObject];
		}
		
		
		// Constraints
		for (id a in self.currentLevel.constrains) {
			[self.space add:a];
			[self.constraints addObject:a];
			CMPhysicsJointSprite* jointSprite = (CMPhysicsJointSprite*)[a physicsSprite];
			if (jointSprite) {
				CCNode *targetNode = [self nodeForLayerName:jointSprite.layerName];
				NSLog(@"SpriteJoint: %@",jointSprite);
				[targetNode addChild:jointSprite];
			}
			
		}
	}
  self.currentLevel.marbleEmitter.simulationLayer = self;
  [self.currentLevel.marbleEmitter startEmitter];

}

- (void) marbleFired:(CMMarbleSprite*)marble
{

  [self.marbleBatchNode addChild:marble];
  //	[ms createOverlayTextureRect];
	[self.space add:marble];


	[self.gameDelegate marbleFiredWithID:marble.ballIndex];
	[self.simulatedMarbles addObject:marble];
}


- (void) removedMarbles:(NSSet *)removedOnes
{
	CMMarbleSprite *ms = self.dollyBody.data;
	if (ms) {
		for (NSNumber *p in [removedOnes allObjects]) {
			if (p.integerValue == ms.ballIndex) {
				ms.ballIndex = [self.gameDelegate marbleIndex];
				self.currentMarbleIndex = ms.ballIndex;
				break;
			}
		}
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
