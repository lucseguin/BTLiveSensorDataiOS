//
//  DeviceGridView.m
//  BTLiveSensorDataiOS
//
//  Created by Luc Seguin on 16-08-17.
//  Copyright © 2016 Luc. All rights reserved.
//

#import "DeviceGridView.h"

@implementation DeviceGridView


-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // ---------------------------
    // Drawing column lines
    // ---------------------------
    
    // calculate column width
    CGFloat width = MIN(self.frame.size.width/6, self.frame.size.height/6);
    
    CGPoint startPoint;
    CGPoint endPoint;
    endPoint.x = startPoint.x =  self.frame.size.width/2;
    startPoint.y = 0.0f;
    endPoint.y = self.frame.size.height;
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);

    endPoint.x = 0;
    startPoint.x =  self.frame.size.width;
    startPoint.y = endPoint.y = self.frame.size.height /2 ;

    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
    

    //Grid
    for(int i = self.frame.size.width/2 + width; i < self.frame.size.width; i+=width){
        endPoint.x = startPoint.x =  i;
        startPoint.y = 0.0f;
        endPoint.y = self.frame.size.height;
        
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        CGContextStrokePath(context);
    }
    
    for(int i = self.frame.size.width/2 - width; i >= 0; i-=width){
        endPoint.x = startPoint.x =  i;
        startPoint.y = 0.0f;
        endPoint.y = self.frame.size.height;
        
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        CGContextStrokePath(context);
    }
    
    
    for(int i = self.frame.size.height/2 + width; i < self.frame.size.height; i+=width){
        
        endPoint.x = 0;
        startPoint.x =  self.frame.size.width;
        startPoint.y = endPoint.y = i ;
        
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        CGContextStrokePath(context);
    }
    
    for(int i = self.frame.size.height/2 - width; i  >= 0; i-=width){
        
        endPoint.x = 0;
        startPoint.x =  self.frame.size.width;
        startPoint.y = endPoint.y = i ;
        
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        CGContextStrokePath(context);
    }
    
    
    if(self.connected) {
        CGPoint devicePoint;
        devicePoint.x = self.frame.size.width/2;
        devicePoint.y = self.frame.size.height/2;
        
        devicePoint.x += self.deviceXpos*10 * width; 
        devicePoint.y -= self.deviceYpos*10 * width;
        
        CGFloat deviceWidth = width / 10;
        CGRect deviceRect = CGRectMake( devicePoint.x - deviceWidth/2 , devicePoint.y - deviceWidth, deviceWidth, deviceWidth*2);
        
        CGPathRef path = CGPathCreateWithRect(deviceRect, NULL);
        [[UIColor redColor] setFill];
        [[UIColor redColor] setStroke];
        CGContextAddPath(context, path);
        CGContextDrawPath(context, kCGPathFillStroke);
        
        UIFont * font = [UIFont boldSystemFontOfSize:10.0 ];
        UIColor * fontColor = [UIColor whiteColor];
        NSDictionary *attributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: fontColor};
        NSString *string = [NSString stringWithFormat:@"x:%.3f y:%.3f", self.deviceXpos, self.deviceYpos];
        [string drawAtPoint:CGPointMake(devicePoint.x - deviceWidth/2 + 10,  devicePoint.y - deviceWidth) withAttributes:attributes];
        
    }
}

@end
