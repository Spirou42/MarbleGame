//
//  StartScene.h
//  CocosTest1
//
//  Created by Carsten Müller on 6/29/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "CCScene.h"

@interface CMMarbleMainMenuScene : CCScene
{
	@protected
	CCNode <CCLabelProtocol,CCRGBAProtocol>*		_playerName;
}
@property (nonatomic, retain) CCNode<CCLabelProtocol,CCRGBAProtocol> *playerName;

@end
