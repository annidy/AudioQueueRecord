//
//  AQRecordController.m
//  AudioQueueRecord
//
//  Created by John Geelen on 01-07-11.
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

#import "AQRecordController.h"


@implementation AQRecordController
@synthesize volumeIndicator;

	#pragma mark -
	#pragma mark === Accessor Methods ===
//	*********************************************************************************************************************************
//	archive strings
	@synthesize rcFileDirStr, rcFilePathStr;

	#pragma mark -
	#pragma mark === Internal Methods ===
//	*********************************************************************************************************************************
- (id)init
{
    self = [super init];
    if (self) {
        aqRecordModelPtr = [[AQRecordModel alloc] init];
	//	init file directory
		rcFileDirStr = @"~/Music";
		rcFilePathStr = @"";
    }
    
    return self;
}

- (void)dealloc
{
	[aqRecordModelPtr release];
    [super dealloc];
}

	#pragma mark -
	#pragma mark === Action Methods ===
//	*********************************************************************************************************************************
- (IBAction)rcReadButtons:(id)sender
{
	NSLog(@"frReadButtons Started");
	BOOL	succes;
	
	switch([sender tag])
	{
		case 0:		//	browse
		[self rcSaveSoundFile];
		break;
		case 1:		//	start recording
		NSLog(@"rcFilePathStr: %@", rcFilePathStr);
		NSURL *	soundFileURL = [NSURL fileURLWithPath:rcFilePathStr];
		succes = [aqRecordModelPtr rmConfigureOutputFile:(CFURLRef)soundFileURL];
		if(succes == NO) {
			NSLog(@"ConfigureOutputFile failed");
		}
		succes = [aqRecordModelPtr rmStart];
		if(succes == YES) {
			[rcStartRec setEnabled:NO];
			[rcStopRec setEnabled:YES];
		} else {
			NSLog(@"Start Recording failed");
		}
            volumeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateLevel) userInfo:nil repeats:YES];
		break;
		case 2:		//	stop recording
		succes = [aqRecordModelPtr rmStop];
		if(succes == YES) {
			[rcBrowse  setEnabled:YES];
			[rcStartRec setEnabled:NO];
			[rcStopRec setEnabled:NO];
		} else {
			NSLog(@"Start Recording failed");
		}
            [volumeTimer invalidate], volumeTimer = nil;
		break;
	}
}

	#pragma mark -
	#pragma mark === Data Archive Methods ===
//	*********************************************************************************************************************************
- (void)rcSaveSoundFile
{
	NSLog(@"rcSaveSoundFile Start");
    NSSavePanel *	savePanel = [NSSavePanel savePanel];
	NSArray *		fileTypes = [NSArray arrayWithObjects:@"aiff",nil];
	
	[savePanel setAllowedFileTypes:fileTypes];
	[savePanel setMessage:@"Choose destination folder and file name for audio file"];
	[savePanel setPrompt:@"Select"];
	[savePanel setTreatsFilePackagesAsDirectories:NO];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setPrompt:@"Select"];
	[savePanel setDirectoryURL:[NSURL fileURLWithPath:rcFileDirStr isDirectory:YES]];
    [savePanel beginSheetModalForWindow:rcWindow completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            [savePanel orderOut:self];	//	close panel before we might present an error
			[rcBrowse  setEnabled:NO];
			[rcStartRec setEnabled:YES];
			[self setRcFilePathStr:[savePanel filename]];
			NSLog(@"fcFilePathStr: %@", rcFilePathStr);
        }
    }];
}

- (void)updateLevel
{
    if (aqRecordModelPtr->mQueue) {
        AudioQueueLevelMeterState state = {0};
        UInt32 size = sizeof(state);
        OSStatus st = AudioQueueGetProperty(aqRecordModelPtr->mQueue, kAudioQueueProperty_CurrentLevelMeter, &state, &size);
        NSLog(@"%d %f", st, state.mAveragePower);
        [self.volumeIndicator setFloatValue:state.mAveragePower * 10];
    }
}
@end
