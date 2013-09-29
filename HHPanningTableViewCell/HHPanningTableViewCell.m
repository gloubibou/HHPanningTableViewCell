/*
 * Copyright (c) 2012-2013, Pierre Bernard & Houdah Software s.à r.l.
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

#import "HHPanningTableViewCell.h"

#import "HHDirectionPanGestureRecognizer.h"
#import "HHInnerShadowView.h"

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>


#define HH_PANNING_ANIMATION_DURATION	0.1f
#define HH_PANNING_BOUNCE_DISTANCE		10.0f
#define HH_PANNING_MINIMUM_PAN			50.0f
#define HH_PANNING_MAXIMUM_PAN			0.0f	// Set to 0.0f for full view width
#define HH_PANNING_TRIGGER_OFFSET		100.0f
#define HH_PANNING_SHADOW_INSET			-10.0f
#define HH_PANNING_USE_VELOCITY			YES


@interface HHPanningTableViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, assign, getter = isDrawerRevealed) BOOL		drawerRevealed;
@property (nonatomic, assign, getter = isAnimationInProgress) BOOL	animationInProgress;

@property (nonatomic, strong) UIView								*shadowView;
@property (nonatomic, strong) UIPanGestureRecognizer				*panGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer				*drawerPanGestureRecognizer;
@property (nonatomic, assign) CGFloat								translation;
@property (nonatomic, assign) CGFloat								initialTranslation;
@property (nonatomic, assign) HHPanningTableViewCellDirection		panDirection;
@property (nonatomic, assign, getter = isPanning) BOOL				panning;

- (void)panningTableViewCellInit;

- (UIView *)createShadowView;
- (UIPanGestureRecognizer *)createPanGesureRecognizer;

- (void)setDrawerRevealed:(BOOL)revealed direction:(HHPanningTableViewCellDirection)direction animated:(BOOL)animated;

@end


static NSString *const												kDrawerRevealedContext	= @"drawerRevealed";
static NSString *const												kTranslationContext		= @"translation";


@implementation HHPanningTableViewCell

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

	if (self != nil) {
		[self panningTableViewCellInit];
	}

	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];

	if (self != nil) {
		[self panningTableViewCellInit];
	}

	return self;
}

- (void)panningTableViewCellInit
{
	self.panGestureRecognizer		= [self createPanGesureRecognizer];
	self.drawerPanGestureRecognizer = [self createPanGesureRecognizer];

	[self addGestureRecognizer:self.panGestureRecognizer];
	[self.drawerView addGestureRecognizer:self.drawerPanGestureRecognizer];

	self.directionMask				= 0;
	self.shouldBounce				= YES;

	self.minimumPan					= HH_PANNING_MINIMUM_PAN;
	self.maximumPan					= HH_PANNING_MAXIMUM_PAN;

	[self addObserver:self forKeyPath:@"drawerRevealed" options:0 context:(__bridge void *)kDrawerRevealedContext];
	[self addObserver:self forKeyPath:@"translation" options:0 context:(__bridge void *)kTranslationContext];
}

- (void)awakeFromNib
{
	if ([super respondsToSelector:@selector(awakeFromNib)]) {
		[super awakeFromNib];
	}
}

- (void)prepareForReuse
{
	[super prepareForReuse];

	self.delegate				= nil;

	[self setDrawerRevealed:NO animated:NO];

	self.directionMask			= 0;
	self.shouldBounce			= YES;

	self.drawerRevealed			= NO;
	self.animationInProgress	= NO;

	self.translation			= 0.0f;
	self.initialTranslation		= 0.0f;
	self.panning				= NO;
}

- (UIView *)createShadowView
{
	CGRect	shadowFrame = CGRectInset([self bounds], HH_PANNING_SHADOW_INSET, 0.0f);
	UIView	*shadowView = [[HHInnerShadowView alloc] initWithFrame:shadowFrame];

	[shadowView setOpaque:NO];
	[shadowView setUserInteractionEnabled:NO];
	[shadowView setAutoresizesSubviews:YES];
	[shadowView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

	return shadowView;
}

- (UIPanGestureRecognizer *)createPanGesureRecognizer
{
	HHDirectionPanGestureRecognizer *gestureRecognizer = [[HHDirectionPanGestureRecognizer alloc] initWithTarget:self
																										  action:@selector(gestureRecognizerDidPan:)];

	gestureRecognizer.direction = HHDirectionPanGestureRecognizerHorizontal;
	gestureRecognizer.delegate	= self;

	return gestureRecognizer;
}

#pragma mark -
#pragma mark Finalization

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"drawerRevealed" context:(__bridge void *)kDrawerRevealedContext];
	[self removeObserver:self forKeyPath:@"translation" context:(__bridge void *)kTranslationContext];
}

#pragma mark -
#pragma mark Accessors

- (void)setDrawerView:(UIView *)drawerView
{
	UIPanGestureRecognizer *drawerPanGestureRecognizer = self.drawerPanGestureRecognizer;

	[_drawerView removeGestureRecognizer:drawerPanGestureRecognizer];
	[drawerView addGestureRecognizer:drawerPanGestureRecognizer];

	_drawerView = drawerView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == (__bridge void *)kDrawerRevealedContext) {
		if (self.drawerRevealed) {
			UITableView *tableView = [self superTableView];

			for (UITableViewCell *cell in [tableView visibleCells]) {
				if ((cell != self) && [cell isKindOfClass:[HHPanningTableViewCell class]]) {
					[(HHPanningTableViewCell *)cell setDrawerRevealed : NO animated : YES];
				}
			}
		}
	}
	else if (context == (__bridge void *)kTranslationContext) {
		UIView				*shadowView			= self.shadowView;
		CGRect				shadowBounds		= [shadowView bounds];

		CGFloat				translation			= self.translation;
		CGFloat				shadowTranslation	= translation;

		if (translation > 0.0f) {
			shadowTranslation -= shadowBounds.size.width + HH_PANNING_SHADOW_INSET;
		}
		else {
			shadowTranslation += shadowBounds.size.width + HH_PANNING_SHADOW_INSET;
		}

		CGAffineTransform	transform			= CGAffineTransformMakeTranslation(translation, 0.0f);
		CGAffineTransform	shadowTransform		= CGAffineTransformMakeTranslation(shadowTranslation, 0.0f);

		self.transform			= transform;
		shadowView.transform	= shadowTransform;
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark -
#pragma mark API

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:(highlighted && (! [self isDrawerRevealed])) animated:animated];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
{
	if (editing && [self isDrawerRevealed]) {
		[self setDrawerRevealed:NO animated:NO];
	}

	[super setEditing:editing animated:animated];
}

- (void)setDrawerRevealed:(BOOL)revealed animated:(BOOL)animated
{
	NSInteger directionMask = self.directionMask;

	if (HHPanningTableViewCellDirectionRight & directionMask) {
		[self setDrawerRevealed:revealed direction:HHPanningTableViewCellDirectionRight animated:animated];
	}
	else if (HHPanningTableViewCellDirectionLeft & directionMask) {
		[self setDrawerRevealed:revealed direction:HHPanningTableViewCellDirectionLeft animated:animated];
	}
}

- (void)setDrawerRevealed:(BOOL)revealed direction:(HHPanningTableViewCellDirection)direction animated:(BOOL)animated
{
	if ([self isEditing] || (self.drawerView == nil)) {
		return;
	}

	self.drawerRevealed = revealed;

	UIView	*drawerView		= self.drawerView;
	UIView	*shadowView		= self.shadowView;
	UIView	*contentView	= self.contentView;

	CGFloat duration		= animated ? HH_PANNING_ANIMATION_DURATION : 0.0f;

	if (revealed) {
		CGRect	bounds		= [contentView frame];
		CGFloat translation = 0.0f;

		if (direction == HHPanningTableViewCellDirectionRight) {
			translation = bounds.size.width;
		}
		else {
			translation = -bounds.size.width;
		}

		[self installViews];

		self.animationInProgress = YES;

		void	(^animations)(void) = ^{
			self.translation = translation;
		};

		void	(^completion)(BOOL finished) = ^(BOOL finished) {
			self.animationInProgress = NO;
		};

		if (animated) {
			[UIView animateWithDuration:HH_PANNING_ANIMATION_DURATION
								  delay:0.0f
								options:UIViewAnimationOptionCurveEaseOut
							 animations:animations
							 completion:completion];
		}
		else {
			animations();
			completion(YES);
		}
	}
	else {
		void	(^animations)(void) = ^{
			self.translation = 0.0f;
		};

		self.animationInProgress = YES;

		void	(^completion)(BOOL finished) = ^(BOOL finished) {
			[drawerView removeFromSuperview];
			[shadowView removeFromSuperview];

			self.animationInProgress = NO;
		};

		if (animated) {
			BOOL shouldBounce = self.shouldBounce;

			if (shouldBounce) {
				CGFloat bounceDuration		= duration;
				CGFloat translation			= self.translation;
				CGFloat bounceMultiplier	= fminf(fabsf(translation / HH_PANNING_TRIGGER_OFFSET), 1.0f);
				CGFloat bounceTranslation	= bounceMultiplier * HH_PANNING_BOUNCE_DISTANCE;

				if (translation < 0.0f) {
					bounceTranslation *= -1.0;
				}

				[UIView animateWithDuration:duration
									  delay:0.0f
									options:UIViewAnimationOptionCurveEaseOut
								 animations:animations
								 completion:^(BOOL finished) {
									 [UIView animateWithDuration:bounceDuration
														   delay:0.0f
														 options:UIViewAnimationOptionCurveLinear
													  animations:^{
														  self.translation = bounceTranslation;
													  } completion:^(BOOL finished) {
														  [UIView animateWithDuration:bounceDuration
																				delay:0.0f
																			  options:UIViewAnimationOptionCurveLinear
																		   animations:animations
																		   completion:completion];
													  }];
								 }];
			}
			else {
				[UIView animateWithDuration:duration
									  delay:0.0f
									options:UIViewAnimationOptionCurveEaseOut
								 animations:animations
								 completion:completion];
			}
		}
		else {
			animations();
			completion(YES);
		}
	}
}

#pragma mark -
#pragma mark Gesture recognizer

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	BOOL shouldReceiveTouch = (! self.animationInProgress) && (! self.editing) && (self.drawerView != nil);

	if (shouldReceiveTouch) {
		UITableView *tableView = (id)[self superTableView];

		shouldReceiveTouch = ! (tableView.isDragging || tableView.isDecelerating);
	}

	if (shouldReceiveTouch) {
		id <HHPanningTableViewCellDelegate> delegate = self.delegate;

		if ([delegate respondsToSelector:@selector(panningTableViewCell:shouldReceivePanningTouch:)]) {
			shouldReceiveTouch = [delegate panningTableViewCell:self shouldReceivePanningTouch:touch];
		}
	}

	return shouldReceiveTouch;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	if ([gestureRecognizer isKindOfClass:[HHDirectionPanGestureRecognizer class]]) {
		HHDirectionPanGestureRecognizer *panGestureRecognizer = (HHDirectionPanGestureRecognizer *)gestureRecognizer;

		return !panGestureRecognizer.panRecognized;
	}

	return YES;
}

- (void)gestureRecognizerDidPan:(UIPanGestureRecognizer *)gestureRecognizer
{
	if (self.animationInProgress) {
		return;
	}

	UIGestureRecognizerState	state				= gestureRecognizer.state;
	CGPoint						translationInView	= [gestureRecognizer translationInView:self];

	if (state == UIGestureRecognizerStateBegan) {
		[self installViews];

		[self setSelected:NO];

		self.initialTranslation = self.translation;
		self.panning			= NO;
	}
	else if (state == UIGestureRecognizerStateChanged) {
		CGFloat		translation		= self.translation;
		CGFloat		totalPan		= translation + translationInView.x;

		if (!self.panning) {
			if (fabsf(totalPan) <= self.minimumPan) {
				return;
			}
			else {
				self.panning = YES;
			}
		}

		[gestureRecognizer setTranslation:CGPointZero inView:self];

		CGFloat		pan				= totalPan;
		CGFloat		maximumPan		= self.maximumPan;

		if (maximumPan <= 0.0f) {
			maximumPan = self.bounds.size.width;
		}

		NSInteger	directionMask	= self.directionMask;

		if (directionMask & HHPanningTableViewCellDirectionLeft) {
			if ((pan + maximumPan) < 0.0f) {
				pan = -maximumPan;
			}
		}
		else {
			pan = MAX(pan, 0.0f);
		}

		if (directionMask & HHPanningTableViewCellDirectionRight) {
			if (pan > maximumPan) {
				pan = maximumPan;
			}
		}
		else {
			pan = MIN(pan, 0.0f);
		}

		self.translation = pan;
	}
	else if ((state == UIGestureRecognizerStateEnded) || (state == UIGestureRecognizerStateCancelled)) {
		BOOL								drawerRevealed		= self.drawerRevealed;
		BOOL								drawerWasRevealed	= drawerRevealed;

		id <HHPanningTableViewCellDelegate> delegate			= self.delegate;
		BOOL								isDelegateTrigger	= [delegate respondsToSelector:@selector(panningTableViewCell:didTriggerWithDirection:)];

		CGFloat								translation			= self.translation;
		CGFloat								initialTranslation	= self.initialTranslation;
		CGFloat								deltaPan			= translation - initialTranslation;

		if (deltaPan == 0) {
			return;
		}

		BOOL								isOffsetRight		= (initialTranslation > 0.0);
		HHPanningTableViewCellDirection		panDirection		= (deltaPan > 0.0f) ? HHPanningTableViewCellDirectionRight : HHPanningTableViewCellDirectionLeft;
		NSInteger							directionMask		= self.directionMask;

		if (drawerRevealed) {
			directionMask = isOffsetRight ?  HHPanningTableViewCellDirectionLeft : HHPanningTableViewCellDirectionRight;
		}

		if (panDirection & directionMask) {
			CGFloat triggerOffset = HH_PANNING_TRIGGER_OFFSET;

			if (fabsf(translation) > triggerOffset) {
				drawerRevealed = !drawerRevealed;
			}
			else if (HH_PANNING_USE_VELOCITY) {
				CGFloat velocity = [gestureRecognizer velocityInView:self].x;

				if (fabsf(velocity) > triggerOffset) {
					drawerRevealed = !drawerRevealed;
				}
			}
		}

		HHPanningTableViewCellDirection direction = panDirection;

		if (drawerRevealed == drawerWasRevealed) {
			direction = isOffsetRight ? HHPanningTableViewCellDirectionRight : HHPanningTableViewCellDirectionLeft;
		}

		if (isDelegateTrigger && (drawerRevealed != drawerWasRevealed)) {
			[self setDrawerRevealed:NO direction:direction animated:YES];

			[delegate panningTableViewCell:self didTriggerWithDirection:panDirection];
		}
		else {
			[self setDrawerRevealed:drawerRevealed direction:direction animated:YES];
		}

		self.panning = NO;

		[gestureRecognizer setTranslation:CGPointZero inView:self];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	[self placeViews];
}

- (void)placeViews
{
	UIView	*drawerView = self.drawerView;

	CGRect	bounds		= [self bounds];
	CGPoint center		= [self center];

	[drawerView setBounds:bounds];
	[drawerView setCenter:center];

	UIView	*shadowView = self.shadowView;

	[shadowView setCenter:center];
}

- (void)installViews
{
	UIView	*superview	= self.superview;

	UIView	*drawerView = self.drawerView;
	UIView	*shadowView = self.shadowView;

	if (shadowView == nil) {
		shadowView		= [self createShadowView];

		self.shadowView = shadowView;
	}

	[self placeViews];

	[superview insertSubview:shadowView belowSubview:self];
	[superview insertSubview:drawerView belowSubview:shadowView];
}

- (UITableView *)superTableView
{
	UIView *superview = self.superview;

	while (superview != nil) {
		if ([superview isKindOfClass:[UITableView class]]) {
			return (id)superview;
		}

		superview = [superview superview];
	}

	return nil;
}

@end
