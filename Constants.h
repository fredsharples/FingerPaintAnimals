/*
 *  Constants.h
 *  MadrigalChallenge
 *
 *  Created by Susan Surapruik on 7/14/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#import <mach/mach_time.h>
#import "Texture2D.h"

typedef enum {
	kGameState_StandBy = 0,
	kGameState_Legal,
	kGameState_Title,
	kGameState_Game
} GameState;

#define DEGREES_TO_RADIANS(_ANGLE_) (_ANGLE_ / 180.0 * M_PI)

#define kNumLevels				21

#define kGameDataKey			@"GameData"	// preference key to obtain our restore location

#define kMinimumGestureLength	200.0 // pixels

#define kLegalTimeOut			5.0 // seconds legal screen is visible

#define kViewFadeTime			0.75 // fade transition in seconds

#define kRenderingFPS			24.0 // Hz
#define kAnimationRenderingFPS	12.0 // Hz

#define kImage_Paper			@"paper_00"
#define kImage_Brush			@"brush"
#define kImage_Speckle			@"speckle_00"
#define kNewScreenAudio			@"SFX_nextScreen"
#define kNewLevelAudio			@"SFX_nextAnimal"
#define kTitleAudio				@"VO_title"
#define kCameraAudio			@"SFX_camera"
#define kTrashAudio				@"SFX_trash"
#define kBlankPageAudio			@"VO_blank"
#define kClickAudio				@"SFX_buttonClick"
#define kClickVolume			0.15

#define kURLRequest				@"http://www.learnl.net"

// Notifications

#define kChangeStateNotification	@"ChangeState"

#define kNotificationKey			@"NotificationKey"


#define kSetSoundLoopNotification	@"SetSoundLoop"
#define kPlaySoundNotification		@"PlaySound"
#define kFadeSoundInNotification	@"FadeSoundIn"
#define kFadeSoundOutNotification	@"FadeSoundOut"
#define kStopSoundNotification		@"StopSound"
#define kQuerySoundNotification		@"QuerySound"
#define kQueryResponseSoundNotification		@"QueryResponseSound"

#define kNotificationSoundIdentifier	@"SoundIdentifier"
#define kNotificationSoundLoop			@"SoundLoop"
#define kNotificationSoundRestart		@"SoundRestart"
#define kNotificationSoundVolume		@"SoundVolume"
#define kNotificationSoundPlaying		@"SoundPlaying"