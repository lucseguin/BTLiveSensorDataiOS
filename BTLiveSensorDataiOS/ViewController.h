//
//  ViewController.h
//  BTLiveSensorDataiOS
//
//  Created by Luc Seguin on 16-08-16.
//  Copyright © 2016 Luc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SerialGATT.h"

@interface ViewController : UIViewController<BTSmartSensorDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

@property (strong, nonatomic) SerialGATT *sensor;
@property (nonatomic, retain) NSMutableArray *peripheralViewControllerArray;
@end

