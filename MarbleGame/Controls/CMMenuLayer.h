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
#import "CMEventEatingLayer.h"
#import "CCControlExtension.h"

@interface CMMenuLayer : CMEventEatingLayer

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
