//
//  TitleViewController.m
//  MadrigalChallenge
//
//  Created by Susan Surapruik on 7/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TitleViewController.h"
#import "GameImageEAGLView.h"

@implementation TitleViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	_gameImageEAGLView0._imageFileName = @"screen_splash_01";
	
	self.view.userInteractionEnabled = NO;
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
}


- (void)dealloc {
    [super dealloc];
}

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

	NSDictionary *soundInfo = @{kNotificationSoundIdentifier: kTitleAudio,
								   kNotificationSoundRestart: @YES};
	[[NSNotificationCenter defaultCenter] postNotificationName:kPlaySoundNotification object:self userInfo:soundInfo];
	
	[self startAnimationTimer];
}


// A tap starts game play
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	NSDictionary *soundInfo = @{kNotificationSoundIdentifier: kTitleAudio};
	[[NSNotificationCenter defaultCenter] postNotificationName:kStopSoundNotification object:self userInfo:soundInfo];
	
	NSDictionary *fadeSoundInfo = @{kNotificationSoundIdentifier: @"MUSIC_intro"};
	[[NSNotificationCenter defaultCenter] postNotificationName:kFadeSoundOutNotification object:self userInfo:fadeSoundInfo];
	
	[self fadeView];
}

- (void) removeView {
	NSDictionary *userInfo = @{kNotificationKey: [NSNumber numberWithUnsignedInt:kGameState_Game]};
	[[NSNotificationCenter defaultCenter] postNotificationName:kChangeStateNotification object:self userInfo:userInfo];
}

- (void) fadeView {
	self.view.userInteractionEnabled = NO;
	
	[self invalidateTimer];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeView)];
	self.view.alpha = 0.0;
	[UIView commitAnimations];
}

- (void) startAnimationTimer {
	_timer = nil;
	if (_currentAnimation == 1 && _animationStarted) {
		CGFloat iRandomTime = 5.0 + arc4random() % 5;
		_timer = [NSTimer scheduledTimerWithTimeInterval:iRandomTime target:self selector:@selector(updateAnimationImage) userInfo:nil repeats:NO];
	} else {
		_animationStarted = YES;
		_timer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / kRenderingFPS) target:self selector:@selector(updateAnimationImage) userInfo:nil repeats:NO];
	}
}

- (void) invalidateTimer {
	if (_timer) {
		[_timer invalidate];
		_timer = nil;
	}
}

- (void) updateAnimationImage {
	_currentAnimation++;
	
	if (_currentAnimation > [_levelData count] - 1) {
		_currentAnimation = 1;
	}
	
	NSString *imageName = [NSString stringWithFormat:@"screen_%@_0%d", _type, [_levelData[_currentAnimation] intValue]];
	
	_gameImageEAGLView0._imageFileName = imageName;
	[self startAnimationTimer];
}

- (void) setLevelData:(NSArray*)newLevelData {
	_levelData = [[NSArray alloc] initWithArray:newLevelData];
	
	_animationStarted = NO;
	_currentAnimation = 1;

	_type = [[NSString alloc] initWithString:_levelData[0]];
		
	[self initializeViewAnimation];
	
	NSDictionary *soundLoopInfo = @{kNotificationSoundIdentifier: @"MUSIC_intro",
								   kNotificationSoundLoop: @YES};
	[[NSNotificationCenter defaultCenter] postNotificationName:kSetSoundLoopNotification object:self userInfo:soundLoopInfo];

	
	NSDictionary *fadeSoundInInfo = @{kNotificationSoundIdentifier: @"MUSIC_intro"};
	[[NSNotificationCenter defaultCenter] postNotificationName:kFadeSoundInNotification object:self userInfo:fadeSoundInInfo];
}

@end