//
//  CMRubeBody.h
//  MarbleGame
//
//  Created by Carsten Müller on 8/19/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kRubeBody_static,
	kRubeBody_kinematic,
	kRubeBody_dynamic,
}CMRubeBodyType;

@interface CMRubeBody : NSObject
{
	@protected
	NSString* 				_name;
	CMRubeBodyType		_type;
	CGFloat						_angle;
	CGFloat						_angularVelocity;
	CGFloat						_linearVelocity;
	CGPoint						_position;
	NSMutableArray		*_fixtures;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, assign) CMRubeBodyType type;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGFloat angularVelocity;
@property (nonatomic, assign) CGFloat linearVelocity;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, retain) NSMutableArray *fixtures;
@end
