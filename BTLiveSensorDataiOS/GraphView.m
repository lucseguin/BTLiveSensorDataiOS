//
//  GraphView.m
//  BTLiveSensorDataiOS
//
//  Created by Luc Seguin on 17-11-01.
//  Copyright © 2017 Luc. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView
{
    NSMutableArray * plot1;
    NSMutableArray * plot2;
    float maxValue;
    bool initialized;
}
#define MAX_POINTS 250
-(void)initValues {
    maxValue = 0.0;
    
    plot1 = [[NSMutableArray alloc] initWithCapacity:MAX_POINTS];
    plot2 = [[NSMutableArray alloc] initWithCapacity:MAX_POINTS];
    
//    //generate random value
//    for (int i =0 ; i < MAX_POINTS; i++) {
//        [plot1 addObject:[NSNumber numberWithFloat:((-20 + (rand() % 40)) / 100.0)]];
//        [plot2 addObject:[NSNumber numberWithFloat:((-20 + (rand() % 40)) / 100.0)]];
//
//        if(fabsf([[plot1 objectAtIndex:i] floatValue]) > maxValue)
//            maxValue = fabsf([[plot1 objectAtIndex:i] floatValue]);
//
//        if(fabsf([[plot2 objectAtIndex:i] floatValue]) > maxValue)
//            maxValue = fabsf([[plot1 objectAtIndex:i] floatValue]);
//    }
    
    initialized = true;
}
-(void)drawRect:(CGRect)rect
{
    if(!initialized) {
        [self initValues];
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    
    
    CGPoint startPoint;
    CGPoint endPoint;

    //countour
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    startPoint.x = 0;
    startPoint.y = self.frame.size.height;
    endPoint.x = self.frame.size.width;
    endPoint.y = self.frame.size.height;
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    startPoint.x = self.frame.size.width;
    startPoint.y = self.frame.size.height;
    endPoint.x = self.frame.size.width;
    endPoint.y = 0;
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    startPoint.x = self.frame.size.width;
    startPoint.y = 0;
    endPoint.x = 0;
    endPoint.y = 0;
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    startPoint.x = 0;
    startPoint.y = 0;
    endPoint.x = 0;
    endPoint.y = self.frame.size.height;
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);

    //left hand min & max scale value
    UIFont * font = [UIFont boldSystemFontOfSize:10.0 ];
    UIColor * fontColor = [UIColor whiteColor];
    NSDictionary *attributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: fontColor};
    NSString *string = [NSString stringWithFormat:@"%.3f", maxValue];
    [string drawAtPoint:CGPointMake(2, 0) withAttributes:attributes];
    string = [NSString stringWithFormat:@"-%.3f", maxValue];
    [string drawAtPoint:CGPointMake(2, self.frame.size.height-12) withAttributes:attributes];
    
    fontColor = [UIColor redColor];
    attributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: fontColor};
    string = @"x";
    [string drawAtPoint:CGPointMake(self.frame.size.width-12, 0) withAttributes:attributes];
    fontColor = [UIColor cyanColor];
    attributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: fontColor};
    string = @"y";
    [string drawAtPoint:CGPointMake(self.frame.size.width-12, 12) withAttributes:attributes];
    
    
    //zero line
    startPoint.x = 0;
    startPoint.y = self.frame.size.height/2;
    endPoint.x = self.frame.size.width;
    endPoint.y = self.frame.size.height/2;
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
    
    if([plot1 count] > 0 && maxValue != 0.0) {
        CGPoint point;

        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        point.x = 0;
        point.y = self.frame.size.height/2- self.frame.size.height/2 * [[plot1 objectAtIndex:0] floatValue] / maxValue;
        CGContextMoveToPoint(context, point.x, point.y);
        
        int widthInterval = self.frame.size.width / MAX_POINTS;
        
        for (int i = 1 ; i < [plot1 count]; i++) {
            point.x = i * widthInterval;
            point.y = self.frame.size.height/2 - self.frame.size.height/2 * [[plot1 objectAtIndex:i] floatValue] / maxValue;
            
            CGContextAddLineToPoint(context, point.x, point.y);
            CGContextMoveToPoint(context, point.x, point.y);
        }
        CGContextStrokePath(context);
        
        CGContextSetStrokeColorWithColor(context, [UIColor cyanColor].CGColor);
        point.x = 0;
        point.y = self.frame.size.height/2 - self.frame.size.height/2 * [[plot2 objectAtIndex:0] floatValue] / maxValue;
        CGContextMoveToPoint(context, point.x, point.y);

        for (int i = 1 ; i < [plot2 count]; i++) {
            point.x = i * widthInterval;
            point.y = self.frame.size.height/2 - self.frame.size.height/2 * [[plot2 objectAtIndex:i] floatValue] / maxValue;
            CGContextAddLineToPoint(context, point.x, point.y);
            CGContextMoveToPoint(context, point.x, point.y);
        }
        CGContextStrokePath(context);
    }
}

-(void)addDataX:(float)x Y:(float)y {
    if(plot1.count == MAX_POINTS) {
        [plot1 removeObjectAtIndex:0];
        [plot2 removeObjectAtIndex:0];
    }
    [plot1 addObject:[NSNumber numberWithFloat:x]];
    [plot2 addObject:[NSNumber numberWithFloat:y]];
    
    maxValue = 0.0;
    float maxX=0.0;
    float maxY=0.0;
    
    for (int i =0 ; i < plot1.count; i++) {
        maxX = fabsf([[plot1 objectAtIndex:i] floatValue]);
        maxY = fabsf([[plot2 objectAtIndex:i] floatValue]);
        
        if(maxX > maxValue)
            maxValue = maxX;
        if(maxY > maxValue)
            maxValue = maxY;
    }
}
@end
