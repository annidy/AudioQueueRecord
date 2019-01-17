//
//  AQRecordModel.h
//  AudioQueueRecord
//
//  Created by John Geelen on 03-07-11.
//  Copyright 2011 JG Electronics. All rights reserved.
//	Remarks, reports to: www.jgelectronics.nl.
//
//	Derived from Apple's example program Record Audio described in Apple's Audio Queue Services Programming Guide.
//	The application icon is from Vincent Garnier http://benjigarner.deviantart.com/art/Fruity-Apples-80805804
//
//	OSX10.6 and XCODE 4.0.1
//
/*
 Disclaimer: IMPORTANT: 
 This JG Electronics software is supplied to you by JG Electronics as FREE AND OPEN SOURCE SOFTWARE. 
 
 The JG Electronics Software is provided by JG Electronics on an "AS IS" basis.
 JG ELECTRONICS MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE JG ELECTRONICS SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL JG ELECTRONICS BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE JG ELECTRONICS SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF JG ELECTRONICS HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/*
 static const int kNumberBuffers = 3;							// 1
 
 struct AQRecorderState
 {
	AudioStreamBasicDescription		mDataFormat;				// 2
	AudioQueueRef					mQueue;						// 3
	AudioQueueBufferRef				mBuffers[kNumberBuffers];	// 4
	AudioFileID						mAudioFile;					// 5
	UInt32							bufferByteSize;				// 6
	SInt64							mCurrentPacket;				// 7
	BOOL							mIsRunning;					// 8
 };
 */


/*
 1.	Sets the number of audio queue buffers to use.
 2.	An AudioStreamBasicDescription structure (from CoreAudioTypes.h) representing the audio data format to write to disk.
 This format gets used by the audio queue specified in the mQueue field.
 The mDataFormat field gets filled initially by code in your program, as described in “Set Up an Audio Format for Recording.”
 It is good practice to then update the value of this field by querying the audio queue's kAudioConverterCurrentOutputStreamDescription property, as described in “Getting the Full Audio Format from an Audio Queue.”
 For details on the AudioStreamBasicDescription structure, see Core Audio Data Types Reference.
 3.	The recording audio queue created by your application.
 4.	An array holding pointers to the audio queue buffers managed by the audio queue.
 5.	An audio file object representing the file into which your program records audio data.
 6.	The size, in bytes, for each audio queue buffer. This value is calculated in these examples in the DeriveBufferSize function, after the audio queue is created and before it is started. See “Write a Function to Derive Recording Audio Queue Buffer Size.”
 7.	The packet index for the first packet to be written from the current audio queue buffer.
 8.	A Boolean value indicating whether or not the audio queue is running.
 */

//	static const int kNumberBuffers = 3;						// 1

@interface AQRecordModel : NSObject
{
@public
    AudioStreamBasicDescription		mDataFormat;				// 2
	AudioQueueRef					mQueue;						// 3
	AudioQueueBufferRef				mBuffers[3];				// 4
	AudioFileID						mAudioFile;					// 5
	UInt32							mBufferByteSize;			// 6
	SInt64							mCurrentPacket;				// 7
	BOOL							mIsRunning;					// 8
}

- (BOOL)rmConfigureOutputFile:(CFURLRef)inURL;
- (BOOL)rmStart;
- (BOOL)rmStop;
- (OSStatus)rmSetMagicCookieForFile:(AudioQueueRef)inQueue audioFile:(AudioFileID)inFile;

@end
