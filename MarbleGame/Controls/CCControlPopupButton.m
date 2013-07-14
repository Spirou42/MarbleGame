//
//  CCControlPopupButton.m
//  ChipDonkey
//
//  Created by Carsten Müller on 7/3/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CCControlPopupButton.h"
#import "cocos2d.h"
#import "CCControlExtension.h"

@implementation CCControlPopupButton
@synthesize labels, popupBackgroundSprite, selectedIndex,selectedLabel;

- (void) menuItemSelected:(CCControlButton*)sender
{
  CCNode* k = [self getChildByTag:10];
  for (CCControlButton *c in k.children) {
    if ([c isKindOfClass:[CCControlButton class]]) {
      if (c == sender) {
        c.selected =YES;
        [c setTitleColor:SELECTED_BUTTON_TITLE_COLOR forState:CCControlStateNormal];
        CCLabelTTF* label = (CCLabelTTF*)c.titleLabel;
        [self setTitle:label.string forState:CCControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setObject:label.string forKey:@"MarbleSet"];
				
      }else{
        c.selected=NO;
        [c setTitleColor:DEFAULT_BUTTON_TITLE_COLOR forState:CCControlStateNormal];
      }
    }
  }
  k.visible=NO;
}

- (void) popupPressed:(CCNode*) sender
{
  CCNode* c = [self getChildByTag:10];
  if ([c isKindOfClass:[CCScale9Sprite class]]) {
    c.visible=!c.visible;
  }
}

/// returns a button with a skin for the popupButtonLabel optionaly it is selected (image is set to checkmark)
- (CCControlButton*) popupItemButtonWithTitle:(NSString*)label selected:(BOOL) selected
{
  CCScale9Sprite *menuItemBackgroundNormal=nil;
#if !USE_DEFAULT_BUTTON_FOR_MENU
  menuItemBackgroundNormal = [[CCScale9Sprite new]autorelease];
	//  menuItemBackgroundHighlighted = [[CCScale9Sprite new]autorelease];
#else
  menuItemBackgroundNormal = [CCScale9Sprite spriteWithSpriteFrameName:DEFAULT_DDMENUITM_BACKGROUND capInsets:DDMENUITM_BACKGROUND_CAPS];
	//  menuItemBackgroundHighlighted =[CCScale9Sprite spriteWithSpriteFrameName:backgroundHighlightedName capInsets:backgroundCaps];
#endif
  
	
  
  CCControlButton *result = [CCControlButton buttonWithBackgroundSprite:menuItemBackgroundNormal];
	//  [result setBackgroundSprite:menuItemBackgroundHighlighted forState:CCControlStateHighlighted];
  result.zoomOnTouchDown=NO;
  result.labelAnchorPoint = ccp(0.5 ,0.5);
  result.marginLR=20;
  result.anchorPoint=ccp(0, 0);
  result.selected = selected;
  
  // CCLabelTTF      *ttfLabel = [CCLabelTTF labelWithString:label fontName:DEFAULT_BUTTON_FONT fontSize:DEFAULT_BUTTON_FONT_SIZE];
  CCLabelTTF *ttfLabel = [CCLabelTTF labelWithString:label
                                            fontName:DEFAULT_BUTTON_FONT
                                            fontSize:DEFAULT_BUTTON_FONT_SIZE
                                          dimensions:DEFAULT_MENU_TITLESIZE
                                          hAlignment:kCCTextAlignmentLeft
                                          vAlignment:kCCVerticalTextAlignmentCenter];
	
  [result setTitleLabel:ttfLabel forState:CCControlStateNormal];
	
  if (result.selected) {
    [result setTitleColor:SELECTED_BUTTON_TITLE_COLOR forState:CCControlStateNormal];
  }else{
    [result setTitleColor:DEFAULT_BUTTON_TITLE_COLOR forState:CCControlStateNormal];
  }
	
  [result addTarget:self action:@selector(menuItemSelected:) forControlEvents:CCControlEventTouchUpInside];
	
  [result needsLayout ];
  return result;
}


- (CCControlButton*) popupWithLabels:(NSArray*)labels selected:(NSUInteger) selectedIndex
{
  CCScale9Sprite * backgroundSprite = [CCScale9Sprite spriteWithSpriteFrameName:DEFAULT_DDMENU_BACKGROUND capInsets:DDMENU_BACKGROUND_CAPS];
  CGPoint currentPosition = ccp(0, 0);
  CCNode<CCLabelProtocol,CCRGBAProtocol> *buttonLabel = nil;
  CGSize maxButtonSize = CGSizeMake(0, 0);
  for (NSInteger index =[labels count]-1; index>=0; index--) {
    BOOL isSelected = index == selectedIndex;
    
    CCControlButton *currentButton = [self popupItemButtonWithTitle:[labels objectAtIndex:index] selected:isSelected];
    
    if (isSelected) {
      if ([currentButton.titleLabel isKindOfClass:[CCLabelTTF class]]) {
        CCLabelTTF* k = (CCLabelTTF*)currentButton.titleLabel;
        buttonLabel = [CCLabelTTF labelWithString:k.string fontName:k.fontName fontSize:k.fontSize];
      }
    }
    
    [backgroundSprite addChild:currentButton];
    currentButton.position = currentPosition;
    
    
    if (maxButtonSize.width<currentButton.contentSize.width) {
      maxButtonSize.width=currentButton.contentSize.width;
    }
    if (maxButtonSize.height<currentButton.contentSize.height) {
      maxButtonSize.height=currentButton.contentSize.height;
    }
    currentPosition.y +=currentButton.contentSize.height;
  }
  CGSize menuSize=CGSizeMake(maxButtonSize.width+2, currentPosition.y+2);
  for (CCControlButton* button in backgroundSprite.children) {
		
    if ([button isKindOfClass:[CCControlButton class]]) {
      CGPoint pos = button.position;
      pos.x+=1;
      pos.y+=1;
      button.position=pos;
      button.preferredSize =maxButtonSize;
      [button needsLayout];
    }
  }
	
  backgroundSprite.contentSize=menuSize;
  backgroundSprite.tag=10;
  CCScale9Sprite *popupBackground = [CCScale9Sprite spriteWithSpriteFrameName:DEFAULT_DDBUTTON_BACKGROUND capInsets:DDBUTTON_BACKGROUND_CAPS];
  CCControlButton *popB = [CCControlButton buttonWithLabel:buttonLabel backgroundSprite:popupBackground];
  popB.marginLR=20;
  [popB addTarget:self action:@selector(popupPressed:) forControlEvents:CCControlEventTouchUpInside];
  
  popB.labelAnchorPoint=ccp(.7, .5);
  popB.preferredSize=maxButtonSize;
  [popB addChild:backgroundSprite];
  backgroundSprite.position = ccp(backgroundSprite.contentSize.width/2.0, -backgroundSprite.contentSize.height/2.0);
  popB.zoomOnTouchDown=NO;
  backgroundSprite.visible=NO;
  popB.preferredSize=CGSizeMake(150, 40);
  
  
  // initialize ArrowLabel
  CCSprite *arrowSprite = [CCSprite spriteWithSpriteFrameName:DEFAULT_DDBUTTON_GLYPH];
  arrowSprite.anchorPoint=ccp(0.5, 0.5);
  CGSize buttonSize = popB.contentSize;
  
  arrowSprite.position=ccp(buttonSize.width - arrowSprite.contentSize.width*1.5,buttonSize.height/2.0);
  [popB addChild:arrowSprite];
	return popB;
}

@end
