//
//  LedViewController.m
//  iLed
//
//  Created by Bui Duc Khanh on 7/1/16.
//  Copyright © 2016 Bui Duc Khanh. All rights reserved.
//

#import "LedViewController.h"

@interface LedViewController ()

@end

@implementation LedViewController
{
    float viewPortWidth;    // Width của vùng vẽ matrix led
    float viewPortHeight;   // Height của vùng vẽ matrix led
    float ballRadius;       // Bán kính của led
    
    int initialTag;         // Tag khởi tạo để tránh tag 0
    
    int ledRows;            // Số hàng matrix led
    int ledColumns;         // Số cột matrix led
    
    int startPointX;        // X của điểm khởi đầu chạy running led
    int startPointY;        // Y của điểm khởi đầu chạy running led
    
    int currentPointX;      // X của điểm led đang sáng
    int currentPointY;      // Y của điểm led đang sáng
    
    Boolean isRunningLed;   // Có bật led không
    
    Boolean isRowFirst;          // True: chạy theo hàng hết hàng chuyển cột
                                 // False: chạy theo cột, hết cột chuyển hàng
    
    Boolean isRowFromLeftToRight;  // True: hướng theo hàng từ trái qua phải
                            // False: hướng theo hàng từ phải qua trái
    
    Boolean isColumnFromUpToDown;   // True: hướng theo cột từ trên xuống dưới
                                    // False:hướng theo cột từ dưới lên trên
    
    
    NSTimer* _timer;        // Timer chạy led
    float timerInterval;         // Interval của timer
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Khởi tạo giao diện 1 chút
    self.title = @"Led Matrix";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    initialTag= 1000;
}


// Hàm khởi tạo các tham số vẽ ma trận led
- (void) setParamBallRadius:(float) radius
         withViewPortWidth:(float) width
         withViewPortHeight:(float) height
{
    ballRadius = radius;
    viewPortWidth = width;
    viewPortHeight = height;
}


// Hàm xoá ma trận led
- (void) clear{
    [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
}


// Hàm vẽ ma trận led
- (void) drawWithHorizontalMargin:(float) horizontalMargin
                   verticalMargin:(float) verticalMargin
                     numberOfRows:(int) rows
                  numberOfColumns:(int) columns
{
    // Xoá view cũ nếu có
    [self clear];
    
    // Lưu biến cho led chạy
    ledRows = rows;
    ledColumns = columns;
    
    // Tính vùng bao đóng cho 1 cái led
    float boundWidth = (viewPortWidth - 2.0*horizontalMargin)/columns;
    float boundHeight = (viewPortHeight - 2.0*verticalMargin)/rows;
    
    // Vẽ
    for (int i = 0; i < rows; i++)
        for (int j = 0; j < columns; j++)
        {
            UIImageView *ball = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Green"]];
            
            float x = horizontalMargin + boundWidth*(j + 0.5);
            float y = verticalMargin + boundHeight*(i + 0.5);
            int tag = initialTag + i*columns + j;
            
            ball.tag = tag;
            ball.center = CGPointMake(x, y);
            
            [self.view addSubview:ball];
        }
}

// Gán các tham số xem có chạy led không
- (void) setIsRunningLed: (Boolean)isRun
            withInterval: (float) interval
         withRunRowFirst: (Boolean)isRunRowFirst
    withRowIsLeftToRight: (Boolean)isRowLeftToRight
       withColIsUpToDown: (Boolean)isColUpToDown
{
    isRunningLed = isRun;
    timerInterval = interval;
    isRowFirst = isRunRowFirst;
    isRowFromLeftToRight = isRowLeftToRight;
    isColumnFromUpToDown = isColUpToDown;
    
    if (isRowFromLeftToRight)
        startPointX = 0;
    else
        startPointX = ledColumns - 1;
    
    if (isColumnFromUpToDown)
        startPointY = 0;
    else
        startPointY = ledRows - 1;
}


// Kiểm tra xem có chạy led không
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(isRunningLed)
    {
        // Gán led đang chạy hiện tại
        currentPointX = startPointX;
        currentPointY = startPointY;
        
        // Bật led cho start point lên
        [self toogleLedWithTag:(initialTag + currentPointY*ledColumns + currentPointX)];

        
        _timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(runningLed) userInfo:nil repeats:true];
    }
}


// Huỷ timer khi ẩn
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_timer != nil)
        [_timer invalidate];
    
    _timer = nil;
}


// Chạy led
- (void) runningLed{
    // Tắt led hiện tại
    [self toogleLedWithTag:(initialTag + currentPointY*ledColumns + currentPointX)];
    
    int newX = currentPointX;
    int newY = currentPointY;
    
    Boolean isColumnInLeftBoundary = (currentPointX == 0);
    Boolean isColumnInRightBoundary = currentPointX == (ledColumns -1);
    
    Boolean isRowBoundary = (isColumnFromUpToDown && (currentPointY == (ledRows - 1)))
                             || (!isColumnFromUpToDown && (currentPointY == 0));
    
    Boolean isRowInUpBoundary = (currentPointY == 0);
    Boolean isRowInDownBoundary = currentPointY == (ledRows -1);
    
    Boolean isColumnBoundary = (isRowFromLeftToRight && (currentPointX == (ledColumns - 1)))
    || (!isRowFromLeftToRight && (currentPointX == 0));
    
    
    
    if (// Nhóm newX = currentPointX + 1 bắt buộc chưa đến lề phải chiều hàng isRowFromLeftToRight
        // Chạy theo hàng
        (isRowFromLeftToRight && !isColumnInRightBoundary && isRowFirst)
        
        // Chạy theo cột chỉ tăng khi đến biên đổi cột
        || (isRowFromLeftToRight && !isColumnInRightBoundary && !isRowFirst && isRowBoundary)
        )
    {
        newX = currentPointX + 1;
    }
    else if (// Nhóm newX = currentPointX - 1 bắt buộc chưa đến lề trái chiều hàng !isRowFromLeftToRight
             // Nếu chạy theo hàng
             (!isRowFromLeftToRight && !isColumnInLeftBoundary && isRowFirst)
             
             // Chạy theo cột chỉ giảm khi đén biên đổi cột
             || (!isRowFromLeftToRight && !isColumnInLeftBoundary && !isRowFirst && isRowBoundary)
             )
    {
        newX = currentPointX - 1;
    }
    else if (isRowFromLeftToRight && isColumnInRightBoundary)
    {
        if (isRowFirst || isRowBoundary)
        {
            newX = 0;
        }
    }
    else if (!isRowFromLeftToRight && isColumnInLeftBoundary)
    {
        if (isRowFirst || isRowBoundary)
        {
            newX = ledColumns - 1;
        }
    }
    
    
    if (// Nhóm newY = currentPointY + 1 bắt buộc chưa đến lề dưới chiều hàng isColumnFromUpToDown
        // Chạy theo hàng
        (isColumnFromUpToDown && !isRowInDownBoundary && !isRowFirst)
        
        // Chạy theo cột chỉ tăng khi đến biên đổi cột
        || (isColumnFromUpToDown && !isRowInDownBoundary && isRowFirst && isColumnBoundary)
        )
    {
        newY = currentPointY + 1;
    }
    else if (// Nhóm newY = currentPointY - 1 bắt buộc chưa đến lề trên chiều hàng !isColumnFromUpToDown
             // Nếu chạy theo hàng
             (!isColumnFromUpToDown && !isRowInUpBoundary && !isRowFirst)
             
             // Chạy theo cột chỉ giảm khi đén biên đổi cột
             || (!isColumnFromUpToDown && !isRowInUpBoundary && isRowFirst && isColumnBoundary)
             )
    {
        newY = currentPointY - 1;
    }
    else if (isColumnFromUpToDown && isRowInDownBoundary)
    {
        if (!isRowFirst || isColumnBoundary)
        {
            newY = 0;
        }
    }
    else if (!isColumnFromUpToDown && isRowInUpBoundary)
    {
        if (!isRowFirst || isColumnBoundary)
        {
            newY = ledRows - 1;
        }
    }

    // Gán vị trí mới
    currentPointX = newX;
    currentPointY = newY;
    
    [self toogleLedWithTag:(initialTag + currentPointY*ledColumns + currentPointX)];
}


// Hàm đổi màu led
- (void) toogleLedWithTag: (int) tag
{
    UIView *led = [self.view viewWithTag:tag];
    
    if(led != nil && [led isKindOfClass:[UIImageView class]])
    {
        if ([((UIImageView*)led).image isEqual:[UIImage imageNamed:@"Green"]]) {
            // Correct. This technique compares the image data correctly.
            
            ((UIImageView*)led).image = [UIImage imageNamed:@"Red"];
        }
        else
        {
            ((UIImageView*)led).image = [UIImage imageNamed:@"Green"];
        }
        
    }
}

@end
