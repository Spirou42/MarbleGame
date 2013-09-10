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
#import "CMRubeSceneReader.h"
#import "ObjectiveChipmunk.h"
#import "CMRubeBody.h"

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
@property (nonatomic,retain) NSMutableArray *dynamicObjects;

- (void) initializeLevel;
@end


@implementation CMMarbleSimulationLayer

@synthesize space = space_, marbleBatchNode=marbleBatchNode_,otherSpritesNode = otherSpritesNode_, currentMarbleSet=currentMarbleSet_, debugLayer=debugLayer_,
simulationRunning=simulationRunning_, collisionCollector=collisionCollector_,simulatedMarbles=simulatedMarbles_,
dollyGroove = dollyGroove_, dollyShape = dollyShape_, dollyServo = dollyServo_, dollyBody = dollyBody_,
gameDelegate = gameDelegate_, lastMousePosition = lastMousePosition_,currentLevel=currentLevel_,
marbleFireTimer=marbleFireTimer_,marblesToFire=marblesToFire_, currentMarbleIndex = currentMarbleIndex_,staticShapes=staticShapes_,
lastMarbleSoundTime = _lastMarbleSoundTime,dynamicObjects = dynamicObjects_;

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
		self.dynamicObjects = [NSMutableArray array];
		// init physics
		[self initPhysics];
		// Use batch node. Faster currently the batch node is not supported cause i use a custome shader. This will change in the future.

#if 1
		self.marbleBatchNode= [CMMarbleBatchNode batchNodeWithFile:@"Balls.png" capacity:100];
#else
    self.marbleBatchNode = [CCNode node];
#endif
		[self addChild:self.marbleBatchNode z:0 tag:kTagParentNode];

		
		self.otherSpritesNode = [CCNode node];
		[self addChild:self.otherSpritesNode];
		
//		[self addNewSpriteAtPosition:ccp(200,200)];
//		[self prepareMarble];

		// this starts the update process automatically
    [self scheduleUpdate];
    self.simulationRunning = YES;
	}
	
	return self;
}

- (void)dealloc
{
// 	[self.space removeBody:self.space.staticBody];
	[self.space remove:self.dynamicObjects];
	self.dynamicObjects = nil;
	[self.marbleFireTimer invalidate];
	self.marbleFireTimer = nil;
	self.staticShapes = nil;
//	[self.space remove:self.bounds];

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
  p.size.height = 768 - 54;
  p.origin.y = 54;
	CGRect newBounds = CGRectInset(p,0,0);
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
												postSolve:@selector(postMarbleCollision:space:)
												 separate:@selector(separateMarbleCollision:space:)];
  
  [self.space addCollisionHandler:self
                            typeA:COLLISION_TYPE_MARBLE typeB:COLLISION_TYPE_BORDER
                            begin:nil
                         preSolve:nil
                        postSolve:@selector(postBorderCollision:space:)
                         separate:nil];

	self.space.collisionBias = pow(1.0-0.1, 400);
	debugLayer_ = [CCPhysicsDebugNode debugNodeForCPSpace:self.space.space];
	debugLayer_.visible = NO;
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

- (BOOL) beginBorderCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)sp
{
  return YES;
//  NSLog(@"collision: %@ %@",firstObj,secondObj);
}

- (void) postBorderCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space
{
  CHIPMUNK_ARBITER_GET_SHAPES(arbiter, firstObj, secondObj);
	if (cpArbiterIsFirstContact(arbiter)) {
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
	int steps = 1;
	CGFloat dt = [[CCDirector sharedDirector] animationInterval]/(CGFloat)steps;
	
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


#pragma mark - SOUND


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
  if (!secondMarbleLayer) {
    sSpeed = 1.0;
  }
	if ((fSpeed < 1.0) || (sSpeed < 1.0) ) {
		return;
	}
	
	NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
	if ((currentTime -self.lastMarbleSoundTime)<(1.0f/10.0f)) {
		return;
	}
	cpFloat impulse = cpvlength(cpArbiterTotalImpulse(arbiter));

	if (impulse<1000.00) {
		return;
	}
	
	//	CGFloat sVal = fSpeed + sSpeed;
	//	NSLog(@"%f,%f,(%f)",self.lastMarbleSoundTime,currentTime,currentTime-self.lastMarbleSoundTime);
	float volume = MIN(impulse/6000.0f , 1.0f);
	
	volume *= self.gameDelegate.soundVolume;
	if(volume > 0.1f){
		//		NSLog(@"S1(%p) = %f, S2(%p) = %f (%04.3f,%04.3f)",firstMarble,fSpeed,secondMarble,sSpeed,impulse,volume);
    CGFloat pitch = 1.0;
    if (!secondMarbleLayer) {
      pitch = 5.0;
    }
		[[SimpleAudioEngine sharedEngine] playEffect:DEFAULT_MARBLE_KLICK pitch:pitch pan:1.0 gain:volume];
		//		[[OALSimpleAudio sharedInstance] playEffect:MARBLE_SOUND volume:volume pitch:1.0 pan:1.0 loop:NO];
		self.lastMarbleSoundTime = [NSDate timeIntervalSinceReferenceDate];
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
//    CCScheduler *s =self.scheduler;
    self->simulationRunning_ = run;
#if 0
    if (run) {
      [self scheduleUpdate];
    }else{
      [self unscheduleUpdate];
      //[s unscheduleUpdateForTarget:self];
    }
#endif
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
    [self.space remove:self.dynamicObjects];
    [self.dynamicObjects removeAllObjects];
		self->currentLevel_ = cL;
//		[self initializeLevel];
	}
}
- (void) setStaticShapes:(NSArray *)staticShapes
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
	[self.marbleBatchNode addChild:ms];
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
	[self.marbleBatchNode addChild:ms];
	[ms createOverlayTextureRect];
  
}
- (void) startMarble
{
	self.dollyGroove = nil;
	self.dollyServo = nil;
  cpVect velocity =  self.dollyBody.vel;
  cpVect velocityNew =cpvmult(velocity, .66);
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
  /// todo:  the marble timer has to be restarted in onEnter
	[self.marbleFireTimer invalidate];
	self.marbleFireTimer = nil;
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
	[self.marbleFireTimer invalidate];
	self.marbleFireTimer = nil;
  [self.marbleBatchNode removeAllChildren];
	[self initializeLevel];
  self.simulationRunning = YES;
}
- (void) retextureMarbles
{
  NSString *marbleSet =[[NSUserDefaults standardUserDefaults]stringForKey:@"MarbleSet"];
  for (CMMarbleSprite *marble in self.marbleBatchNode.children) {
    marble.setName=marbleSet;
  }
}
- (void) initializeLevel
{
	[self.space remove:self.dynamicObjects];
	[self.dynamicObjects removeAllObjects];

	[self.space remove: self.space.bodies];
//	[self.space remove: self.space.shapes];
	self.staticShapes = [self.currentLevel staticObjects];
	[self.otherSpritesNode removeAllChildren];
	[self.gameDelegate initializeLevel:self.currentLevel];
	NSUInteger p = self.currentLevel.numberOfMarbles;
	
	{ // request all dynamics, if this is a Rube level
		if (self.currentLevel.isRubeLevel) {
			CMRubeSceneReader *reader = self.currentLevel.rubeReader;
			NSArray *dynBodies = reader.dynamicBodies;
			for (CMRubeBody *aBody in dynBodies) {
				CCPhysicsSprite *dynSprite = aBody.physicsSprite;
				[self.space add:aBody.chipmunkObjects];
				[self.dynamicObjects addObjectsFromArray:aBody.chipmunkObjects];
				[self.otherSpritesNode addChild:dynSprite];
			}
		}

	}
	
	[self fireMarbles:p inTime:10];
	
}

- (void) fireSingleMarble:(NSTimer*) timer
{
	NSUInteger marbleIndex = [self.gameDelegate marbleIndex];
  NSString *marbleSet = [self.gameDelegate marbleSetName];
	CMMarbleSprite *ms = [[[CMMarbleSprite alloc]initWithBallSet:marbleSet ballIndex:marbleIndex mass:MARBLE_MASS andRadius:MARBLE_RADIUS]autorelease];
	[self.marbleBatchNode addChild:ms];
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
