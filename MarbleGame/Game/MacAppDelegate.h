//
//  AppDelegate.h
//  CocosTest1
//
//  Created by Carsten Müller on 6/28/13.
//  Copyright Carsten Müller 2013. All rights reserved.
//


#import "cocos2d.h"

#import "MacAppDelegate.h"

@class CMMarbleLevelSet;

@interface MarbleGameAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	CCGLView	*glView_;

  
  CMMarbleLevelSet* _levelSet;
  NSArray           *_marbleSets;
}

@property (nonatomic, assign) IBOutlet NSWindow	*window;
@property (nonatomic, assign) IBOutlet CCGLView	*glView;

@property (nonatomic, retain) CMMarbleLevelSet* levelSet;
@property (nonatomic, retain) NSArray *marbleSets;

- (IBAction)toggleFullScreen:(id)sender;


@end
