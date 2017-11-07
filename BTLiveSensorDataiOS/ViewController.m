//
//  ViewController.m
//  BTLiveSensorDataiOS
//
//  Created by Luc Seguin on 16-08-16.
//  Copyright © 2016 Luc. All rights reserved.
//

#import "ViewController.h"
#import "DeviceGridView.h"
#import "GraphView.h"
#import "DirectionGraph.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UITextView *logView;
@property (weak, nonatomic) IBOutlet GraphView *graphParentView;
@property (weak, nonatomic) IBOutlet GraphView *velocityGraphView;
@property (weak, nonatomic) IBOutlet DirectionGraph *directionGraph;
@property (weak, nonatomic) IBOutlet UIButton *recenterBtn;

@property (weak, nonatomic) IBOutlet UIButton *btnScanConnect;
@property (weak, nonatomic) IBOutlet UIButton *btnConnect;
@property (weak, nonatomic) IBOutlet UIButton *bntInfo;

@property (weak, nonatomic) IBOutlet UIPickerView *btDeviceListView;
@property (weak, nonatomic) IBOutlet UILabel *xPosLabel;
@property (weak, nonatomic) IBOutlet UILabel *yPosLabel;

@property (weak, nonatomic) IBOutlet DeviceGridView *deviceGridView;
@property (weak, nonatomic) IBOutlet UIImageView *imgState;
@property (weak, nonatomic) IBOutlet UILabel *lblCompassDegree;
@property (weak, nonatomic) IBOutlet UIImageView *compassImg;
@end

#define COMPASS_OFFSET 2.915
@implementation ViewController
{
    NSMutableString *msgBuffer;
    int fixedHeading;
    float lastXpos;
    float lastYpos;
    bool bleInit;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.btDeviceListView.dataSource = self;
    self.btDeviceListView.delegate = self;
    
    self.sensor = [[SerialGATT alloc] init];
    [self.sensor setup];
    self.sensor.delegate = self;
    
    self.peripheralViewControllerArray = [[NSMutableArray alloc] init];
    
    self.deviceGridView.deviceXpos = 0;
    self.deviceGridView.deviceYpos = 0;
    self.deviceGridView.connected = false;
    
    bleInit = false;
    lastXpos = 0.0;
    lastYpos = 0.0;
    msgBuffer = [NSMutableString string];
}

- (void) peripheralFound:(CBPeripheral *)peripheral {
    [self.peripheralViewControllerArray addObject:peripheral];
    [self.btDeviceListView reloadAllComponents];
}
-(void) serialGATTCharValueUpdated:(NSString *)UUID value:(NSData *)data
{
    NSString *value = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    [msgBuffer appendString:value];
    
    NSString * msg = nil;
    //; is the message terminator
    NSRange range = [msgBuffer rangeOfString:@";"];
    if (range.location != NSNotFound)
    {
        msg = [msgBuffer substringToIndex:range.location];
        
        range.length = range.location + 1;
        range.location = 0;

        [msgBuffer setString:[msgBuffer stringByReplacingCharactersInRange:range withString:@""]];
    }
    
    if (msg != nil) {
        if([msg hasPrefix:@"init:"] && msg.length <= 8) {
            bleInit = true;
            const char *cString = [msg UTF8String];
            sscanf(cString, "init:%d",&fixedHeading);
            self.directionGraph.fixedHeading = fixedHeading;
            self.lblCompassDegree.text = [NSString stringWithFormat:@"Direction : %dº", fixedHeading];
            self.logView.text= [self.logView.text stringByAppendingString:@"BLE Device Initialized\r\n"];
            self.deviceGridView.connected = true;
            self.recenterBtn.enabled = TRUE;
        } else if([msg hasPrefix:@"upd:"] && bleInit && msg.length <= 59) {
            const char *cString = [msg UTF8String];
            int heading;
            float ax;
            float ay;
            float vx;
            float vy;
            float xDisplacement;
            float yDisplacement;
            
            sscanf(cString, "upd:%d,%f,%f,%f,%f,%f,%f",&heading, &ax, &ay, &vx, &vy, &xDisplacement, &yDisplacement);
            self.directionGraph.currentHeading = heading;
            [self.directionGraph setNeedsDisplay];
            
            [self.graphParentView addDataX:ax Y:ay];
            [self.velocityGraphView addDataX:vx Y:vy];
            
            [self.graphParentView setNeedsDisplay];
            [self.velocityGraphView setNeedsDisplay];
            
//            float angleAdjust = (heading - fixedHeading);
//            float xDisp = xDisplacement*cos(angleAdjust) + yDisplacement*sin(angleAdjust);
//            float yDisp = yDisplacement*cos(angleAdjust) + xDisplacement*sin(angleAdjust);
//
//            self.deviceGridView.deviceXpos += xDisp;
//            self.deviceGridView.deviceYpos += yDisp;
//
            self.deviceGridView.deviceXpos += xDisplacement;
            self.deviceGridView.deviceYpos += yDisplacement;
            
            [self.deviceGridView setNeedsDisplay];
            self.lblCompassDegree.text = [NSString stringWithFormat:@"Direction : %dº", heading];
        }  else if ([msg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0){
            NSMutableString *message = [NSMutableString string];
            [message appendString:msg];
            [message appendString:@"\r\n"];
            self.logView.text= [self.logView.text stringByAppendingString:message];
        }
    }
}
- (void) setConnect{
    self.imgState.image = [UIImage imageNamed:@"connected"];
    
    NSMutableString *message = [NSMutableString string];
    CFStringRef s = CFUUIDCreateString(NULL, (__bridge CFUUIDRef )self.sensor.activePeripheral.identifier);
    [message appendString:@"------------------------------------\r\n"];
    [message appendString:@"Peripheral Info :\r\n"];
    [message appendString:[NSString stringWithFormat:@"UUID : %s\r\n",CFStringGetCStringPtr(s, 0)]];
    [message appendString:[NSString stringWithFormat:@"RSSI : %d\r\n",[self.sensor.activePeripheral.RSSI intValue]]];
    [message appendString:[NSString stringWithFormat:@"Name : %s\r\n",[self.sensor.activePeripheral.name cStringUsingEncoding:NSStringEncodingConversionAllowLossy]]];
    [message appendString:[NSString stringWithFormat:@"isConnected : %d\r\n",self.sensor.activePeripheral.state == CBPeripheralStateConnected]];
    [message appendString:@"-------------------------------------\r\n"];
    
    self.logView.text= [self.logView.text stringByAppendingString:message];
//    [self.logView layoutIfNeeded];
//    NSRange range = NSMakeRange(self.logView.text.length - 2, 1); //I ignore the final carriage return, to avoid a blank line at the bottom
//    [self.logView scrollRangeToVisible:range];
    
    
}
- (void) setDisconnect {
    self.imgState.image = [UIImage imageNamed:@"notconnected"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnScanConnectPressed:(UIButton *)sender {
    self.logView.text = @"";
    
    if ([self.sensor activePeripheral]) {
        if (self.sensor.activePeripheral.state == CBPeripheralStateConnected) {
            [self.sensor.manager cancelPeripheralConnection:self.sensor.activePeripheral];
            self.sensor.activePeripheral = nil;
        }
    }
    
    if ([self.sensor peripherals]) {
        self.sensor.peripherals = nil;
        [self.peripheralViewControllerArray removeAllObjects];
        [self.btDeviceListView reloadAllComponents];
    }
    
    self.sensor.delegate = self;
    [self.sensor findHMSoftPeripherals:5];

}

- (IBAction)btnConnect:(UIButton *)sender {
    self.logView.text = @"";
    
    NSInteger row = [self.btDeviceListView selectedRowInComponent:0];
    CBPeripheral *peripheral = [self.peripheralViewControllerArray objectAtIndex:row];
    
    if (self.sensor.activePeripheral && self.sensor.activePeripheral != peripheral) {
        [self.sensor disconnect:self.sensor.activePeripheral];
    }
    
    self.sensor.activePeripheral = peripheral;
    [self.sensor connect:self.sensor.activePeripheral];
    [self.sensor stopScan];

}


//UIPickerViewDelegate
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView
             attributedTitleForRow:(NSInteger)row
                      forComponent:(NSInteger)component {
    
    CBPeripheral *peripheral = [self.peripheralViewControllerArray objectAtIndex:row];
    
    if([peripheral name] != nil)
        return [[NSMutableAttributedString alloc] initWithString:[peripheral name]];
    else
        return [[NSMutableAttributedString alloc] initWithString:@"(Unknown Device)"];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    NSInteger count = [self.peripheralViewControllerArray count];
    if(count > 0){
        self.btnConnect.enabled = TRUE;
        self.bntInfo.enabled = TRUE;
    }else{
        self.btnConnect.enabled = FALSE;
        self.bntInfo.enabled = FALSE;
    }
    return count;
}
- (IBAction)btnRecenterPressed:(UIButton *)sender {
    self.deviceGridView.deviceXpos = 0.0;
    self.deviceGridView.deviceYpos = 0.0;
}


@end
