//
//  CMRubeImage.h
//  MarbleGame
//
//  Created by Carsten Müller on 8/19/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kRubeImageType_Unknown = -1,
	kRubeImageType_Background = 0,
	kRubeImageType_Overlay = 1,
	kRubeImageType_Sprite = 2,
} CMRubeImageType;


@class CCSprite;

@interface CMRubeImage : NSObject

@property (nonatomic,assign) CMRubeImageType type;
@property (nonatomic,retain) NSString* name;

@property (nonatomic, assign) CGFloat rubeOpacity;
@property (nonatomic, assign) CGFloat rubeScale;
@property (nonatomic, assign) CGFloat rubeAspectScale;
@property (nonatomic, assign) CGFloat rubeAngle;
@property (nonatomic, assign) CGPoint rubeCenter;
@property (nonatomic, assign) NSInteger rubeBodyIndex;
@property (nonatomic, retain) NSString* filename;
@property (nonatomic, assign) NSInteger rubeRenderOrder;

@property (nonatomic, readonly) CCSprite* sprite;

- (id) initWithDictionary:(NSDictionary*) dict;

@end


/*
 "name": "image0",
 "opacity": 1, //the length of the vertical side of the image in physics units
"renderOrder": 0, //float
"scale": 1,//the length of the vertical side of the image in physics units
"aspectScale": 1,//the ratio of width to height, relative to the natural dimensions
"angle": 0, //radians
"body": 4, //zero-based index of body in bodies array
"center": (vector), //center position in body local coordinates
"corners": (vector array), //corner positions in body local coordinates
"file": "../images/tire.png", //if relative, from the location of the exported file
"filter": 1, //texture magnification filter, 0 = linear, 1 = nearest
"flip": true, //true if the texture should be reversed horizontally
"colorTint": [127,114,64,255], //RGBA values for color tint, if not 255,255,255,255
"glDrawElements": [],
"glTexCoordPointer": [],
"glVertexPointer": [],
"customProperties": //An array of zero or more custom properties.

*/