//
//  FingerPaintAnimalsAppDelegate.h
//  FingerPaintAnimals
//
//  Created by Orange Design on 3/24/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import "Constants.h"

@class OpenALPlayer;
@class GameWindow;
@class ViewController;
@class GameViewController;

@interface FingerPaintAnimalsAppDelegate : NSObject <UIApplicationDelegate> {
    IBOutlet GameWindow *window;
	
	IBOutlet UIView *_mainView;
	ViewController *_viewController;
	GameViewController *_gameViewController;
	
	IBOutlet UIImageView *_paperImageView;
	
	NSMutableDictionary *_saveData;
	
	OpenALPlayer *_openALPlayer;
	
	BOOL _pause;
	CFTimeInterval _pauseTime;
	
	NSTimer *_timer;
	
	GameState _state;
	
	unsigned _levelNum;
	NSMutableArray *_animationData;
	
	BOOL _rotating;
	UIInterfaceOrientation _interfaceOrientation;
}

- (void) checkRotation;

- (void) createSaveData;

- (void) resetGame:(unsigned)levelNum;

- (void) changeState:(unsigned)state;

@property (nonatomic, retain) IBOutlet GameWindow *window;
@property (nonatomic, retain) OpenALPlayer *_openALPlayer;

@end



