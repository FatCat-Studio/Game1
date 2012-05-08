//
//  FCGameViewController.h
//  Game1
//
//  Created by Руслан Федоров on 4/24/12.
//  Copyright (c) 2012 MIPT iLab. All rights reserved.
//

#import "ASPEngine.h"
#import <GLKit/GLKit.h>
@interface FCGameViewController : ASPGLKViewController
-(GLKVector2)TKRotateVectorByAngle:(GLKVector2)vect withAngle:(double)angle;
@end
