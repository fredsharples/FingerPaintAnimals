//
//  GameImageViewController.h
//  BabyAnimals
//
//  Created by Susan Surapruik on 9/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzView.h"

@interface GameImageView : QuartzView {
	CGContextRef _contextRef;
	CGLayerRef _layerRef;
	
	CGImageRef _image;
	CGImageRef _speckle;
	CGImageRef _paper;
	
	NSString *_imageFileName;
	
	BOOL _showSpeckles;
	
	BOOL _iPhoneDevice;
}

- (void) initializeMe;
- (void) drawFromPoint:(CGPoint)start toPoint:(CGPoint)end;

@property(nonatomic, retain) NSString *_imageFileName;
@property BOOL _showSpeckles;

@end