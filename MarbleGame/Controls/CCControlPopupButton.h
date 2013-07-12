//
//  CCControlPopupButton.h
//  ChipDonkey
//
//  Created by Carsten Müller on 7/3/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CCControlButton.h"
#import "cocos2d.h"

@interface CCControlPopupButton : CCControlButton

@property (nonatomic,retain) NSArray* labels; ///< a list of CCLabel elements
@property (nonatomic,retain) CCScale9Sprite* popupBackgroundSprite; ///< a background sprite for the popup
@property (nonatomic,assign) NSUInteger selectedIndex; ///< selected index of the Button
@property (nonatomic,assign) CCNode<CCLabelProtocol,CCRGBAProtocol> *selectedLabel;

@end
