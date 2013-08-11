//
//  CMMenuNode.h
//  MarbleGame
//
//  Created by Carsten Müller on 8/10/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//
// creates an transparent full screen layer, fetches all relevant touch and mouse events.

#import "CCLayer.h"
#import "cocos2d.h"
#import "CCControlExtension.h"

@interface CMMenuLayer : CCLayer
{
	CCSprite 					*_backgroundSprite;								///< our background
	NSMutableArray 		*_menuButtons;										///< CCControl*
	CGSize 						_defaultButtonSize;								///< used while adding element with convinience methonds
	CGPoint						_nextFreeMenuPosition;						///< next free position on which an element will be added
	CGFloat						_interElementSpacing;							///< vertical spacing between elements
}

@property (nonatomic, retain) CCSprite* backgroundSprite;
@property (nonatomic, retain) NSMutableArray* menuButtons;
@property (nonatomic, assign) CGSize defaultButtonSize;
@property (nonatomic, assign) CGPoint nextFreeMenuPosition;
@property (nonatomic, assign) CGFloat interElementSpacing;
- (void) addButtonWithTitle:(NSString*) buttonTitle target:(id)target action:(SEL)selector;


@end
