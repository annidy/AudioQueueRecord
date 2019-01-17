//
//  AudioQueueRecordAppDelegate.m
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

#import "AudioQueueRecordAppDelegate.h"

@implementation AudioQueueRecordAppDelegate

//	*********************************************************************************************************************************
@synthesize window;

//	*********************************************************************************************************************************
- (void)windowWillClose:(NSNotification *)notification
{
		//	NSLog(@"windowWillClose Notification");
	NSString * windowName = [[notification object]title];
	
	if([windowName compare:@"Audio Queue Record"] == NSOrderedSame)
		{	
				//	if window closes we want the application to terminate (quit)
			NSApplication * application = [NSApplication sharedApplication];
			[application terminate:self];
		}
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
}


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
		//	save data
		//	NSLog(@"applicationShouldTerminate");
	
	return NSTerminateNow;	//	NSTerminateCancel;
}

@end
