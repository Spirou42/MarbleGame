//
//  CMSoundPolyShape.h
//  MarbleGame
//
//  Created by Carsten Müller on 9/11/13.
//  Copyright (c) 2013 Carsten Müller. All rights reserved.
//

#import "ChipmunkShape.h"
#import "CMObjectSoundProtocol.h"

@interface CMSoundCircleShape : ChipmunkCircleShape <CMObjectSoundProtocol>

@end

@interface CMSoundSegmentShape : ChipmunkSegmentShape <CMObjectSoundProtocol>

@end

@interface CMSoundPolyShape : ChipmunkPolyShape <CMObjectSoundProtocol>

@end
