#import <UIKit/UIKit.h>

#import <OpenAL/al.h>
#import <OpenAL/alc.h>

#define kDefaultDistance 1.0

@interface Sound : NSObject {
	ALuint _sourceID;
	ALuint _bufferID;
	NSString *_identifier;
	BOOL _playing;
	BOOL _loop;
	CGPoint _position;
	float _volume;
	int _volumeState;
}

@property ALuint _sourceID;
@property ALuint _bufferID;
@property (nonatomic, retain) NSString *_identifier;
@property BOOL _playing;
@property BOOL _loop;
@property CGPoint _position;
@property float _volume;
@property int _volumeState;

@end

@interface OpenALPlayer : NSObject {
	ALCcontext *_context;
	ALCdevice *_device;
	
	CGPoint _listenerPos;
	CGFloat _listenerRotation;
	ALfloat _sourceVolume;
	
	BOOL _interrupted;	
	
	NSMutableDictionary *_sounds;
}

@property (nonatomic, assign) BOOL _interrupted;		// Whether playback was interrupted by the system
@property (nonatomic, assign) CGPoint _listenerPos;		// The coordinates of the listener
@property (nonatomic, assign) CGFloat _listenerRotation;	// The rotation angle of the listener in radians

- (void) initOpenAL;
- (void) teardownOpenAL;

- (BOOL) initSoundBuffer:(Sound*)sound forFileName:(NSString*)fileName ofType:(NSString*)fileType;
- (BOOL) initSoundSource:(Sound*)sound;

- (void) setSoundLoop:(NSString*)identifier loop:(BOOL)loop;
- (BOOL) soundPlaying:(NSString*)identifier;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL soundPlaying;
- (void) stopAllSoundsExcept:(NSString*)identifier;
- (void) restartSounds;
- (BOOL) playSound:(NSString*)identifier restart:(BOOL)restart atVolume:(float)volume;
- (BOOL) playSound:(NSString*)identifier restart:(BOOL)restart;
- (void) fadeSoundIn:(NSString*)identifier;
- (void) stopSound:(NSString*)identifier;
- (void) fadeSoundOut:(NSString*)identifier;

- (void) startFadeTimer:(NSString*)identifier;

- (void) setSourcePosition:(Sound*)sound atPosition:(CGPoint)position;
- (void) setListenerPos:(CGPoint)pos;
- (void) setListenerRotation:(CGFloat)rotRadians;

@end