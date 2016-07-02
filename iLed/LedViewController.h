//
//  LedViewController.h
//  iLed
//
//  Created by Bui Duc Khanh on 7/1/16.
//  Copyright © 2016 Bui Duc Khanh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LedViewController : UIViewController

- (void) setParamBallRadius:(float) radius
          withViewPortWidth:(float) width
         withViewPortHeight:(float) height;

- (void) drawWithHorizontalMargin:(float) horizontalMargin
                   verticalMargin:(float) verticalMargin
                     numberOfRows:(int) rows
                  numberOfColumns:(int) columns;

- (void) setIsRunningLed: (Boolean)isRun
            withInterval: (float) interval
         withRunRowFirst: (Boolean)isRunRowFirst
    withRowIsLeftToRight: (Boolean)isRowLeftToRight
       withColIsUpToDown: (Boolean)isColUpToDown;
@end
