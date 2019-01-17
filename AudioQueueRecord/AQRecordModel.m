//
//  AQRecordModel.m
//  AudioQueueRecord
//
//  Created by John Geelen on 06-07-11.
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

#import "AQRecordModel.h"


@implementation AQRecordModel

	#pragma mark -
	#pragma mark === Static Methods ===
//	*********************************************************************************************************************************
static void HandleInputBuffer (void *aqData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,
															UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc);

	#pragma mark -
	#pragma mark === Internal Methods ===
//	*********************************************************************************************************************************

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark -
#pragma mark === Audio Methods ===
	//	*********************************************************************************************************************************
- (BOOL)rmConfigureOutputFile:(CFURLRef)inURL
{
	OSStatus	error = noErr;
	
		//	Set Up an Audio Format for Recording
	mDataFormat.mFormatID = kAudioFormatLinearPCM;															//	2
	mDataFormat.mSampleRate = 44100.0;																		//	3
	mDataFormat.mChannelsPerFrame = 2;																		//	4
	mDataFormat.mBitsPerChannel = 16;																		//	5
	mDataFormat.mBytesPerPacket = mDataFormat.mChannelsPerFrame *sizeof(SInt16);							//	6
	mDataFormat.mBytesPerFrame = mDataFormat.mChannelsPerFrame *sizeof(SInt16);								//	6
	mDataFormat.mFramesPerPacket = 1;																		//	7
	mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsBigEndian | kLinearPCMFormatFlagIsSignedInteger 
	| kLinearPCMFormatFlagIsPacked;																			//	9
	mIsRunning = NO;
	
	AudioFileTypeID		fileType = kAudioFileCAFType;														//	8 
	
		//	Create a Recording Audio Queue
	error = AudioQueueNewInput (																			//	1
								&mDataFormat,																//	2
								HandleInputBuffer,															//	3
								self,																		//	4
								NULL,																		//	5
								kCFRunLoopCommonModes,														//	6
								0,																			//	7
								&mQueue																		//	8
								);
	if(error != noErr) {
		NSLog(@"AudioQueueNewInput failed");
	}
    UInt32 d = 1;
    AudioQueueSetProperty(mQueue, kAudioQueueProperty_EnableLevelMetering, &d, sizeof(UInt32));

	/*
	 1.	The AudioQueueNewInput function creates a new recording audio queue.
	 2.	The audio data format to use for the recording. See “Set Up an Audio Format for Recording.”
	 3.	The callback function to use with the recording audio queue. See “Write a Recording Audio Queue Callback.”
	 4.	The custom data structure for the recording audio queue. See “Define a Custom Structure to Manage State.”
	 5.	The run loop on which the callback will be invoked. Use NULL to specify default behavior, in which the callback will be invoked on a thread internal to the audio queue. This is typical use—it allows the audio queue to record while your application’s user interface thread waits for user input to stop the recording.
	 6.	The run loop modes in which the callback can be invoked. Normally, use the kCFRunLoopCommonModes constant here.
	 7.	Reserved. Must be 0.
	 8.	On output, the newly allocated recording audio queue.
	 */
	
		//	Getting the Full Audio Format from an Audio Queue
	UInt32 dataFormatSize = sizeof (mDataFormat);														//	1
	error = AudioQueueGetProperty (																		//	2
								   mQueue,																//	3
								   kAudioConverterCurrentOutputStreamDescription,						//	4
								   &mDataFormat,														//	5
								   &dataFormatSize														//	6
								   );
	if(error != noErr) {
		NSLog(@"AudioQueueGetProperty failed");
	}
	/*
	 1.	Gets an expected property value size to use when querying the audio queue about its audio data format.
	 2.	The AudioQueueGetProperty function obtains the value for a specified property in an audio queue.
	 3.	The audio queue to obtain the audio data format from.
	 4.	The property ID for obtaining the value of the audio queue’s data format.
	 5.	On output, the full audio data format, in the form of an AudioStreamBasicDescription structure, obtained from the audio queue.
	 6.	On input, the expected size of the AudioStreamBasicDescription structure. On output, the actual size. Your recording application does not need to make use of this value.
	 */
	
		//	Create an Audio File
	error = AudioFileCreateWithURL (
									inURL,																//	7
									fileType,															//	8
									&mDataFormat,														//	9
									kAudioFileFlags_EraseFile,											//	10
									&mAudioFile															//	11
									);
	if(error != noErr) {
		NSLog(@"AudioFileCreateWithURL failed");
	}
	/*
	 7.	The URL at which to create the new audio file, or to initialize in the case of an existing file. The URL was derived from theCFURLCreateFromFileSystemRepresentation in step 1.
	 8.	The file type for the new file. In the example code in this chapter, this was previously set to AIFF by way of the kAudioFileAIFFType file type constant. See “Set Up an Audio Format for Recording.”
	 9.	The data format of the audio that will be recorded into the file, specified as an AudioStreamBasicDescription structure. In the example code for this chapter, this was also set in “Set Up an Audio Format for Recording.”
	 10. Erases the file, in the case that the file already exists.
	 11. On output, an audio file object (of type AudioFileID) representing the audio file to record into.
	 */
	
		// copy the cookie first to give the file object as much info as we can about the data going in
	error = [self rmSetMagicCookieForFile:mQueue audioFile:mAudioFile];
	if(error != noErr) {
		NSLog(@"rmSetMagicCookieForFile failed");
	}
	
		//	Set an Audio Queue Buffer Size
	/*
	 1.	The DeriveBufferSize function, described in “Write a Function to Derive Recording Audio Queue Buffer Size,” sets an appropriate audio queue buffer size.
	 2.	The audio queue that you’re setting buffer size for.
	 3.	The audio data format for the file you are recording. See “Set Up an Audio Format for Recording.”
	 4.	The number of seconds of audio that each audio queue buffer should hold. One half second, as set here, is typically a good choice.
	 5.	On output, the size for each audio queue buffer, in bytes. This value is placed in the custom structure for the audio queue.
	 
	 DeriveBufferSize (																						//	1
	 pAqData.mQueue,																						//	2
	 pAqData.mDataFormat,																					//	3
	 0.5,																									//	4
	 &pAqData.bufferByteSize																				//	5
	 );
	 */
	
		//	void DeriveBufferSize(
		//						  AudioQueueRef				audioQueue,										//	1
		//						  AudioStreamBasicDescription	&ASBDescription,							//	2
		//						  Float64						seconds,									//	3
		//						  UInt32						*outBufferSize								//	4
		//						  )
		//	{
	static const int maxBufferSize = 0x50000;																//	5
	int maxPacketSize = mDataFormat.mBytesPerPacket;														//	6
	
	if (maxPacketSize == 0)	{																				//	7
		UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
		AudioQueueGetProperty (
							   mQueue,
							   kAudioConverterPropertyMaximumOutputPacketSize,
							   &maxPacketSize,
							   &maxVBRPacketSize
							   );
	}
	Float64	seconds = 0.5;
	Float64	numBytesForTime = mDataFormat.mSampleRate * maxPacketSize * seconds;							//	8
	mBufferByteSize  = (numBytesForTime < maxBufferSize ? numBytesForTime : maxBufferSize);					//	9
	/*
	 Here’s how this code works:
	 1.	The audio queue that owns the buffers whose size you want to specify.
	 2.	The AudioStreamBasicDescription structure for the audio queue.
	 3.	The size you are specifying for each audio queue buffer, in terms of seconds of audio.
	 4.	On output, the size for each audio queue buffer, in terms of bytes.
	 5.	An upper bound for the audio queue buffer size, in bytes. In this example, the upper bound is set to 320 KB. This corresponds to approximately five seconds of stereo, 24 bit audio at a sample rate of 96 kHz.
	 6.	For CBR audio data, get the (constant) packet size from the AudioStreamBasicDescription structure. Use this value as th maximum packet size.This assignment has the side effect of determining if the audio data to be recorded is CBR or VBR. If it i VBR, the audio queue’s AudioStreamBasicDescription structure lists the value of bytes-per-packet as 0.
	 7.	For VBR audio data, query the audio queue to get the estimated maximum packet size.
	 8.	Derive the buffer size, in bytes.
	 9.	Limit the buffer size, if needed, to the previously set upper bound.
	 */
	
		//	Prepare a Set of Audio Queue Buffers
	for (int i = 0; i < 3; ++i)
		{																									//	1
			error = AudioQueueAllocateBuffer (																//	2
											  mQueue,														//	3
											  mBufferByteSize,												//	4
											  &mBuffers[i]													//	5
											  );
			if(error != noErr) {
				NSLog(@"AudioQueueAllocateBuffer1 failed");
			}
			
			error = AudioQueueEnqueueBuffer (																//	6
											 mQueue,														//	7
											 mBuffers[i],													//	8
											 0,																//	9
											 NULL															//	10
											 );
			if(error != noErr) {
				NSLog(@"AudioQueueAllocateBuffer2 failed");
			}
		}
	/*
	 1.	Iterates to allocate and enqueue each audio queue buffer.
	 2.	The AudioQueueAllocateBuffer function asks an audio queue to allocate an audio queue buffer.
	 3.	The audio queue that performs the allocation and that will own the buffer.
	 4.	The size, in bytes, for the new audio queue buffer being allocated. See “Write a Function to Derive Recording Audio Queue Buffer Size.”
	 5.	On output, the newly allocated audio queue buffer. The pointer to the buffer is placed in the custom structure you’re using with the audio queue.
	 6.	The AudioQueueEnqueueBuffer function adds an audio queue buffer to the end of a buffer queue.
	 7.	The audio queue whose buffer queue you are adding the buffer to.
	 8.	The audio queue buffer you are enqueuing.
	 9.	This parameter is unused when enqueuing a buffer for recording.
	 10. This parameter is unused when enqueuing a buffer for recording.
	 */
	NSLog(@"rmConfigureOutputFile end");
	return YES;
}

-(BOOL)rmStart
{
	NSLog(@"rmStart start");
	OSStatus	error = noErr;
	
	mCurrentPacket = 0;
	mIsRunning = YES;
	error = AudioQueueStart(mQueue, NULL);
	if(error != noErr) {
		NSLog(@"AudioQueueStart failed");
	}
	return YES;
}

-(BOOL)rmStop
{
	NSLog(@"rmStop start");
	OSStatus	error = noErr;
	
	error = AudioQueueStop(mQueue, true);
	if(error != noErr) {
		NSLog(@"AudioQueueStop failed");
	}
	mIsRunning = NO;
		// a codec may update its cookie at the end of an encoding session, so reapply it to the file now
	error = [self rmSetMagicCookieForFile:mQueue audioFile:mAudioFile];
	if(error != noErr) {
		NSLog(@"rmSetMagicCookieForFile failed");
	}
	
	error = AudioQueueDispose(mQueue, true);
	if(error != noErr) {
		NSLog(@"AudioQueueDispose failed");
	}
	AudioFileClose(mAudioFile);
	return YES;
}

- (OSStatus)rmSetMagicCookieForFile:(AudioQueueRef) inQueue															//	1
						  audioFile:(AudioFileID)	inFile															//	2
{
	NSLog(@"rmSetMagicCookieForFile start");
	OSStatus	result = noErr;																						//	3
	UInt32		cookieSize;																							//	4
	if(AudioQueueGetPropertySize(inQueue, kAudioQueueProperty_MagicCookie, &cookieSize) == noErr)					//	5
		{
		char *	magicCookie = (char *) malloc(cookieSize);															//	6
		if(AudioQueueGetProperty(inQueue, kAudioQueueProperty_MagicCookie, magicCookie, &cookieSize) == noErr) {	//	7
			result = AudioFileSetProperty(inFile, kAudioFilePropertyMagicCookieData, cookieSize, magicCookie);		//	8
		}
		free (magicCookie);																							//	9
		}
	return result;																									//	10
}
/*
 Here’s how this code works:
 1.	The audio queue you’re using for recording.
 2.	The audio file you’re recording into.
 3.	A result variable that indicates the success or failure of this function.
 4.	A variable to hold the magic cookie data size.
 5.	Gets the data size of the magic cookie from the audio queue and stores it in the cookieSize variable.
 6.	Allocates an array of bytes to hold the magic cookie information.
 7.	Gets the magic cookie by querying the audio queue’s kAudioQueueProperty_MagicCookie property.
 8.	Sets the magic cookie for the audio file you’re recording into. The AudioFileSetProperty function is declared in the AudioFile.h header file.
 9.	Frees the memory for the temporary cookie variable.
 10. Returns the success or failure of this function.
 */

#pragma mark -
#pragma mark === Callback Procedures ===
	//	*********************************************************************************************************************************
static void HandleInputBuffer (
							   void *								aqData,									//	1
							   AudioQueueRef						inAQ,									//	2
							   AudioQueueBufferRef					inBuffer,								//	3
							   const AudioTimeStamp *				inStartTime,							//	4
							   UInt32								inNumPackets,							//	5
							   const AudioStreamPacketDescription *	inPacketDesc							//	6
							   )
/*
 1.	Typically, aqData is a custom structure that contains state data for the audio queue, as described in “Define a Custom Structure to Manage State.”
 2.	The audio queue that owns this callback.
 3.	The audio queue buffer containing the incoming audio data to record.
 4.	The sample time of the first sample in the audio queue buffer (not needed for simple recording).
 5.	The number of packet descriptions in the inPacketDesc parameter. A value of 0 indicates CBR data.
 6.	For compressed audio data formats that require packet descriptions, the packet descriptions produced by the encoder for the packets in the buffer.
 */
{
	NSLog(@"HandleInputBuffer start");
	AQRecordModel *pAqData = (AQRecordModel *)aqData;
		//	1
	if(inNumPackets == 0 && pAqData->mDataFormat.mBytesPerPacket != 0) {									//	2								
		inNumPackets = inBuffer->mAudioDataByteSize / pAqData->mDataFormat.mBytesPerPacket;
	}
	if(AudioFileWritePackets(pAqData->mAudioFile, false, inBuffer->mAudioDataByteSize, inPacketDesc,		//	3
							 pAqData->mCurrentPacket, &inNumPackets, inBuffer->mAudioData) == noErr) {	
		pAqData->mCurrentPacket += inNumPackets;															//	4
		if(pAqData->mIsRunning == YES) {																	//	5
			OSStatus error = AudioQueueEnqueueBuffer(pAqData->mQueue, inBuffer, 0, NULL);					//	6
			if(error != noErr) {
				NSLog(@"AudioQueueEnqueueBuffer failed");
			}
		}
	}
}
/*
 Here’s how this code works:
 1.	The custom structure supplied to the audio queue object upon instantiation, including an audio file object representing the audio file to record into as well as a variety of state data. See “Define a Custom Structure to Manage State.”
 2.	If the audio queue buffer contains CBR data, calculate the number of packets in the buffer. This number equals the total bytes of data in the buffer divided by the (constant) number of bytes per packet. For VBR data, the audio queue supplies the number of packets in the buffer when it invokes the callback.
 3.	Writes the contents of the buffer to the audio data file. For a detailed description , see “Writing an Audio Queue Buffer to Disk.”
 4.	If successful in writing the audio data, increment the audio data file’s packet index to be ready for writing the next buffer's worth of audio data.
 5.	If the audio queue has stopped, return.
 6.	Enqueues the audio queue buffer whose contents have just been written to the audio file. For a detailed description, see “Enqueuing an Audio Queue Buffer.”
 */

@end
