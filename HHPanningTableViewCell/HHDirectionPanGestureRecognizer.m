/*
 * Copyright (c) 2012, Pierre Bernard & Houdah Software s.à r.l.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the <organization> nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#import "HHDirectionPanGestureRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>


static CGFloat const kDirectionPanThreshold = 5.0;


@interface HHDirectionPanGestureRecognizer ()

@property (nonatomic, assign) BOOL panRecognized;

@end


@implementation HHDirectionPanGestureRecognizer

#pragma mark -
#pragma mark Initialization

- (id)initWithTarget:(id)target action:(SEL)action
{
	self = [super initWithTarget:target action:action];
	
	if (self != nil) {
		self.direction = HHDirectionPanGestureRecognizerHorizontal;
	}
	
	return self;
}


#pragma mark -
#pragma mark Accessors

@synthesize direction = _direction;
@synthesize panRecognized = _panRecognized;


#pragma mark -
#pragma mark Instance methods

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
	
    if (self.state == UIGestureRecognizerStateFailed) {
		return;
	}
	
	if (!self.panRecognized) {
		HHDirectionPangestureRecognizerDirection direction = self.direction;
		CGPoint translation = [self translationInView:self.view];
		
		if (fabsf(translation.x) > kDirectionPanThreshold) {
            if (direction == HHDirectionPangestureRecognizerVertical) {
                self.state = UIGestureRecognizerStateFailed;
            }
			else {
                self.panRecognized = YES;
            }
		}
		else if (fabsf(translation.y) > kDirectionPanThreshold) {
			if (direction == HHDirectionPanGestureRecognizerHorizontal) {
				self.state = UIGestureRecognizerStateFailed;
			}
			else {
				self.panRecognized = YES;
			}
		}
	}
}

- (void)reset
{
    [super reset];
    
	self.panRecognized = NO;
}

@end
