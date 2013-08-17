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

@interface CMMenuLayer : CCLayerColor
{
	CCSprite 					*_backgroundSprite;								///< our background
	NSMutableArray 		*_menuButtons;										///< CCControl*
	CGSize 						_defaultButtonSize;								///< used while adding element with convinience methonds
	CGPoint						_nextFreeMenuPosition;						///< next free position on which an element will be added
	CGFloat						_interElementSpacing;							///< vertical spacing between elements
	NSString					*_menuLabel;											///< name of the Menu
	CGSize						_currentMaxSize;
	CGFloat						_interColumnSpacing;							///< spacing between columns if nodes are added with two column
}

@property (nonatomic, retain) CCSprite* backgroundSprite;
@property (nonatomic, retain) NSMutableArray* menuButtons;
@property (nonatomic, assign) CGSize defaultButtonSize;
@property (nonatomic, assign) CGPoint nextFreeMenuPosition;
@property (nonatomic, assign) CGFloat interElementSpacing;
@property (nonatomic, retain) NSString* menuLabel;
@property (nonatomic, assign) CGSize currentMaxSize;
@property (nonatomic, assign) CGFloat interColumnSpacing;

+ (id) menuLayerWithLabel:(NSString*)menuLabel;

- (id) initWithLabel:(NSString*) menuLabel;

- (CCControlButton*) addButtonWithTitle:(NSString*) buttonTitle target:(id)target action:(SEL)selector;
- (void) addNode:(CCNode*) aNode;
- (void) addNode:(CCNode*) aNode z:(NSInteger) zLayer;

- (void) addLeftNode:(CCNode*) lNode right:(CCNode*)rNode;

@end
