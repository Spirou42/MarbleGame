//
//  CMRubeImage.h
//  MarbleGame
//
//  Created by Carsten Müller on 8/19/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kRubeImageType_Background = 0,
	kRubeImageType_Overlay = 1
} CMRubeImageType;

@interface CMRubeImage : NSObject

@property (nonatomic,assign) CMRubeImageType type;
@property (nonatomic,retain) NSString* name;



@end
