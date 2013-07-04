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

#import <UIKit/UIKit.h>


@class HHPanningTableViewCell;
@protocol HHPanningTableViewCellDelegate;


typedef enum {
	HHPanningTableViewCellDirectionRight = UISwipeGestureRecognizerDirectionRight,
	HHPanningTableViewCellDirectionLeft = UISwipeGestureRecognizerDirectionLeft,
} HHPanningTableViewCellDirection;


@interface HHPanningTableViewCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;


@property (nonatomic, strong)	IBOutlet	UIView*								drawerView;

@property (nonatomic, assign)				NSInteger							directionMask;
@property (nonatomic, assign)				BOOL								shouldBounce;
@property (nonatomic, assign)				CGFloat								minimumPan;
@property (nonatomic, assign)				CGFloat								maximumPan;
@property (nonatomic, assign)				CGFloat								revealDistance;
@property (nonatomic, weak)                 id<HHPanningTableViewCellDelegate>  delegate;

- (BOOL)isDrawerRevealed;
- (void)setDrawerRevealed:(BOOL)revealed animated:(BOOL)animated;

@end


@protocol HHPanningTableViewCellDelegate <NSObject>

@optional

- (BOOL)panningTableViewCell:(HHPanningTableViewCell *)cell shouldReceivePanningTouch:(UITouch*)touch;

// If implemented this this will be triggered instead of fully revealing
- (void)panningTableViewCell:(HHPanningTableViewCell *)cell didTriggerWithDirection:(HHPanningTableViewCellDirection)direction;

@end
