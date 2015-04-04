//
//  GameViewController.m
//  BabyAnimals
//
//  Created by Susan Surapruik on 9/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameViewController.h"
#import "DrawEAGLView.h"
#import "GameButton.h"

#define kAccelerationThreshold        0.5
#define kUpdateInterval               0.25

@implementation GameViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.userInteractionEnabled = NO;
	
//	_iPhoneDevice = UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad;
	
	_initialized = NO;
	
	_soundIdentifier = [[NSMutableString alloc] init];
	
	_blackButton._r = 0.0;
	_blackButton._g = 0.0;
	_blackButton._b = 0.0;
	_blackButton._vo = @"VO_black";
	
	_blueButton._r = 0.0;
	_blueButton._g = 0.53125;
	_blueButton._b = 1.0;
	_blueButton._vo = @"VO_blue";
	
	_brownButton._r = 0.6640625;
	_brownButton._g = 0.3984375;
	_brownButton._b = 0.1328125;
	_brownButton._vo = @"VO_brown";
	
	_grayButton._r = 0.796875;
	_grayButton._g = 0.796875;
	_grayButton._b = 0.796875;
	_grayButton._vo = @"VO_gray";
	
	_greenButton._r = 0.33203125;
	_greenButton._g = 0.796875;
	_greenButton._b = 0.0;
	_greenButton._vo = @"VO_green";
	
	_orangeButton._r = 1.0;
	_orangeButton._g = 0.53125;
	_orangeButton._b = 0.1328125;
	_orangeButton._vo = @"VO_orange";
	
	_pinkButton._r = 1.0;
	_pinkButton._g = 0.53125;
	_pinkButton._b = 0.796875;
	_pinkButton._vo = @"VO_pink";
	
	_purpleButton._r = 0.6640625;
	_purpleButton._g = 0.33203125;
	_purpleButton._b = 0.6640625;
	_purpleButton._vo = @"VO_purple";
	
	_redButton._r = 0.9296875;
	_redButton._g = 0.19921875;
	_redButton._b = 0.1328125;
	_redButton._vo = @"VO_red";
	
	_whiteButton._r = 1.0;
	_whiteButton._g = 1.0;
	_whiteButton._b = 1.0;
	_whiteButton._vo = @"VO_white";
	
	_yellowButton._r = 1.0;
	_yellowButton._g = 0.796875;
	_yellowButton._b = 0.1328125;
	_yellowButton._vo = @"VO_yellow";
	
	_currentColorButton = _redButton;
	_currentColorButton.selected = YES;
	buttonTouched = _redButton;
	[self changeColor:_currentColorButton];
	
	_saveAnimation.hidden = YES;
/*
	if (_iPhoneDevice) {
		_saveAnimation.animationImages = [NSArray arrayWithObjects:
										  [UIImage imageNamed:@"camera_00.png"],
										  [UIImage imageNamed:@"camera_01.png"],
										  [UIImage imageNamed:@"camera_02.png"],
										  [UIImage imageNamed:@"camera_03.png"],
										  [UIImage imageNamed:@"camera_04.png"],
										  [UIImage imageNamed:@"camera_05.png"],
										  [UIImage imageNamed:@"camera_05.png"],
										  [UIImage imageNamed:@"camera_05.png"],
										  [UIImage imageNamed:@"camera_05.png"],
										  [UIImage imageNamed:@"camera_05.png"],
										  [UIImage imageNamed:@"camera_04.png"],
										  [UIImage imageNamed:@"camera_03.png"],
										  [UIImage imageNamed:@"camera_02.png"],
										  [UIImage imageNamed:@"camera_01.png"],
										  [UIImage imageNamed:@"camera_00.png"], 
										  nil];
	} else {
*/
		_saveAnimation.animationImages = [NSArray arrayWithObjects:
										  [UIImage imageNamed:@"camera_00_iPad.png"],
										  [UIImage imageNamed:@"camera_01_iPad.png"],
										  [UIImage imageNamed:@"camera_02_iPad.png"],
										  [UIImage imageNamed:@"camera_03_iPad.png"],
										  [UIImage imageNamed:@"camera_04_iPad.png"],
										  [UIImage imageNamed:@"camera_05_iPad.png"],
										  [UIImage imageNamed:@"camera_05_iPad.png"],
										  [UIImage imageNamed:@"camera_05_iPad.png"],
										  [UIImage imageNamed:@"camera_05_iPad.png"],
										  [UIImage imageNamed:@"camera_05_iPad.png"],
										  [UIImage imageNamed:@"camera_04_iPad.png"],
										  [UIImage imageNamed:@"camera_03_iPad.png"],
										  [UIImage imageNamed:@"camera_02_iPad.png"],
										  [UIImage imageNamed:@"camera_01_iPad.png"],
										  [UIImage imageNamed:@"camera_00_iPad.png"],
										  nil];
//	}
	
	_saveAnimation.animationDuration = 1.0;
	_saveAnimation.animationRepeatCount = 1;
	
	_clearAnimation.hidden = YES;
/*
	if (_iPhoneDevice) {
		_clearAnimation.animationImages = [NSArray arrayWithObjects:
										   [UIImage imageNamed:@"garbage_00.png"],
										   [UIImage imageNamed:@"garbage_01.png"],
										   [UIImage imageNamed:@"garbage_02.png"],
										   [UIImage imageNamed:@"garbage_03.png"],
										   [UIImage imageNamed:@"garbage_04.png"],
										   [UIImage imageNamed:@"garbage_05.png"],
										   [UIImage imageNamed:@"garbage_00.png"],
										   nil];
	} else {
*/
		_clearAnimation.animationImages = [NSArray arrayWithObjects:
										   [UIImage imageNamed:@"garbage_00_iPad.png"],
										   [UIImage imageNamed:@"garbage_01_iPad.png"],
										   [UIImage imageNamed:@"garbage_02_iPad.png"],
										   [UIImage imageNamed:@"garbage_03_iPad.png"],
										   [UIImage imageNamed:@"garbage_04_iPad.png"],
										   [UIImage imageNamed:@"garbage_05_iPad.png"],
										   [UIImage imageNamed:@"garbage_00_iPad.png"],
										   nil];
//	}
	_clearAnimation.animationDuration = 0.5;
	_clearAnimation.animationRepeatCount = 1;


	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shakeStartNotification) name:@"shakeStart" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shakeEndNotification) name:@"shakeEnd" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryResponseSoundNotification:) name:kQueryResponseSoundNotification object:nil];

	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startGame) name:@"EAGLEViewLoaded" object:nil];
	
	
	
	_initialized = YES;
	
	//[self startGame];
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
*/
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
	[self invalidateTimer];
	
	[_levelData release];
	[_levels release];
	
	// NEED TO DO MORE THAN JUST THIS
	[_animationDataTable release];
	
	[_backwardNav release];
	[_forwardNav release];
	[_clearButton release];
	[_saveButton release];
	
	[_clearAnimation release];
	[_saveAnimation release];
	
	[_blackButton release];
	[_blueButton release];
	[_brownButton release];
	[_grayButton release];
	[_greenButton release];
	[_orangeButton release];
	[_pinkButton release];
	[_purpleButton release];
	[_redButton release];
	[_whiteButton release];
	[_yellowButton release];
	
	[_eraseConfirmView release];
	
	[_gameDrawView release];
	
	[_soundIdentifier release];
	[_type release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Animations

- (void) initializeViewAnimation {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kViewFadeTime];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(viewVisible)];
	self.view.alpha = 1.0;
	[UIView commitAnimations];
}

- (void) viewVisible {
	self.view.userInteractionEnabled = YES;

	[self playSoundIdentifier];
}

- (void) crossFade:(unsigned)forward {
	[self invalidateTimer];
	
	self.view.userInteractionEnabled = NO;
	
	[self saveLevelAnimationData];

	if (forward) {
		if (_levelNum + 1 < [_levels count]) {
			[self setLevelNum:_levelNum + 1];
		} else {
			[self setLevelNum:0];
		}
	} else {
		int newLevel = _levelNum - 1;
		if (newLevel < 0) {
			[self setLevelNum:[_levels count] - 1];
		} else {
			[self setLevelNum:newLevel];
		}
	}
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kViewFadeTime];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(viewFadedIn)];
	
	[self updateImage:_gameDrawView forType:_type];
	
	if (forward) {
		[UIView setAnimationTransition:(UIViewAnimationTransitionCurlUp) forView:_gameDrawView cache:YES];
	} else {
		[UIView setAnimationTransition:(UIViewAnimationTransitionCurlDown) forView:_gameDrawView cache:YES];
	}
	
	[UIView commitAnimations];
	
	[NSTimer scheduledTimerWithTimeInterval:(kViewFadeTime/2.0) target:self selector:@selector(playLevelSound) userInfo:nil repeats:NO];
}

- (void) viewFadedIn {
	[self drawSavedAnimation];
	
	[self playSoundIdentifier];

	self.view.userInteractionEnabled = YES;
}

- (void) shakeStartNotification {
	_shaking = YES;

	if (!_animationStarted && [_type length] > 0) {
		self.view.userInteractionEnabled = NO;

		//[self startAnimationSequence];
		[self checkSoundPlaying];
	}
}

- (void) shakeEndNotification {
	_shaking = NO;
}

- (void) startAnimationSequence {
	[_soundIdentifier setString:[NSString stringWithFormat:@"SFX_%@", _type]];
	
	NSDictionary *soundInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							   _soundIdentifier, kNotificationSoundIdentifier,
							   [NSNumber numberWithBool:YES], kNotificationSoundRestart,
							   nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:kPlaySoundNotification object:self userInfo:soundInfo];
	
	[self startAnimationTimer];
}

- (void) startAnimationTimer {
	[self invalidateTimer];
	
	if (_currentAnimation == 1 && _animating) {
		_animating = NO;
		_animationStarted = NO;
		/*
		if (_shaking) {
			[self startAnimationSequence];
		} else {
			self.view.userInteractionEnabled = YES;
		}
		*/
		//[self checkSoundPlaying];
		self.view.userInteractionEnabled = YES;

	} else {
		_animationStarted = YES;
		_timer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / kAnimationRenderingFPS) target:self selector:@selector(updateAnimationImage) userInfo:nil repeats:NO];
	}
}

- (void) checkSoundPlaying {
	NSDictionary *soundInfo = [NSDictionary dictionaryWithObject:_soundIdentifier forKey:kNotificationSoundIdentifier];
	[[NSNotificationCenter defaultCenter] postNotificationName:kQuerySoundNotification object:self userInfo:soundInfo];
}

- (void) queryResponseSoundNotification:(NSNotification*)notificationObject {
	[self invalidateTimer];
	
	NSDictionary *userInfo = [notificationObject userInfo];
	BOOL soundPlaying = [[userInfo objectForKey:kNotificationSoundPlaying] boolValue];

//	if (_shaking) {
		if (soundPlaying) {
			_timer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / kAnimationRenderingFPS) target:self selector:@selector(checkSoundPlaying) userInfo:nil repeats:NO];
		} else {
			[self startAnimationSequence];
		}
//	} else {
//		self.view.userInteractionEnabled = YES;
//	}
}

#pragma mark -
#pragma mark Update Image

- (void) updateImage:(DrawEAGLView*)gameImageView forType:(NSString*)type {
	gameImageView._imageFileName = [NSString stringWithFormat:@"screen_%@_drawing_01", type];
	
	[self createSavedPreviewImageData];
	
	gameImageView._paperView.hidden = _hidePaperForTransition;
}

- (void) updateAnimationImage {
	_animating = YES;
	_currentAnimation++;
	
	if (_currentAnimation > [_levelData count] - 1) {
		_currentAnimation = 1;
	}
	
	NSString *imageName = [NSString stringWithFormat:@"screen_%@_drawing_0%d", _type, [[_levelData objectAtIndex:_currentAnimation] intValue]];

	_gameDrawView._imageFileName = imageName;
		
	[self startAnimationTimer];
}

#pragma mark -
#pragma mark StartGame
- (void) startGame {
	self.view.alpha = 0.0;

	[self updateImage:_gameDrawView forType:_type];
	[self drawSavedAnimation];
	
	[self initializeViewAnimation];
	
	NSDictionary *soundLoopInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								   @"MUSIC_intro", kNotificationSoundIdentifier,
								   [NSNumber numberWithBool:YES], kNotificationSoundLoop,
								   nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:kSetSoundLoopNotification object:self userInfo:soundLoopInfo];
	
	
	NSDictionary *fadeSoundInfo = [NSDictionary dictionaryWithObject:@"MUSIC_intro" forKey:kNotificationSoundIdentifier];
	[[NSNotificationCenter defaultCenter] postNotificationName:kFadeSoundInNotification object:self userInfo:fadeSoundInfo];
}

- (void) updateImage:(unsigned)forward {
	[self invalidateTimer];
	if ([_soundIdentifier length] > 0) {
		NSDictionary *soundInfo = [NSDictionary dictionaryWithObject:_soundIdentifier forKey:kNotificationSoundIdentifier];
		[[NSNotificationCenter defaultCenter] postNotificationName:kStopSoundNotification object:self userInfo:soundInfo];
	}
	
	[self crossFade:forward];
}

#pragma mark -
#pragma mark Animation Data Record Keeping

- (void) saveLevelAnimationData {
	NSData *_imageData = [_gameDrawView convertImageToData];
	if (_drawn) {
		// point to the datatable for the level
		NSMutableArray *animationData = (NSMutableArray*)[_animationDataTable objectAtIndex:_levelNum];
	
		[animationData removeAllObjects];
	
		[animationData addObject:_imageData];
	}
}

- (void) createSavedPreviewImageData {
	NSMutableArray *animationData = (NSMutableArray*)[_animationDataTable objectAtIndex:_levelNum];
	
	if ([animationData count] > 0) {
		[_gameDrawView createSavedPreviewImageData:[animationData objectAtIndex:0]];
		_hidePaperForTransition = NO;
	} else {
		[_gameDrawView createClearPreviewImageData];
		_hidePaperForTransition = YES;
	}
}

- (void) drawSavedAnimation {
	_gameDrawView._previousDrawnImage.hidden = YES;
	_gameDrawView._paperView.hidden = NO;
	
	[_gameDrawView clearDrawnPoints];
	
	NSMutableArray *animationData = (NSMutableArray*)[_animationDataTable objectAtIndex:_levelNum];
	
	if ([animationData count] > 0) {
		[_gameDrawView drawSavedImageData:[animationData objectAtIndex:0]];
	}
}

#pragma mark -
#pragma mark Sound

- (void) playSoundIdentifier {
	if ([_type length] == 0) {
		[_soundIdentifier setString:[NSString stringWithString:kBlankPageAudio]];
	} else {
		[_soundIdentifier setString:[NSString stringWithFormat:@"VO_%@", _type]];	
	}
	
	NSDictionary *soundInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							   _soundIdentifier, kNotificationSoundIdentifier,
							   [NSNumber numberWithBool:YES], kNotificationSoundRestart,
							   nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:kPlaySoundNotification object:self userInfo:soundInfo];
}

- (void) playLevelSound {
	NSDictionary *soundInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							   kNewLevelAudio, kNotificationSoundIdentifier,
							   [NSNumber numberWithBool:YES], kNotificationSoundRestart,
							   nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:kPlaySoundNotification object:self userInfo:soundInfo];
}

- (void) playScreenSound {
	NSDictionary *soundInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							   kNewScreenAudio, kNotificationSoundIdentifier,
							   [NSNumber numberWithBool:YES], kNotificationSoundRestart,
							   nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:kPlaySoundNotification object:self userInfo:soundInfo];
}

#pragma mark -
#pragma mark Invalidate Timer

- (void) invalidateTimer {
	if (_timer) {
		[_timer invalidate];
		_timer = nil;
	}
}

#pragma mark -
#pragma mark Touches

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	unsigned i;
	if (!_animating && ![_eraseConfirmView superview]) {
		for (i = 0; i < [touches count]; i++) {
			//UITouch *touch = [touches anyObject];
			UITouch *touch = [[touches allObjects] objectAtIndex:i];
			CGPoint location = [touch locationInView:self.view];
			location = CGPointMake(location.x, self.view.bounds.size.height - location.y);
			CGPoint prevLocation = [touch previousLocationInView:self.view];
			prevLocation = CGPointMake(prevLocation.x, self.view.bounds.size.height - prevLocation.y);
			
			_drawn = YES;
			
			[_gameDrawView drawFromPoint:prevLocation toPoint:location];
		}
	}
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	unsigned i;
	if (!_animating) {
		for (i = 0; i < [touches count]; i++) {
			//UITouch *touch = [touches anyObject];
			UITouch *touch = [[touches allObjects] objectAtIndex:i];
			NSUInteger numTaps = [touch tapCount];
			
			if (numTaps < 2) {
				[self touchesMoved:touches withEvent:event];
			}
		}
	}
}

#pragma mark -
#pragma mark Button Actions

- (IBAction) touchDown:(id)sender {
	buttonTouched = sender;
}

- (IBAction) flipForward:(id)sender {
	if (buttonTouched == sender) {
		self.view.userInteractionEnabled = NO;
		
		NSDictionary *soundInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								   kClickAudio, kNotificationSoundIdentifier,
								   [NSNumber numberWithBool:YES], kNotificationSoundRestart,
								   [NSNumber numberWithFloat:kClickVolume], kNotificationSoundVolume,
								   nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:kPlaySoundNotification object:self userInfo:soundInfo];
		
		[self updateImage:YES];
	}
}

- (IBAction) flipBackward:(id)sender {
	if (buttonTouched == sender) {
		self.view.userInteractionEnabled = NO;
		
		NSDictionary *soundInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								   kClickAudio, kNotificationSoundIdentifier,
								   [NSNumber numberWithBool:YES], kNotificationSoundRestart,
								   [NSNumber numberWithFloat:kClickVolume], kNotificationSoundVolume,
								   nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:kPlaySoundNotification object:self userInfo:soundInfo];
		
		[self updateImage:NO];
	}
}

- (IBAction) saveImage:(id)sender {
	if (buttonTouched == sender) {
		self.view.userInteractionEnabled = NO;
		
		NSDictionary *soundInfo0 = [NSDictionary dictionaryWithObjectsAndKeys:
								   kClickAudio, kNotificationSoundIdentifier,
								   [NSNumber numberWithBool:YES], kNotificationSoundRestart,
								   [NSNumber numberWithFloat:kClickVolume], kNotificationSoundVolume,
								   nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:kPlaySoundNotification object:self userInfo:soundInfo0];
		
		[_soundIdentifier setString:[NSString stringWithString:kCameraAudio]];

		NSDictionary *soundInfo1 = [NSDictionary dictionaryWithObjectsAndKeys:
								   _soundIdentifier, kNotificationSoundIdentifier,
								   [NSNumber numberWithBool:YES], kNotificationSoundRestart,
								   nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:kPlaySoundNotification object:self userInfo:soundInfo1];
		
		_saveButton.hidden = YES;
		_saveAnimation.hidden = NO;
		[_saveAnimation startAnimating];
	
		[self invalidateTimer];
		_timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(saveImageFinished) userInfo:nil repeats:NO];
	
		[_gameDrawView saveToPhotoLibrary];
	}
}

- (IBAction) changeColor:(id)sender {
	if (buttonTouched == sender) {
		if (_currentColorButton) {
			_currentColorButton.selected = NO;
		}
	
		_currentColorButton = (GameButton*)sender;
		_currentColorButton.selected = YES;
		[_gameDrawView changeLineColorR:_currentColorButton._r G:_currentColorButton._g B:_currentColorButton._b];
	
		if (_initialized) {
			NSDictionary *soundInfo0 = [NSDictionary dictionaryWithObjectsAndKeys:
									   kClickAudio, kNotificationSoundIdentifier,
									   [NSNumber numberWithBool:YES], kNotificationSoundRestart,
									   [NSNumber numberWithFloat:kClickVolume], kNotificationSoundVolume,
									   nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:kPlaySoundNotification object:self userInfo:soundInfo0];
			
			[_soundIdentifier setString:[NSString stringWithString:_currentColorButton._vo]];
			
			NSDictionary *soundInfo1 = [NSDictionary dictionaryWithObjectsAndKeys:
									   _soundIdentifier, kNotificationSoundIdentifier,
									   [NSNumber numberWithBool:YES], kNotificationSoundRestart,
									   nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:kPlaySoundNotification object:self userInfo:soundInfo1];
		}
	}
}

- (IBAction) clearImageSelected:(id)sender {
	if (buttonTouched == sender) {
		NSDictionary *soundInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								   kClickAudio, kNotificationSoundIdentifier,
								   [NSNumber numberWithBool:YES], kNotificationSoundRestart,
								   [NSNumber numberWithFloat:kClickVolume], kNotificationSoundVolume,
								   nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:kPlaySoundNotification object:self userInfo:soundInfo];
		
		[self.view addSubview:_eraseConfirmView];
	}
}

- (IBAction) clearImage:(id)sender {
	if (buttonTouched == sender) {
		self.view.userInteractionEnabled = NO;
		
		[self removeEraseConfirm];
	
		NSDictionary *soundInfo0 = [NSDictionary dictionaryWithObjectsAndKeys:
								   kClickAudio, kNotificationSoundIdentifier,
								   [NSNumber numberWithBool:YES], kNotificationSoundRestart,
								   [NSNumber numberWithFloat:kClickVolume], kNotificationSoundVolume,
								   nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:kPlaySoundNotification object:self userInfo:soundInfo0];
		
		[_soundIdentifier setString:[NSString stringWithString:kTrashAudio]];

		NSDictionary *soundInfo1 = [NSDictionary dictionaryWithObjectsAndKeys:
								   _soundIdentifier, kNotificationSoundIdentifier,
								   [NSNumber numberWithBool:YES], kNotificationSoundRestart,
								   nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:kPlaySoundNotification object:self userInfo:soundInfo1];
	
		NSMutableArray *animationData = (NSMutableArray*)[_animationDataTable objectAtIndex:_levelNum];
		[animationData removeAllObjects];
		
		_clearButton.hidden = YES;
		_clearAnimation.hidden = NO;
		[_clearAnimation startAnimating];
	
		[self invalidateTimer];
		_timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(clearImageFinished) userInfo:nil repeats:NO];
	
		[_gameDrawView clearDrawnPoints];
		_drawn = NO;
	}
}

- (IBAction) clearImageDenied:(id)sender {
	if (buttonTouched == sender) {
		NSDictionary *soundInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								   kClickAudio, kNotificationSoundIdentifier,
								   [NSNumber numberWithBool:YES], kNotificationSoundRestart,
								   [NSNumber numberWithFloat:kClickVolume], kNotificationSoundVolume,
								   nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:kPlaySoundNotification object:self userInfo:soundInfo];
		
		[self removeEraseConfirm];
	}
}

- (void) saveImageFinished {
	_timer = nil;
	_saveButton.hidden = NO;
	_saveAnimation.hidden = YES;
	self.view.userInteractionEnabled = YES;
}

- (void) clearImageFinished {
	_timer = nil;
	_clearButton.hidden = NO;
	_clearAnimation.hidden = YES;
	self.view.userInteractionEnabled = YES;
}

- (void) removeEraseConfirm {
	[_eraseConfirmView removeFromSuperview];
}

#pragma mark -
#pragma mark Accessors

- (unsigned) levelNum {
	return _levelNum;
}
- (void) setLevelNum:(unsigned)newLevelNum {
	_animationStarted = NO;
	_animating = NO;
	_currentAnimation = 1;
	
	_levelNum = newLevelNum;
	_levelData = [_levels objectAtIndex:_levelNum];
	
	_drawn = NO;
	
	[_type release];
	_type = [[NSString alloc] initWithString:[_levelData objectAtIndex:0]];
}

- (NSArray*) _levels {
	return _levels;
}
- (void) set_levels:(NSArray*)newLevels {
	_levels = [[NSArray alloc] initWithArray:newLevels];
}

- (NSMutableArray*) _animationDataTable {
	return _animationDataTable;
}
- (void) set_animationDataTable:(NSMutableArray*)newAnimationDataTable {
	int i;
	NSMutableArray *animationData;
	
	_animationDataTable = [[NSMutableArray alloc] init];
	for (i = 0; i < [newAnimationDataTable count]; i++) {
		animationData = [[NSMutableArray alloc] init];
		[animationData addObjectsFromArray:[newAnimationDataTable objectAtIndex:i]];
		[_animationDataTable addObject:animationData];
		[animationData release];
	}
}

@end