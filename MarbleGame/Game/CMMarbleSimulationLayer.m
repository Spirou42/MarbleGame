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
#import "CMMarbleLevel.h"
#import "CMSimpleShapeReader.h"
#import "CCLabelBMFont+CMMarbleRealBounds.h"
#import "CMMarbleMultiComboSprite.h"
#import "CMMarbleBatchNode.h"
#import "CocosDenshion.h"
#import "SimpleAudioEngine.h"

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

- (void) initializeLevel;
@end


@implementation CMMarbleSimulationLayer

@synthesize space = _space, batchNode=_bathNode, currentMarbleSet=_currentMarbleSet, debugLayer=_debugLayer,
simulationRunning=_simulationRunning, collisionCollector=_collisionCollector,simulatedMarbles=_simulatedMarbles,
dollyGroove = _dollyGroove, dollyShape = _dollyShape, dollyServo = _dollyServo, dollyBody = _dollyBody,
gameDelegate = _gameDelegate, lastMousePosition = _lastMousePosition,currentLevel=_currentLevel,
marbleFireTimer=_marbleFireTimer,marblesToFire=_marblesToFire, currentMarbleIndex,staticShapes=_staticShapes,
lastMarbleSoundTime = _lastMarbleSoundTime;

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
		// init physics
		[self initPhysics];
		// Use batch node. Faster currently the batch node is not supported cause i use a custome shader. This will change in the future.

#if 1
		self.batchNode= [CMMarbleBatchNode batchNodeWithFile:@"Balls.png" capacity:100];
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
// 	[self.space removeBody:self.space.staticBody];
	[self.marbleFireTimer invalidate];
	self.marbleFireTimer = nil;
	[self.space remove:self.bounds];
	[self.space remove:self.staticShapes];
	self.space = nil;
  self.collisionCollector = nil;
	self.currentMarbleSet = nil;
	self.simulatedMarbles = nil;
	self.dollyGroove = nil;
	self.dollyShape.body = nil;
	self.dollyShape = nil;
	self.dollyServo = nil;

	self.bounds = nil;
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
	self.bounds = [[self.space addBounds:newBounds
														thickness:60.0
													 elasticity:BORDER_ELASTICITY
														 friction:BORDER_FRICTION
															 layers:CP_ALL_LAYERS
																group:CP_NO_GROUP
												collisionType:borderType]autorelease];
	
	[self.space addCollisionHandler:self typeA:[CMMarbleSprite class] typeB:[CMMarbleSprite class]
														begin:@selector(beginMarbleCollision:space:)
												 preSolve:nil
												postSolve:@selector(postMarbleCollision:space:)
												 separate:@selector(separateMarbleCollision:space:)];
	self.space.collisionBias = pow(1.0-0.1, 400);
	_debugLayer = [CCPhysicsDebugNode debugNodeForCPSpace:self.space.space];
	_debugLayer.visible = NO;
	[self addChild:_debugLayer z:100];
	
	self.collisionCollector = [[[CMMarbleCollisionCollector alloc] init]autorelease];
	self.collisionCollector.collisionDelay = 0.2;
}


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
- (void) processSound:(cpArbiter*)arbiter first:(ChipmunkShape*) firstMarble second:(ChipmunkShape*) secondMarble
{
	if (!self.gameDelegate.playEffect) {
		return;
	}
	//	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, firstMarble, secondMarble);
	CMMarbleSprite *firstMarbleLayer = firstMarble.data;
	CMMarbleSprite *secondMarbleLayer = secondMarble.data;
	
	
	if ((self.lastMarbleSoundTime - firstMarbleLayer.lastSoundTime) < 1/2) {
		return;
	}
	CGFloat fSpeed = cpvlength(firstMarble.body.vel);
	CGFloat sSpeed = cpvlength(secondMarble.body.vel);
	if ((fSpeed < 1.0) || (sSpeed < 1.0) ) {
		return;
	}
	
	NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
	if ((currentTime -self.lastMarbleSoundTime)<(1.0f/10.0f)) {
		return;
	}
	cpFloat impulse = cpvlength(cpArbiterTotalImpulseWithFriction(arbiter));
	if (impulse<1000.00) {
		return;
	}
	
	//	CGFloat sVal = fSpeed + sSpeed;
	//	NSLog(@"%f,%f,(%f)",self.lastMarbleSoundTime,currentTime,currentTime-self.lastMarbleSoundTime);
	float volume = MIN(impulse/6000.0f , 1.0f);
	
	volume *= self.gameDelegate.soundVolume;
	if(volume > 0.1f){
		NSLog(@"S1(%p) = %f, S2(%p) = %f (%04.3f,%04.3f)",firstMarble,fSpeed,secondMarble,sSpeed,impulse,volume);
		[[SimpleAudioEngine sharedEngine] playEffect:DEFAULT_MARBLE_KLICK pitch:1.0 pan:1.0 gain:volume];
//		[[OALSimpleAudio sharedInstance] playEffect:MARBLE_SOUND volume:volume pitch:1.0 pan:1.0 loop:NO];
		self.lastMarbleSoundTime = [NSDate timeIntervalSinceReferenceDate];
		firstMarbleLayer.lastSoundTime = self.lastMarbleSoundTime;
		secondMarbleLayer.lastSoundTime = self.lastMarbleSoundTime;
	}
	
}

- (void) postMarbleCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)sp
{
	
	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, firstMarble, secondMarble);
	[self processSound:arbiter first:firstMarble second:secondMarble];
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

-(void) update:(ccTime) delta
{
	// Should use a fixed size step based on the animation interval.
	int steps = 2;
	CGFloat dt = [[CCDirector sharedDirector] animationInterval]/(CGFloat)steps;
	
	for(int i=0; i<steps; i++){
		[self.space step:dt];
    //		cpSpaceStep(_space, dt);
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
- (void) setSimulationRunning:(BOOL)run
{
  NSLog(@"isRunning In %d (%d)",self.isRunning,run);
  if (self->_simulationRunning != run) {
//    CCScheduler *s =self.scheduler;
    self->_simulationRunning = run;
    if (run) {
      [self scheduleUpdate];
    }else{
      [self unscheduleUpdate];
      //[s unscheduleUpdateForTarget:self];
    }
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
		[self->_dollyGroove release];
		self->_dollyGroove = [dG retain];
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
		[self->_dollyServo release];
		self->_dollyServo = [dS retain];
	}
}

- (void) setCurrentLevel:(CMMarbleLevel *)cL
{
	if (cL != self->_currentLevel) {
		self->_currentLevel = cL;
		[self initializeLevel];
	}
}
- (void) setStaticShapes:(NSArray *)staticBodies
{
	if (staticBodies != self->_staticShapes) {
		if (self->_staticShapes) {
			[self.space remove:self->_staticShapes];
		}

		ChipmunkBody * staticBody = self.space.staticBody;
		for (ChipmunkShape *shape in staticBodies) {
			shape.body = staticBody;
			[self.space add:shape];
		}
		[self->_staticShapes release];
		self->_staticShapes = [staticBodies retain];
	}

}

- (NSArray*) staticShapes
{
	return self.space.staticBody.shapes;
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
	self.dollyServo = [ChipmunkPivotJoint pivotJointWithBodyA:self.space.staticBody bodyB:self.dollyBody pivot:self.dollyBody.pos];
//	self.dollyServo = [ChipmunkPinJoint pinJointWithBodyA:self.space.staticBody bodyB:dB anchr1:dB.pos anchr2:cpv(0.0, 0.0)];
//  dB.pos = cpv(self.lastMousePosition.x, MARBLE_GROOVE_Y);
	
//	self.dollyServo.maxForce=1e6;
//	self.dollyServo.maxBias = INFINITY;
  self.dollyServo.errorBias = pow(1.0-0.1, 400);
//	self.dollyServo.dist = 0.001;
//	self.dollyServo.anchr1 = self.lastMousePosition;
	self.currentMarbleIndex = marbleIndex;
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
	[self.gameDelegate marbleDroppedWithID:self.currentMarbleIndex];
	[self.simulatedMarbles addObject:self.dollyBody.data];
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
- (void) onExit
{
  self.simulationRunning = NO;
	[self.marbleFireTimer invalidate];
	self.marbleFireTimer = nil;
//  self->entered=NO;
  [super onExit];
}

- (void) onEnter
{
//  self->entered=YES;
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
	[self.marbleFireTimer invalidate];
	self.marbleFireTimer = nil;
  [self.batchNode removeAllChildren];
	[self initializeLevel];
  self.simulationRunning = YES;
}
- (void) retextureMarbles
{
  NSString *marbleSet =[[NSUserDefaults standardUserDefaults]stringForKey:@"MarbleSet"];
  for (CMMarbleSprite *marble in self.batchNode.children) {
    marble.setName=marbleSet;
  }
}
- (void) initializeLevel
{
//	[self.space remove:self.bounds];
	self.staticShapes = self.currentLevel.shapeReader.shapes;
	[self.gameDelegate initializeLevel:self.currentLevel];
	NSUInteger p = self.currentLevel.numberOfMarbles;
	[self fireMarbles:p inTime:10];
	
}

- (void) fireSingleMarble:(NSTimer*) timer
{
	NSUInteger marbleIndex = [self.gameDelegate marbleIndex];
  NSString *marbleSet = [self.gameDelegate marbleSetName];
	CMMarbleSprite *ms = [[[CMMarbleSprite alloc]initWithBallSet:marbleSet ballIndex:marbleIndex mass:MARBLE_MASS andRadius:MARBLE_RADIUS]autorelease];
	[self.batchNode addChild:ms];
	[ms createOverlayTextureRect];
	[self.space add:ms];
	ChipmunkBody *dB = ms.shape.body;

	CGFloat velX = (2500.0 * (CGFloat)arc4random_uniform(100)/100.0) -1250.0;
	CGFloat velY = (2500.0 * (CGFloat)arc4random_uniform(100)/100.0) -1250.0 ;
//	NSLog(@"VelX: %f, VelY: %f",velX,velY);
	dB.vel = cpv(velX,velY);
	CGSize s = [[CCDirector sharedDirector] winSize];
	dB.pos = CGPointMake(s.width/2.0, s.height - 200);
	self.marblesToFire--;
	if (self.marblesToFire == 0) {
		[self.marbleFireTimer invalidate];
		self.marbleFireTimer = nil;
	}
	[self.gameDelegate marbleFiredWithID:marbleIndex];
	[self.simulatedMarbles addObject:ms];
}

- (void) fireMarbles:(NSUInteger)numOfMarbles inTime:(CGFloat)seconds
{
	if(!self.marbleFireTimer){
		CGFloat marbleCadenz = seconds/numOfMarbles;
		self.marblesToFire = numOfMarbles;
		NSTimer *marbleTimer = [NSTimer scheduledTimerWithTimeInterval:marbleCadenz target:self selector:@selector(fireSingleMarble:) userInfo:nil repeats:YES];
		self.marbleFireTimer = marbleTimer;
	}
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
