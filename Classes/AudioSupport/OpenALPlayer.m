#import "OpenALPlayer.h"
#import "MyOpenALSupport.h"
#import "Constants.h"

@interface Sound(Private)
- (instancetype) initSoundWithIdentifier:(NSString*)identifier;
@end

@implementation Sound
@synthesize _sourceID, _bufferID, _identifier, _playing, _volume, _volumeState;

- (instancetype) initSoundWithIdentifier:(NSString*)identifier {
	if ((self = [super init])) {
		_identifier = [[NSString alloc] initWithString:identifier];
		alGenBuffers(1, &_bufferID); 
		alGenSources(1, &_sourceID); 
		
		_playing = NO;
		_loop = NO;
		
		_position = CGPointMake(0.0, 0.0);
		float sourcePosAL[] = {_position.x, kDefaultDistance, _position.y};
		alSourcefv(_sourceID, AL_POSITION, sourcePosAL);
		
		_volume = 1.0;
		_volumeState = 0;
	}
	
	return self;
}

- (void) set_loop:(BOOL)newLoop {
	_loop = newLoop;
	if (_loop) {
		alSourcei(_sourceID, AL_LOOPING, AL_TRUE);
	} else {
		alSourcei(_sourceID, AL_LOOPING, AL_FALSE);
	}
}
- (BOOL) _loop {
	return _loop;
}

- (void) set_position:(CGPoint)newPosition {
	_position = newPosition;
	
	float sourcePosAL[] = {_position.x, kDefaultDistance, _position.y};
	// Move our audio source coordinates
	alSourcefv(_sourceID, AL_POSITION, sourcePosAL);
}
- (CGPoint) _position {
	return _position;
}

- (void) set_volume:(float)newVolume {
	_volume = newVolume;
	alSourcef(_sourceID, AL_GAIN, _volume);
}
- (float) _volume {
	return _volume;
}

- (void)dealloc {
	alDeleteSources(1, &_sourceID);
    alDeleteBuffers(1, &_bufferID);
	
	[_identifier release];
	
	[super dealloc];
}

@end



@implementation OpenALPlayer

@synthesize _listenerPos, _listenerRotation, _interrupted;

#pragma mark Object Init / Maintenance
void interruptionListener(void *inClientData, UInt32 inInterruptionState) {
	OpenALPlayer* THIS = (__bridge OpenALPlayer*)inClientData;
	if (inInterruptionState == kAudioSessionBeginInterruption) {
		//[THIS teardownOpenAL];	
		[THIS stopAllSoundsExcept:@""];
		alcMakeContextCurrent(NULL);
		if ([THIS soundPlaying]) {
			THIS._interrupted = YES;
		}
	} else if (inInterruptionState == kAudioSessionEndInterruption) {
		OSStatus result = AudioSessionSetActive(true);
		if (result) NSLog(@"Error setting audio session active! %d\n", (int)result);
		alcMakeContextCurrent(THIS->_context);
		//[THIS initOpenAL];
		if (THIS._interrupted) {
			[THIS restartSounds];		
			THIS._interrupted = NO;
		}
	}
}

/*
void RouteChangeListener(void *inClientData, AudioSessionPropertyID inID, 
						 UInt32 inDataSize, const void *inData) {
	CFDictionaryRef dict = (CFDictionaryRef)inData;
	
	CFStringRef oldRoute = CFDictionaryGetValue(dict, CFSTR(kAudioSession_AudioRouteChangeKey_OldRoute));
	
	UInt32 size = sizeof(CFStringRef);
	
	CFStringRef newRoute;
	OSStatus result = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute);
	
	NSLog(@"result: %d Route changed from %@ to %@", result, oldRoute, newRoute);
}
*/

- (instancetype) init {	
	if (self = [super init]) {
		// Put the listener in the center of the stage
		_listenerPos = CGPointMake(0.0, 0.0);
		
		// Listener looking straight ahead
		_listenerRotation = 0.0;
		
		// setup our audio session
		OSStatus result = AudioSessionInitialize(NULL, NULL, interruptionListener, self);
		if (result) {
			NSLog(@"Error initializing audio session! %d\n", (int)result);
		} else {
			UInt32 category = kAudioSessionCategory_AmbientSound;
			result = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
			if (result) NSLog(@"Error setting audio session category! %d\n", (int)result);
			
			result = AudioSessionSetActive(true);
			if (result) NSLog(@"Error setting audio session active! %d\n", (int)result);
		}
		
		_interrupted = NO;
		
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Sounds" ofType:@"plist"];
		_sounds = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath]; 
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSoundLoopNotification:) name:kSetSoundLoopNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playSoundNotification:) name:kPlaySoundNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fadeSoundInNotification:) name:kFadeSoundInNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fadeSoundOutNotification:) name:kFadeSoundOutNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSoundNotification:) name:kStopSoundNotification object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(querySoundNotification:) name:kQuerySoundNotification object:nil];
		
		// Initialize our OpenAL environment
		[self initOpenAL];
	}
	
	return self;
}

- (void)dealloc {
	[super dealloc];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_sounds release];
	
	[self teardownOpenAL];

}

#pragma mark OpenAL

- (BOOL) isSoundInitialized:(NSString*)name  {
	NSString* filename = _sounds[name];
	return (filename && [filename isKindOfClass:[Sound class]]);
}

- (Sound*) soundWithIdentifier:(NSString*)identifier {
	BOOL initialized;
	Sound *sound;
	NSString *filename;
	initialized = [self isSoundInitialized:identifier];
	
	if (!initialized) {
		filename = _sounds[identifier];
		if ([filename isKindOfClass:[NSString class]]) {
			if (![[NSBundle mainBundle] pathForResource:filename ofType:@"caf"]) {
				NSLog (@"ERROR: Could not load file %@", filename);
				return NULL;
			}
			sound = [[Sound alloc] initSoundWithIdentifier:identifier];
			if (![self initSoundBuffer:sound forFileName:filename ofType:@"caf"]) {
				[sound release];
				return NULL;
			} else {
				_sounds[identifier] = sound;
				[sound release];
			}
		}
	}
	
	sound = _sounds[identifier];
	return sound;
}

- (BOOL) initSoundBuffer:(Sound*)sound forFileName:(NSString*)fileName ofType:(NSString*)fileType {
	ALenum  error = AL_NO_ERROR;
	ALenum  format;
	ALsizei size;
	ALsizei freq;
	void *data;
	
	CFURLRef fileURL = (CFURLRef)[[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:fileType]] retain];
	
	if (fileURL) {	
		data = MyGetOpenALAudioData(fileURL, &size, &format, &freq);
		CFRelease(fileURL);
		
		if((error = alGetError()) != AL_NO_ERROR) {
			NSLog(@"error loading sound: %x\n", error);
			return NO;
		}
		
		// use the static buffer data API
		alBufferDataStaticProc(sound._bufferID, format, data, size, freq);
		
		if((error = alGetError()) != AL_NO_ERROR) {
			NSLog(@"error attaching audio to buffer: %x\n", error);
			return NO;
		} else {
			return [self initSoundSource:sound];
		}
	} else {
		NSLog(@"Could not find file!\n");
		return NO;
	}
}

- (BOOL) initSoundSource:(Sound*)sound {
	ALenum error = AL_NO_ERROR;
	alGetError(); // Clear the error
	
	// Set Source Reference Distance
	alSourcef(sound._sourceID, AL_REFERENCE_DISTANCE, 50.0f);
	
	// attach OpenAL Buffer to OpenAL Source
	alSourcei(sound._sourceID, AL_BUFFER, sound._bufferID);
	
	if((error = alGetError()) != AL_NO_ERROR) {
		NSLog(@"Error attaching buffer to source: %x\n", error);
		return NO;
	} else {
		return YES;
	}
}

- (void)initOpenAL {
	// Create a new OpenAL Device
	// Pass NULL to specify the system’s default output device
	_device = alcOpenDevice(NULL);
	if (_device != NULL) {
		// Create a new OpenAL Context
		// The new context will render to the OpenAL Device just created 
		_context = alcCreateContext(_device, 0);
		if (_context != NULL) {
			// Make the new context the Current OpenAL Context
			alcMakeContextCurrent(_context);
			/*
			// Create some OpenAL Buffer Objects
			alGenBuffers(kNumBuffers, _buffers);
			if((error = alGetError()) != AL_NO_ERROR) {
				NSLog(@"Error Generating Buffers: %x", error);
				exit(1);
			}
			
			// Create some OpenAL Source Objects
			alGenSources(kNumSources, _sources);
			if(alGetError() != AL_NO_ERROR) 
			{
				NSLog(@"Error generating sources! %x\n", error);
				exit(1);
			}
			 */
			
		}
	}
	// clear any errors
	alGetError();
}

- (void) teardownOpenAL {
	// Delete the Sources
    //alDeleteSources(kNumSources, _sources);
	// Delete the Buffers
   // alDeleteBuffers(kNumBuffers, _buffers);

    //Release context
    alcDestroyContext(_context);
    //Close device
    alcCloseDevice(_device);
}

#pragma mark Play / Pause

- (void) setSoundLoop:(NSString*)identifier loop:(BOOL)loop {
	Sound *sound = [self soundWithIdentifier:identifier];
	sound._loop = loop;
}

- (BOOL) soundPlaying:(NSString*)identifier {
	ALint state;
	Sound *sound = [self soundWithIdentifier:identifier];
	if (sound) {
		alGetSourcei(sound._sourceID, AL_SOURCE_STATE, &state);
		sound._playing = state == AL_PLAYING;
		return sound._playing;
	} else {
		return NO;
	}
}

- (BOOL) soundPlaying {
	BOOL playing;
	playing = NO;
	for (id key in _sounds) {
		if ([self isSoundInitialized:key] && [self soundPlaying:key]) {
			playing = YES;
		}
	}
	return playing;
}

- (void) restartSounds {
	for (id key in _sounds) {
		if ([self isSoundInitialized:key] && [self soundPlaying:key]) {
			[self playSound:key restart:YES];
		}
	}
}

- (BOOL) playSound:(NSString*)identifier restart:(BOOL)restart atVolume:(float)volume {
	ALenum error;
	Sound *sound = [self soundWithIdentifier:identifier];
	BOOL newSound = NO;
	
	if (sound) {
		if ([self soundPlaying:identifier]) {
			if (restart) {
				[self stopSound:identifier];
				newSound = YES;
			}
		} else {
			newSound = YES;
		}
		// Begin playing our source file
		sound._volumeState = 0;
		sound._volume = volume;
		alSourcePlay(sound._sourceID);
		
		if((error = alGetError()) != AL_NO_ERROR) {
			NSLog(@"error starting source: %x\n", error);
			newSound = NO;
		} else {
			sound._playing = YES;
		}
	}
	return newSound;
}

- (BOOL) playSound:(NSString*)identifier restart:(BOOL)restart {
	ALenum error;
	Sound *sound = [self soundWithIdentifier:identifier];
	BOOL newSound = NO;
	
	if (sound) {
		if ([self soundPlaying:identifier]) {
			if (restart) {
				[self stopSound:identifier];
				newSound = YES;
			}
		} else {
			newSound = YES;
		}
		// Begin playing our source file
		sound._volumeState = 0;
		sound._volume = 1.0;
		alSourcePlay(sound._sourceID);
		
		if((error = alGetError()) != AL_NO_ERROR) {
			NSLog(@"error starting source: %x\n", error);
			newSound = NO;
		} else {
			sound._playing = YES;
		}
	}
	return newSound;
}

- (void) fadeSoundIn:(NSString*)identifier {
	Sound *sound;
	BOOL newSound = [self playSound:identifier restart:NO];
	
	if (newSound) {
		sound = [self soundWithIdentifier:identifier];
		sound._volume = 0.0;
		sound._volumeState = 1;
		[self startFadeTimer:identifier];
	}
}

- (void) stopAllSoundsExcept:(NSString*)identifier {
	for (id key in _sounds) {
		if (key != identifier && [self isSoundInitialized:key]) {
			[self stopSound:key];
		}
	}
}

- (void)stopSound:(NSString*)identifier {
	ALenum error;
	Sound *sound = [self soundWithIdentifier:identifier];
	sound._volumeState = 0;
	sound._playing = NO;
	alSourceStop(sound._sourceID);
	if((error = alGetError()) != AL_NO_ERROR) {
		NSLog(@"error stopping source: %x\n", error);
	}
}

- (void) fadeSoundOut:(NSString*)identifier {
	if ([self soundPlaying:identifier]) {
		Sound *sound = [self soundWithIdentifier:identifier];
		sound._volume = 1.0;
		sound._volumeState = -1;
		[self startFadeTimer:identifier];
	}
}

- (void) fadeSound:(NSTimer*)timer {
	BOOL stillFading = NO;
	NSString *identifier = [timer userInfo];
	Sound *sound = [self soundWithIdentifier:identifier];
	
	if (sound) {
		sound._volume = sound._volume + (sound._volumeState * 0.1);
		if (sound._volume <= 0.0) {
			sound._volumeState = 0;
			[self stopSound:sound._identifier];
		} else if (sound._volume >= 1.0) {
			sound._volumeState = 0;
		} else {
			stillFading = YES;
		}
	}
	
	if (stillFading) {
		[self startFadeTimer:identifier];
	}
}

- (void) startFadeTimer:(NSString*)identifier {
	[NSTimer scheduledTimerWithTimeInterval:(0.1) target:self selector:@selector(fadeSound:) userInfo:[NSString stringWithString:identifier] repeats:NO];
}

#pragma mark -
#pragma mark Set Properties

- (void) setSourcePosition:(Sound*)sound atPosition:(CGPoint)position {
	sound._position = position;
}

- (void)setListenerPos:(CGPoint)pos {
	_listenerPos = pos;
	float listenerPosAL[] = {_listenerPos.x, 0., _listenerPos.y};
	// Move our listener coordinates
	alListenerfv(AL_POSITION, listenerPosAL);
}

- (void)setListenerRotation:(CGFloat)rotRadians {
	_listenerRotation = rotRadians;
	float ori[] = {cos(rotRadians + M_PI_2), sin(rotRadians + M_PI_2), 0., 0., 0., 1.};
	// Set our listener orientation (rotation)
	alListenerfv(AL_ORIENTATION, ori);
}

#pragma mark -
#pragma mark Notifications

- (void) setSoundLoopNotification:(NSNotification*)notificationObject {
	NSDictionary *userInfo = [notificationObject userInfo];
	NSString *identifier = userInfo[kNotificationSoundIdentifier];
	BOOL loop = [userInfo[kNotificationSoundLoop] boolValue];
	
	[self setSoundLoop:identifier loop:loop];
}

- (void) playSoundNotification:(NSNotification*)notificationObject {
	NSDictionary *userInfo = [notificationObject userInfo];
	NSString *identifier = userInfo[kNotificationSoundIdentifier];
	BOOL restart = [userInfo[kNotificationSoundRestart] boolValue];
	float volume;
	
	if (userInfo[kNotificationSoundVolume]) {
		volume = [userInfo[kNotificationSoundVolume] floatValue];
		[self playSound:identifier restart:restart atVolume:volume];
	} else {
		[self playSound:identifier restart:restart];
	}
}

- (void) fadeSoundInNotification:(NSNotification*)notificationObject {
	NSDictionary *userInfo = [notificationObject userInfo];
	NSString *identifier = userInfo[kNotificationSoundIdentifier];

	[self fadeSoundIn:identifier];
}

- (void) fadeSoundOutNotification:(NSNotification*)notificationObject {
	NSDictionary *userInfo = [notificationObject userInfo];
	NSString *identifier = userInfo[kNotificationSoundIdentifier];
	
	[self fadeSoundOut:identifier];
}

- (void) stopSoundNotification:(NSNotification*)notificationObject {
	NSDictionary *userInfo = [notificationObject userInfo];
	NSString *identifier = userInfo[kNotificationSoundIdentifier];
	
	[self stopSound:identifier];
}

- (void) querySoundNotification:(NSNotification*)notificationObject {
	NSDictionary *userInfo = [notificationObject userInfo];
	NSString *identifier = userInfo[kNotificationSoundIdentifier];

	BOOL soundPlaying = [self soundPlaying:identifier];
	
	NSDictionary *soundInfo = @{kNotificationSoundIdentifier: identifier,
							   kNotificationSoundPlaying: @(soundPlaying)};
	[[NSNotificationCenter defaultCenter] postNotificationName:kQueryResponseSoundNotification object:self userInfo:soundInfo];
	
}

@end