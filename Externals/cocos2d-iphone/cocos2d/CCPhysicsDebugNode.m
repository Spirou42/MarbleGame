/* Copyright (c) 2012 Scott Lembcke and Howling Moon Software
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


#import "ccConfig.h"

#if CC_ENABLE_CHIPMUNK_INTEGRATION

#import "CCPhysicsDebugNode.h"

#import "ccTypes.h"

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <limits.h>
#include <string.h>


/*
	IMPORTANT - READ ME!
	
	This file sets pokes around in the private API a lot to provide efficient
	debug rendering given nothing more than reference to a Chipmunk space.
	It is not recommended to write rendering code like this in your own games
	as the private API may change with little or no warning.
*/

static ccColor4F staticColor__, dynamicColor__, sleepingColor__, constraintColor__;
static NSInteger bodiesToDraw__;
static ccColor4F ColorForBody(cpBody *body)
{
	if (cpBodyIsRogue(body)) {
		return staticColor__;
	}
	if (cpBodyIsSleeping(body)) {
		return sleepingColor__;
	}
	if(body->CP_PRIVATE(node).idleTime > body->CP_PRIVATE(space)->sleepTimeThreshold){
		ccColor4F k = dynamicColor__;
		k.a = cpflerp(k.a, 1.0, 0.5);
		return k;
	}
	return dynamicColor__;

}

static void
DrawShape(cpShape *shape, CCDrawNode *renderer)
{
	cpBody *body = shape->body;
	ccColor4F color = ColorForBody(body);
	BOOL shouldDrawStatic = (bodiesToDraw__ & kChipmunkType_Static);
	BOOL shouldDrawDynamic = (bodiesToDraw__ & kChipmunkType_Dynamic);
	if (cpBodyIsRogue(body) && !shouldDrawStatic) {
		return;
	}
	if (!cpBodyIsRogue(body) && !shouldDrawDynamic){
		return;
	}

	switch(shape->CP_PRIVATE(klass)->type){
		case CP_CIRCLE_SHAPE: {
				cpCircleShape *circle = (cpCircleShape *)shape;
				cpVect center = circle->tc;
				cpFloat radius = circle->r;
				[renderer drawDot:center radius:cpfmax(radius, 1.0) color:color];
				[renderer drawSegmentFrom:center to:cpvadd(center, cpvmult(body->rot, radius)) radius:1.0 color:color];
			} break;
		case CP_SEGMENT_SHAPE: {
				cpSegmentShape *seg = (cpSegmentShape *)shape;
				[renderer drawSegmentFrom:seg->ta to:seg->tb radius:cpfmax(seg->r, 2.0) color:color];
			} break;
		case CP_POLY_SHAPE: {
				cpPolyShape *poly = (cpPolyShape *)shape;
				ccColor4F line = color;
				line.a = cpflerp(color.a, 1.0, 0.5);
				
				[renderer drawPolyWithVerts:poly->tVerts count:poly->numVerts fillColor:color borderWidth:.2 borderColor:line];
			}break;
		default:
			cpAssertHard(FALSE, "Bad assertion in DrawShape()");
	}
}



static void
DrawConstraint(cpConstraint *constraint, CCDrawNode *renderer)
{
	cpBody *body_a = constraint->a;
	cpBody *body_b = constraint->b;

	const cpConstraintClass *klass = constraint->CP_PRIVATE(klass);
	if(klass == cpPinJointGetClass()){
		cpPinJoint *joint = (cpPinJoint *)constraint;
		
		cpVect a = cpBodyLocal2World(body_a, joint->anchr1);
		cpVect b = cpBodyLocal2World(body_b, joint->anchr2);
		
		[renderer drawDot:a radius:3.0 color:constraintColor__];
		[renderer drawDot:b radius:3.0 color:constraintColor__];
		[renderer drawSegmentFrom:a to:b radius:1.0 color:constraintColor__];
	} else if(klass == cpSlideJointGetClass()){
		cpSlideJoint *joint = (cpSlideJoint *)constraint;

		cpVect a = cpBodyLocal2World(body_a, joint->anchr1);
		cpVect b = cpBodyLocal2World(body_b, joint->anchr2);

		[renderer drawDot:a radius:3.0 color:constraintColor__];
		[renderer drawDot:b radius:3.0 color:constraintColor__];
		[renderer drawSegmentFrom:a to:b radius:1.0 color:constraintColor__];
	} else if(klass == cpPivotJointGetClass()){
		cpPivotJoint *joint = (cpPivotJoint *)constraint;

		cpVect a = cpBodyLocal2World(body_a, joint->anchr1);
		cpVect b = cpBodyLocal2World(body_b, joint->anchr2);

		[renderer drawDot:a radius:3.0 color:constraintColor__];
		[renderer drawDot:b radius:3.0 color:constraintColor__];
	} else if(klass == cpGrooveJointGetClass()){
		cpGrooveJoint *joint = (cpGrooveJoint *)constraint;

		cpVect a = cpBodyLocal2World(body_a, joint->grv_a);
		cpVect b = cpBodyLocal2World(body_a, joint->grv_b);
		cpVect c = cpBodyLocal2World(body_b, joint->anchr2);

		[renderer drawDot:c radius:3.0 color:constraintColor__];
		[renderer drawSegmentFrom:a to:b radius:1.0 color:constraintColor__];
	} else if(klass == cpDampedSpringGetClass()){
		cpDampedSpring *joint = (cpDampedSpring *)constraint;
		
		cpVect a = cpBodyLocal2World(body_a, joint->anchr1);
		cpVect b = cpBodyLocal2World(body_b, joint->anchr2);
		
		[renderer drawDot:a radius:3.0 color:constraintColor__];
		[renderer drawDot:b radius:3.0 color:constraintColor__];
		[renderer drawSegmentFrom:a to:b radius:3.0 color:constraintColor__];
		CGPoint t =cpvsub(a, b);
		CGFloat length = cpvlength(t);
		length -= joint->restLength;

		if(length>0.0){
			CGFloat diffLength = length / joint->restLength;
			CGPoint q = cpvmult(t, diffLength);
			[renderer drawSegmentFrom:b to:cpvadd(q, b)  radius:1 color:ccc4f(1.0, 1.0, 0.0, 1.0)];
		}
		
		
	} else {
//		printf("Cannot draw constraint\n");
	}
}


@interface ChipmunkSpace : NSObject
-(cpSpace *)space;
@end


@implementation CCPhysicsDebugNode

@synthesize space = _spacePtr, bodysToDraw = bodysToDraw_, staticBodyColor=staticBodyColor_, dynamicBodyColor=dynamicBodyColor_, sleepingBodyColor=sleepingBodyColor_;

- (id) init
{
	self = [super init];
	if(self){

		self.staticBodyColor =  ccc4f(0.5, 0.5, 0.5 ,0.5);
		self.dynamicBodyColor = ccc4f(1.0, 0.0, 0.0, 0.5);
		self.constraintColor = ccc4f(0.0, 1.0, 0.0, 0.5);
		self.sleepingBodyColor = ccc4f(.2, 0.2, 0.2, 0.5);
		self.bodysToDraw = kChipmunkType_Constraint | kChipmunkType_Dynamic | kChipmunkType_Static;
	}
	return self;
}

-(void) draw;
{
	if( ! _spacePtr )
		return;
	/////// this is really BAD!
	staticColor__ = self.staticBodyColor;
	dynamicColor__ = self.dynamicBodyColor;
	sleepingColor__ = self.sleepingBodyColor;
	constraintColor__ = self.constraintColor;
	bodiesToDraw__ = self.bodysToDraw;
	cpSpaceEachShape(_spacePtr, (cpSpaceShapeIteratorFunc)DrawShape, self);

	if (self.bodysToDraw & kChipmunkType_Constraint) {
		cpSpaceEachConstraint(_spacePtr, (cpSpaceConstraintIteratorFunc)DrawConstraint, self);
	}

	
	[super draw];
	[super clear];
}

+ debugNodeForChipmunkSpace:(ChipmunkSpace *)space;
{
	CCPhysicsDebugNode *node = [[CCPhysicsDebugNode alloc] init];
	node->_spaceObj = [space retain];
	node->_spacePtr = space.space;

	return [node autorelease];
}

+ debugNodeForCPSpace:(cpSpace *)space;
{
	CCPhysicsDebugNode *node = [[CCPhysicsDebugNode alloc] init];
	node->_spacePtr = space;

	return [node autorelease];
}

- (void) dealloc
{
	[_spaceObj release];
	[super dealloc];
}

@end

#endif // CC_ENABLE_CHIPMUNK_INTEGRATION
