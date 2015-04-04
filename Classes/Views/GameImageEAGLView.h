//
//  GameImageEAGLView.h
//  BabyAnimals
//
//  Created by Susan Surapruik on 9/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyEAGLView.h"
#import "Constants.h"

@interface GameImageEAGLView : MyEAGLView {
	Texture2D *_image;
	Texture2D *_speckle;
	Texture2D *_paper;
	
	BOOL _firstDraw;
	NSString *_imageFileName;
	
	BOOL _showSpeckles;
	
	BOOL _iPhoneDevice;
}

- (void) initializeView;
- (void) drawView;

@property(nonatomic, retain) NSString *_imageFileName;
@property BOOL _showSpeckles;

@end
