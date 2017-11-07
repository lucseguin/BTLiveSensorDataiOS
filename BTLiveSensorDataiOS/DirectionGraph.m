//
//  DirectionGraph.m
//  BTLiveSensorDataiOS
//
//  Created by Luc Seguin on 17-11-02.
//  Copyright © 2017 Luc. All rights reserved.
//

#import "DirectionGraph.h"

@implementation DirectionGraph
{
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f, CGRectGetHeight(self.bounds) / 2.f);
    CGFloat radius = center.x - 10.f;
    
    
    //outer cirlce
    UIBezierPath *portionPath = [UIBezierPath bezierPath];
    [portionPath moveToPoint:center];
    [portionPath addArcWithCenter:center radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES];
    [portionPath closePath];
    [[UIColor greenColor] setFill];
    [portionPath fill];
    //inner circle
    radius = center.x - 11.f;
    portionPath = [UIBezierPath bezierPath];
    [portionPath moveToPoint:center];
    [portionPath addArcWithCenter:center radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES];
    [portionPath closePath];
    [[UIColor colorWithRed:143/255.0 green:188/255.0 blue:143/255.0 alpha:1] setFill];
    [portionPath fill];
    
    radius = center.x - 11.f;
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddLineToPoint(context, center.x, center.y-radius);
    CGContextStrokePath(context);
    
    if(self.currentHeading > self.fixedHeading) {
        radius = center.x - 11.f;
        portionPath = [UIBezierPath bezierPath];
        [portionPath moveToPoint:center];
        float ang =(self.currentHeading-self.fixedHeading)/180.0*M_PI;
        [portionPath addArcWithCenter:center radius:radius startAngle:3*M_PI_2 endAngle:3*M_PI_2+ang clockwise:YES];
        [portionPath closePath];
        [[UIColor colorWithRed:255/255.0 green:128/255.0 blue:128/255.0 alpha:1] setFill];
        [portionPath fill];
    } else if(self.currentHeading < self.fixedHeading) {
        radius = center.x - 11.f;
        portionPath = [UIBezierPath bezierPath];
        [portionPath moveToPoint:center];
        float ang =3*M_PI_2-(self.fixedHeading-self.currentHeading)/180.0*M_PI;
        [portionPath addArcWithCenter:center radius:radius startAngle:ang endAngle:3*M_PI_2 clockwise:YES];
        [portionPath closePath];
        [[UIColor colorWithRed:255/255.0 green:128/255.0 blue:128/255.0 alpha:1] setFill];
        [portionPath fill];
    }
    
}
@end
