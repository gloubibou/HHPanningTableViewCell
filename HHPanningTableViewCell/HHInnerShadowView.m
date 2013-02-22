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

@property (nonatomic, strong) CAShapeLayer *shadowLayer;

@end


@implementation HHInnerShadowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        [self setClipsToBounds:YES];
    }

    return self;
}


#pragma mark -
#pragma mark Accessors


#pragma mark -
#pragma mark Instance methods

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [self layoutShadowLayer];
    
    [super layoutSublayersOfLayer:layer];
}


- (void)layoutShadowLayer
{
    CGRect bounds = [self bounds];
    CAShapeLayer *shadowLayer = self.shadowLayer;

    if (! CGRectEqualToRect(bounds, [shadowLayer frame])) {
        [shadowLayer removeFromSuperlayer];

        // http://stackoverflow.com/questions/4431292/inner-shadow-effect-on-uiview-layer/11436615#11436615
        // Answered by Matt Wilding

        shadowLayer = [CAShapeLayer layer];

        [shadowLayer setFrame:bounds];

        // Standard shadow stuff
        [shadowLayer setShadowColor:[[UIColor blackColor] CGColor]];
        [shadowLayer setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [shadowLayer setShadowOpacity:1.0f];
        [shadowLayer setShadowRadius:10.0f];

        // Causes the inner region in to NOT be filled.
        [shadowLayer setFillRule:kCAFillRuleEvenOdd];

        // Create the larger rectangle path.
        CGMutablePathRef path = CGPathCreateMutable();

        CGPathAddRect(path, NULL, CGRectInset(bounds, -10.0f, -10.0f));

        // Add the inner path so it's subtracted from the outer path.
        // someInnerPath could be a simple bounds rect, or maybe
        // a rounded one for some extra fanciness.

        CGPathRef innerPath = [[UIBezierPath bezierPathWithRect:[shadowLayer bounds]] CGPath];

        CGPathAddPath(path, NULL, innerPath);
        CGPathCloseSubpath(path);

        [shadowLayer setPath:path];

        CGPathRelease(path);

        [shadowLayer setShouldRasterize:YES];
        
        [[self layer] insertSublayer:shadowLayer atIndex:0];

        self.shadowLayer = shadowLayer;
    }
}

@end
