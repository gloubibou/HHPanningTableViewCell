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

#import "HHInnerShadowView.h"

#import <QuartzCore/QuartzCore.h>


@interface HHInnerShadowView ()

@end


@implementation HHInnerShadowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark -
#pragma mark Accessors


#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect
{
	// http://stackoverflow.com/questions/4431292/inner-shadow-effect-on-uiview-layer
	
	CGRect bounds = [self bounds];
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Create the shape of the shadow
	CGMutablePathRef visiblePath = CGPathCreateMutable();
	CGPathAddRect(visiblePath, NULL, bounds);
	
	[[UIColor clearColor] setFill];
	
	CGContextAddPath(context, visiblePath);
	CGContextFillPath(context);
	
	// Now create a larger rectangle, which we're going to subtract the visible path from and apply a shadow
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, CGRectInset(bounds, -10.0, -10.0));
	
	// Add the visible path (so that it gets subtracted for the shadow)
	CGPathAddPath(path, NULL, visiblePath);
	CGPathCloseSubpath(path);
	
	// Add the visible paths as the clipping path to the context
	CGContextAddPath(context, visiblePath);
	CGContextClip(context);
	
	// Now setup the shadow properties on the context
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 10.0f, [[UIColor blackColor] CGColor]);
	
	// Now fill the rectangle, so the shadow gets drawn
	[[UIColor blackColor] setFill];
	
	CGContextSaveGState(context);
	CGContextAddPath(context, path);
	CGContextEOFillPath(context);
	
	// Release the paths
	CGPathRelease(path);
	CGPathRelease(visiblePath);
}

@end
