//
//  FCGameViewController.m
//  Game1
//
//  Created by Руслан Федоров on 4/24/12.
//  Copyright (c) 2012 MIPT iLab. All rights reserved.
//

#import "FCGameViewController.h"

#define NUM 30
#define GIRLS 5
@implementation FCGameViewController{
    ASPGLSprite *first;
    ASPGLSprite *second;
    float t[NUM];
    NSString *sex[NUM+GIRLS];
    float b;
    float w;
    GLKVector2 touchPos;
	BOOL touching;
}
-(void) viewDidLoad{
    [super viewDidLoad];
    w = 0;
    int i=0;
    for (; i<NUM; ++i){
        ASPGLSprite *lol = [ASPGLSprite spriteWithTextureName:@"newball2.png" effect: self.effect];
        lol.contentSize = CGSizeMake(20,20);
        lol.position = GLKVector2Make(self.viewIOSize.width/2 + rand()%300 - 150, self.viewIOSize.height/2+rand()%300-150);
        t[i]=(i*3.14)/NUM;
        sex[i] = @"boy";
        [self.sprites addObject:lol];
    }
    for (; i<NUM+GIRLS; ++i){
        ASPGLSprite *lol = [ASPGLSprite spriteWithTextureName:@"newball.png" effect: self.effect];
        lol.contentSize = CGSizeMake(20,20);
        lol.position = GLKVector2Make(self.viewIOSize.width/2 + rand()%200 - 100, self.viewIOSize.height/2+rand()%300-150);
        t[i]=(i*3.14)/GIRLS;
        sex[i] = @"girl";
        [self.sprites addObject:lol];
    }
}

#define A 170
#define B 170
#define a 5
-(void)update{
    b = 4;
    w+=0.01;

    for (int i = 0;i<NUM+GIRLS;++i){
        //Палец
        if(touching){
            // Здесь мы рассчитываем новую скорость шарика под действием силы тяжести
            GLKVector2 vect = GLKVector2Subtract(touchPos,
                    ((ASPGLSprite*)[self.sprites objectAtIndex:i]).centerPosition); // вектор, соединяющий середину шарика и палец
            float length = GLKVector2Length(vect); // расстояние до пальца
            vect=GLKVector2Normalize(vect); // Привели к единичной длине
            CGFloat acceleration = 5;// Модуль силы
            GLfloat width = ((ASPGLSprite*)[self.sprites objectAtIndex:i]).contentSize.width;
            GLfloat height = ((ASPGLSprite*)[self.sprites objectAtIndex:i]).contentSize.height;
            if(length<70){
                ((ASPGLSprite*)[self.sprites objectAtIndex:i]).contentSize = CGSizeMake(width-1, height-1);                acceleration = 9;
            }else {
                ((ASPGLSprite*)[self.sprites objectAtIndex:i]).contentSize = CGSizeMake(20, 20); //Если вылетели из круга и шар есть, то возвращаем размер
            }
            vect=GLKVector2MultiplyScalar(vect, acceleration); // Задали направление ускорения
            ((ASPGLSprite*)[self.sprites objectAtIndex:i]).velocity =
            GLKVector2Add(((ASPGLSprite*)[self.sprites objectAtIndex:i]).velocity, vect); // Наша новая скорость
            if(width+height<1){
                [[self.sprites objectAtIndex:i] outOfView];
            }
            [[self.sprites objectAtIndex:i] update:self.timeSinceLastUpdate];
        }else{
            ((ASPGLSprite*)[self.sprites objectAtIndex:i]).contentSize = CGSizeMake(20, 20); // Если отпустили и шар есть, то возвращаем размер
            ((ASPGLSprite*)[self.sprites objectAtIndex:i]).velocity = GLKVector2Make(A*sin(a*t[i]+w), B*sin(b*t[i]));
            [[self.sprites objectAtIndex:i] update:self.timeSinceLastUpdate];
            t[i]+=0.006;
        }
    }
    //b-=0.001;
    //if(b<=0) b=1;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	touching=YES;
	CGPoint point=[[touches anyObject] locationInView:self.view];
	touchPos=GLKVector2Make(point.x, self.viewIOSize.height-point.y);
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	touching=NO;
}

@end
