//
//  ViewController.h
//  MadrigalChallenge
//
//  Created by Susan Surapruik on 7/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
	NSTimer *_timer;
	BOOL _timerPaused;
	CFTimeInterval _startTime;
	int _pauseTime;
	
	NSString *_backgroundImageName;
	
	BOOL _iPhoneDevice;
}

- (void) setLevelData:(NSArray*)newLevelData;
- (void) initializeView;
- (void) createViewBackground;
- (void) initializeViewAnimation;
- (void) viewVisible;
- (void) arrangeViewForLevel:(int)levelNum;
- (void) fadeView;
- (void) removeView;
- (void) pause:(BOOL)flag;
- (void) invalidateTimer;
- (UIButton*) createButtonWithImage:(NSString*)imageName x:(float)x y:(float)y;

@end