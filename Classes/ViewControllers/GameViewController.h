//
//  GameViewController.h
//  BabyAnimals
//
//  Created by Susan Surapruik on 9/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DrawEAGLView;
@class GameButton;

@interface GameViewController : UIViewController {
	IBOutlet DrawEAGLView *_gameDrawView;
	
	IBOutlet UIButton *_backwardNav;
	IBOutlet UIButton *_forwardNav;
	IBOutlet UIButton *_saveButton;
	IBOutlet UIButton *_clearButton;
	
	IBOutlet UIImageView *_saveAnimation;
	IBOutlet UIImageView *_clearAnimation;
	
	IBOutlet GameButton *_blackButton;
	IBOutlet GameButton *_blueButton;
	IBOutlet GameButton *_brownButton;
	IBOutlet GameButton *_grayButton;
	IBOutlet GameButton *_greenButton;
	IBOutlet GameButton *_orangeButton;
	IBOutlet GameButton *_pinkButton;
	IBOutlet GameButton *_purpleButton;
	IBOutlet GameButton *_redButton;
	IBOutlet GameButton *_whiteButton;
	IBOutlet GameButton *_yellowButton;
	
	GameButton *_currentColorButton;
	
	IBOutlet UIView	*_eraseConfirmView;
	
	id buttonTouched;
	
	BOOL _initialized;
	
	NSString *_type;
	unsigned _currentImage;
	BOOL _animationStarted;
	unsigned _currentAnimation;
	BOOL _animating;
	BOOL _shaking;
	
	NSMutableString *_soundIdentifier;
	
	unsigned _levelNum;
	NSArray *_levels;
	NSArray *_levelData;
	
	NSMutableArray *_animationDataTable;
	
	NSTimer *_timer;
	
	BOOL _drawn;
	BOOL _hidePaperForTransition;
	
	BOOL _iPhoneDevice;
}

- (void) startGame;
- (void) updateImage:(unsigned)forward;

- (void) crossFade:(unsigned)forward;
- (void) viewFadedIn;
- (void) updateImage:(DrawEAGLView*)gameImageView forType:(NSString*)type;

- (void) shakeStartNotification;
- (void) shakeEndNotification;
- (void) startAnimationSequence;
- (void) startAnimationTimer;
- (void) updateAnimationImage;

- (void) checkSoundPlaying;

- (void) playSoundIdentifier;

@property (NS_NONATOMIC_IOSONLY) unsigned int levelNum;


- (void) invalidateTimer;

- (void) saveLevelAnimationData;
- (void) createSavedPreviewImageData;
- (void) drawSavedAnimation;

- (void) removeEraseConfirm;

- (IBAction) touchDown:(id)sender;

- (IBAction) flipForward:(id)sender;
- (IBAction) flipBackward:(id)sender;
- (IBAction) saveImage:(id)sender;
- (IBAction) changeColor:(id)sender;

- (IBAction) clearImageSelected:(id)sender;
- (IBAction) clearImage:(id)sender;
- (IBAction) clearImageDenied:(id)sender;

@property (nonatomic, retain) NSArray *_levels;
@property (nonatomic, retain) NSMutableArray *_animationDataTable;

@end