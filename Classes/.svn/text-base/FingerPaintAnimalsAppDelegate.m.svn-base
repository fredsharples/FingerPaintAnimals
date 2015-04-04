//
//  FingerPaintAnimalsAppDelegate.m
//  FingerPaintAnimals
//
//  Created by Orange Design on 3/24/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "FingerPaintAnimalsAppDelegate.h"
#import "OpenALPlayer.h"
#import "LegalViewController.h"
#import "TitleViewController.h"
#import "GameViewController.h"

@implementation FingerPaintAnimalsAppDelegate

@synthesize window;

#pragma mark -
#pragma mark Life Cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	_pause = NO;
	
	_openALPlayer = [[OpenALPlayer alloc] init];
	
	[self createSaveData];
	
	_mainView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
	_mainView.center = CGPointMake(384,512);
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeStateNotification:) name:kChangeStateNotification object:nil];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[self checkRotation];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkRotation) name:UIDeviceOrientationDidChangeNotification object:nil];
	
    [window makeKeyAndVisible];
	
	// Show legal screen
	[self changeState:kGameState_Legal];
    
    return YES;
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	if (_gameViewController) {
		[_gameViewController saveLevelAnimationData];
		
		[_saveData setValue:[NSNumber numberWithInteger:[_gameViewController levelNum]] forKey:@"LevelNum"];
		[_saveData setValue:[NSArray arrayWithArray:[_gameViewController _animationDataTable]] forKey:@"AnimationData"];
	} else {
		[_saveData setValue:[NSNumber numberWithInteger:_levelNum] forKey:@"LevelNum"];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:_saveData forKey:kGameDataKey];
	
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
	[_saveData release];
	
	[_openALPlayer release];
	
	[_paperImageView release];
	
	[_gameViewController release];
	[_viewController release];
	
	[_mainView release];
	
    [window release];
    [super dealloc];
}

#pragma mark -
#pragma mark Rotation

- (void) checkRotation {
	float rotation;
	CGAffineTransform transform;
	UIInterfaceOrientation interfaceOrientation = [UIDevice currentDevice].orientation;
	if (!_rotating && _interfaceOrientation != interfaceOrientation && (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
		if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
			rotation = DEGREES_TO_RADIANS(-90.0);
		} else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
			rotation = DEGREES_TO_RADIANS(90.0);
		}
		transform = CGAffineTransformMakeRotation(rotation);
		
		_rotating = YES;
		_interfaceOrientation = interfaceOrientation;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.6];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(recheckRotation)];
		
		_mainView.transform = transform;
		_mainView.bounds = CGRectMake(0,0,1024,768);
		
		[UIView commitAnimations];
	}
}

- (void) recheckRotation{
	_rotating = NO;
	[self checkRotation];
}

#pragma mark -
#pragma mark Application Initialization

- (void) createSaveData {
	// Read saved data
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"];
	NSDictionary *_gameData = [NSDictionary dictionaryWithContentsOfFile:filePath]; 
	
	// load the stored preference of the user's last location from a previous launch
	_saveData = [[[NSUserDefaults standardUserDefaults] objectForKey:kGameDataKey] mutableCopy];
	if (_saveData == nil) {
		_saveData = [NSMutableDictionary dictionaryWithCapacity:[_gameData count]];
		[_saveData setDictionary:[_gameData valueForKey:@"GameData"]];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:_saveData forKey:kGameDataKey];
	_saveData = [[[NSUserDefaults standardUserDefaults] objectForKey:kGameDataKey] mutableCopy];
	
	NSDictionary *savedLocationDict = [NSDictionary dictionaryWithObject:_saveData forKey:kGameDataKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:savedLocationDict];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	_levelNum = [[_saveData valueForKey:@"LevelNum"] unsignedIntValue];
}

#pragma mark -
#pragma mark State Changes

- (void) changeStateNotification:(NSNotification*)notificationObject {
	NSDictionary *userInfo = [notificationObject userInfo];
	unsigned newState = [[userInfo objectForKey:kNotificationKey] unsignedIntValue];
	[self changeState:newState];
}

- (void) changeState:(unsigned)state {
	if (_viewController && [_viewController view] && [[_viewController view] superview]) {
		[[_viewController view] removeFromSuperview];
		[_viewController release];
		_viewController = nil;
	}
	
	if (state == kGameState_Legal) {
		_viewController = [[LegalViewController alloc] init];
		[_mainView addSubview:[_viewController view]];
	} else if (state == kGameState_Title) {
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Animations" ofType:@"plist"];
		NSDictionary *dict = [[[NSDictionary alloc] initWithContentsOfFile:filePath] autorelease];
		NSArray *data = [NSArray arrayWithArray:[dict valueForKey:@"Title"]];
		
		_viewController = [[TitleViewController alloc] init];
		[_viewController setLevelData:data];
		[_mainView addSubview:[_viewController view]];
	} else if (state == kGameState_Game) {
		if (_gameViewController) {
			[_gameViewController setLevelNum:_levelNum];
		} else {
			NSMutableArray *animationData = [NSMutableArray arrayWithArray:[_saveData valueForKey:@"AnimationData"]];
			
			NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Animations" ofType:@"plist"];
			NSDictionary *dict = [[[NSDictionary alloc] initWithContentsOfFile:filePath] autorelease];
			NSArray *levels = [NSArray arrayWithArray:[dict valueForKey:@"Levels"]];
			
			_gameViewController = [[GameViewController alloc] init];
			_gameViewController._animationDataTable = animationData;
			_gameViewController._levels = levels;
			[_gameViewController setLevelNum:_levelNum];
		}
		
		[_mainView addSubview:[_gameViewController view]];
	}
	
	_state = state;
}

- (void) resetGame:(unsigned)levelNum {
	_levelNum = levelNum;
	[self changeState:kGameState_Game];
}

#pragma mark -
#pragma mark OpenAL Getter/Setter

- (OpenALPlayer*) _openALPlayer {
	return _openALPlayer;
}

- (void) set_openALPlayer:(OpenALPlayer*)newOpenALPlayer {
	_openALPlayer = newOpenALPlayer;
}

@end
