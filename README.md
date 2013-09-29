# HHPanningTableViewCell - Swipe to reveal

HHPanningTableViewCell is a UITableViewCell implementing "swipe to reveal" a drawer view. Such a view typically holds action buttons applying to the current row.

This behavior is seen in a number of iOS applications. To my knowledge the idea was pioneered by Loren Brichter for Tweetie (aka Twitter for iPhone).

The HHPanningTableViewCell implementation was written for the [ACTPrinter 4.0 application](https://itunes.apple.com/app/actprinter-virtual-printer/id296083171?mt=8).
The code presented here is identical to the one used in the shipped product.

## Features

* Swipe to reveal implemented using gesture recognizer
* Live tracking of swipe to progressively reveal drawer
* Options to allow for swiping to left or right only
* Bounce animation when hiding drawer
* Foreground view casts shadow on drawer when moved aside

## Requirements

* iOS 6.1 or later. Including 7.0 (Tag 1.0.0 did support iOS 5.1)
* ARC memory management

## Usage

* Copy the following to your project:
    * HHDirectionPanGestureRecognizer.h
    * HHDirectionPanGestureRecognizer.m
    * HHInnerShadowView.h
    * HHInnerShadowView.m
    * HHPanningTableViewCell.h
    * HHPanningTableViewCell.m
* Use HHPanningTableViewCell instances for your table cells
* Set a panning direction mask on the cells
* Provide a drawer view for the cells
* Optionally, implement the HHPanningTableViewCellDelegate method to trigger your own custom action.
* Refer to the demo application for details

## License

This code is made available under the terms of the BSD license as included in the source files.
