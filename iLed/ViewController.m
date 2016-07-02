//
//  ViewController.m
//  iLed
//
//  Created by Bui Duc Khanh on 7/1/16.
//  Copyright © 2016 Bui Duc Khanh. All rights reserved.
//

#import "ViewController.h"
#import "LedViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtHorizontalMargin;
@property (weak, nonatomic) IBOutlet UITextField *txtVerticalMargin;
@property (weak, nonatomic) IBOutlet UITextField *txtRows;
@property (weak, nonatomic) IBOutlet UITextField *txtColumn;
@property (weak, nonatomic) IBOutlet UILabel *lblNoteHorizontalMargin;
@property (weak, nonatomic) IBOutlet UILabel *lblNoteVerticalMargin;
@property (weak, nonatomic) IBOutlet UILabel *lblNoteRows;
@property (weak, nonatomic) IBOutlet UILabel *lblNoteColumns;
@property (weak, nonatomic) IBOutlet UISwitch *switchRunningLed;
@property (weak, nonatomic) IBOutlet UITextField *txtInterval;
@property (weak, nonatomic) IBOutlet UISwitch *switchIsRowFirst;
@property (weak, nonatomic) IBOutlet UISwitch *switchLeftToRight;
@property (weak, nonatomic) IBOutlet UISwitch *switchUpToDown;

@end

@implementation ViewController{
    float viewPortWidth;
    float viewPortHeight;
    float ballRadius;
    
    float maxHorizontalMargin;
    float maxVerticalMargin;
    float maxRows;
    float maxColumns;
    
    LedViewController* ledView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Validate chỉ nhập số
    self.txtHorizontalMargin.delegate = self;
    self.txtVerticalMargin.delegate = self;
    self.txtRows.delegate = self;
    self.txtColumn.delegate = self;
    
    
    // Khởi tạo hiệu chỉnh giao diện
    self.title = @"Led Builder";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // Test các kích thước
    NSLog(@"Navigation Y=%f   Height=%f", self.navigationController.navigationBar.frame.origin.y, self.navigationController.navigationBar.frame.size.height);
    
    NSLog(@"View size Width=%f  Height=%f",
          self.view.bounds.size.width, self.view.bounds.size.height);
    
    NSLog(@"View origin x=%f  y=%f",
          self.view.frame.origin.x, self.view.frame.origin.y);
    
    UIImageView *ball = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Green"]];
    
    NSLog(@"Ball Width=%f   Height=%f", ball.frame.size.width,
          ball.frame.size.height);
    
    // Lưu các biến
    viewPortWidth = self.view.bounds.size.width;
    
    viewPortHeight = self.view.bounds.size.height - self.navigationController.navigationBar.frame.origin.y - self.navigationController.navigationBar.frame.size.height;
    
    ballRadius = ball.frame.size.width / 2;
    
    // Khởi tạo ledview
    ledView = [LedViewController new];
    
    // Các giá trị cơ bản sẽ giống nhau nên gán view port và ball radius cho led view
    [ledView setParamBallRadius:ballRadius withViewPortWidth:viewPortWidth withViewPortHeight:viewPortHeight];
    
    // Tạo các thông báo về biên và giới hạn
    // Lề ngang
    maxHorizontalMargin = (viewPortWidth/2.0) - 2.0 * ballRadius;
    [self.lblNoteHorizontalMargin setText:[NSString stringWithFormat:@"(Trong khoảng 0 - %3.0f)", maxHorizontalMargin]];
    
    // Lề dọc
    maxVerticalMargin = (viewPortHeight/2.0) - 2.0 * ballRadius;
    [self.lblNoteVerticalMargin setText:[NSString stringWithFormat:@"(Trong khoảng 0 - %3.0f)", maxVerticalMargin]];
    
    // Số hàng
    maxRows = viewPortHeight/(2.0*ballRadius) - 1;
    [self.lblNoteRows setText:[NSString stringWithFormat:@"(Trong khoảng 1 - %3.0f)", maxRows]];
                                                                                     
    // Số cột
    maxColumns = viewPortWidth/(2.0*ballRadius) - 1;
    [self.lblNoteColumns setText:[NSString stringWithFormat:@"(Trong khoảng 1 - %3.0f)", maxColumns]];

}

- (IBAction)onDrawLed:(id)sender {
    float horizontalMargin = [self.txtHorizontalMargin.text floatValue];
    float verticalMargin = [self.txtVerticalMargin.text floatValue];
    int rows = [self.txtRows.text intValue];
    int columns = [self.txtColumn.text intValue];
    
    
    // Kiểm tra điều kiện cơ bản nhất
    if (!(horizontalMargin >= 0 && horizontalMargin <= maxHorizontalMargin)
        || !(verticalMargin >= 0 && verticalMargin <= maxVerticalMargin)
        || !(rows >= 1 && rows <= maxRows)
        || !(columns >= 1 && columns <= maxColumns))
    {
        
        
        UIAlertController * alert2 = [UIAlertController
                                        alertControllerWithTitle:@"Lỗi"
                                        message:@"Nhập giá trị lỗi, hãy xem ghi chú và kiểm tra lại giá trị"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                    }];
        
        [alert2 addAction:okButton];
        
        [self presentViewController:alert2 animated:YES completion:nil];
        
    }
    // Kiểm tra xem giá trị nhập vào có dài quá mức bề ngang để hiển thị không
    else if (viewPortWidth < (2.0 * horizontalMargin + 2.0 * ballRadius * columns))
    {
        UIAlertView* alert = [[UIAlertView alloc]       initWithTitle:@"Lỗi"
                                                        message:@"Kích thước vượt quá chiều rộng. Hãy giảm số cột hoặc lề ngang"
                                                        delegate:self
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil, nil];
        
        [alert show];
    }
    // Kiểm tra xem giá trị nhập vào có dài quá mức bề ngang để hiển thị không
    else if (viewPortHeight < (2.0 * verticalMargin + 2.0 * ballRadius * rows))
    {
        UIAlertView* alert = [[UIAlertView alloc]       initWithTitle:@"Lỗi"
                                                              message:@"Kích thước vượt quá chiều cao. Hãy giảm số dòng hoặc lề dọc"
                                                             delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil, nil];
        
        [alert show];
    }
        
    else
    {
        // Vẽ led matrix
        [ledView drawWithHorizontalMargin:horizontalMargin verticalMargin:verticalMargin numberOfRows:rows numberOfColumns:columns];
        
        // Tham số chạy led;
        Boolean isRunningLed = self.switchRunningLed.on;
        float interval= [self.txtInterval.text floatValue];
        Boolean isRowFirst = self.switchIsRowFirst.on;
        Boolean isLeftToRight = self.switchLeftToRight.on;
        Boolean isUpToDown = self.switchUpToDown.on;
        
        // Gán tham số chạy led
        [ledView setIsRunningLed:isRunningLed withInterval:interval withRunRowFirst:isRowFirst withRowIsLeftToRight:isLeftToRight withColIsUpToDown:isUpToDown];

        
        [self.navigationController pushViewController:ledView animated:YES];
    }
}


// Hàm này kế thừa từ interface UITextFieldDelegate validate chỉ cho các text field nhập số
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0) || [string isEqualToString:@""];
}

// Ẩn keyboard đi khi ấn return
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // 2 lệnh dưới để ẩn keyboard
    [textField resignFirstResponder];
    return YES; // want to hide keyboard
}

@end
