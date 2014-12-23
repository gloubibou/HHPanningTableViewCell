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

#import "TableViewController.h"

#import "HHPanningTableViewCell.h"


@interface TableViewController () {
    NSUInteger _numberOfItems;
}

@property (nonatomic, retain) NSArray *rowTitles;
@property (nonatomic, assign) NSUInteger numberOfItems;

@end


@implementation TableViewController

@synthesize numberOfItems = _numberOfItems;
#pragma mark -
#pragma mark Initialization

- (id)init
{
	self = [super initWithNibName:@"TableViewController" bundle:nil];
	
	if (self != nil) {
		self.rowTitles = [NSArray arrayWithObjects:@"Pan direction: None", @"Pan direction: Right", @"Pan direction: Left", @"Pan direction: Both", @"Custom trigger", nil];
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self
                           action:@selector(dropViewDidBeginRefreshing:)
                 forControlEvents:UIControlEventValueChanged];

        self.refreshControl = refreshControl;
        
        self.numberOfItems = 250;
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark -
#pragma mark Accessors

@synthesize rowTitles = _rowTitles;


#pragma mark -
#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.numberOfItems;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    HHPanningTableViewCell *cell = (HHPanningTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSInteger directionMask = indexPath.row % 5;

	if (cell == nil) {
		cell = [[HHPanningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											  reuseIdentifier:CellIdentifier];
			
		UIView *drawerView = [[UIView alloc] initWithFrame:cell.frame];
		
		drawerView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
		
		cell.drawerView = drawerView;
	}

    if (directionMask < 3) {
        cell.directionMask = directionMask;
    }
    else {
        cell.directionMask = HHPanningTableViewCellDirectionLeft + HHPanningTableViewCellDirectionRight;

        if (directionMask == 4) {
            cell.delegate = self;
        }
    }

	cell.textLabel.text = [self.rowTitles objectAtIndex:directionMask];

    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	if ([cell isKindOfClass:[HHPanningTableViewCell class]]) {
		HHPanningTableViewCell *panningTableViewCell = (HHPanningTableViewCell*)cell;
		
		if ([panningTableViewCell isDrawerRevealed]) {
			return nil;
		}
	}
	
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//
//	if ([cell isKindOfClass:[HHPanningTableViewCell class]]) {
//		HHPanningTableViewCell *panningTableViewCell = (HHPanningTableViewCell*)cell;
//
//		[panningTableViewCell setDrawerRevealed:YES animated:YES];
//	}

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark HHPanningTableViewCellDelegate

- (void)panningTableViewCell:(HHPanningTableViewCell *)cell didTriggerWithDirection:(HHPanningTableViewCellDirection)direction
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Custom Action"
                                                    message:@"You triggered a custom action"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UIRefreshControl delegate
-(void) dropViewDidBeginRefreshing:(id) sender
{
    //Add 10 cells
    self.numberOfItems += 10;
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NSUInteger i=0; i<10; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPaths addObject:indexPath];
    }
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.refreshControl endRefreshing];
}


@end
