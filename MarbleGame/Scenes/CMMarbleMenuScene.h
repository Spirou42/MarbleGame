//
//  CMMarbleMenuScene.h
//  
//
//  Created by Carsten Müller on 8/12/13.
//
//	Baseclass for all menu like scenes
//	creates Background and overlay. Knows about the current player.


#import "cocos2d.h"

@interface CMMarbleMenuScene : CCScene
{
@protected
	CCNode <CCLabelProtocol,CCRGBAProtocol>*		_playerName;
}
@property (nonatomic, retain) CCNode<CCLabelProtocol,CCRGBAProtocol> *playerName;
@property (nonatomic, readonly) CCSprite* backgroundSprite;
@property (nonatomic, readonly) CCSprite* overlaySprite;
@property (nonatomic, readonly) CGPoint playerLabelPosition;
@end
