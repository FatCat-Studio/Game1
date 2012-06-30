//
//  FCGameViewController.m
//  Game1
//
//  Created by Руслан Федоров on 4/24/12.
//  Copyright (c) 2012 MIPT iLab. All rights reserved.
//

#import "FCGameViewController.h"

#define RED 7
#define GREEN 7
#define BLUE 7
#define CIRCLES 3
#define SPEED 100
#define DENSITY 7
@implementation FCGameViewController{
    GLKVector2 touchPos;
	BOOL touching;
    ASPGLSprite* circle;
    int caughtRed;
    int caughtGreen;
    int caughtBlue;
    float touchingTime; // Для того, чтобы сделать расширяющийся плавно круг, и чтобы он исчезал
}

-(GLKVector2)TKRotateVectorByAngle:(GLKVector2)vect withAngle:(double)angle{
    vect = GLKVector2Make(vect.x * cos(angle) - vect.y * sin(angle), vect.x * sin(angle) + vect.y * cos(angle));
    return vect;
}

-(void)MakeBallWithTexture:(NSString*)texture withVelocity:(float)velocity withDiameter:(float)diameter angleParts:(int)parts{
    ASPGLSprite *sp;
    sp = [ASPGLSprite spriteWithTextureName:texture effect: self.effect]; //Задаем текстуру
    sp.position = GLKVector2Make(self.viewIOSize.width/2-200+rand()%400, self.viewIOSize.height/2-100+rand()%200); // Задаем позиции
    sp.velocity = GLKVector2Make(velocity, 0); // Задаем скорости
    sp.contentSize = CGSizeMake(diameter,diameter); // Задаем размер шариков
    // Работаем со скоростью:
    double angle = 3.14/(rand()%parts+1); // Задаем угол поворота скорости
    // Поворачиваем на нужный угол.
    sp.velocity = GLKVector2MultiplyScalar([self TKRotateVectorByAngle:sp.velocity withAngle:angle],(rand()%2 ? 1 : -1)); // Вуаля
	sp.rotation = (rand()%10-5)*2;
    [self.sprites addObject:sp]; // Запихиваем в массив шарики
}

-(void) viewDidLoad{
    [super viewDidLoad];
    caughtRed = 0;
    caughtGreen = 0;
    caughtBlue = 0;
    // Круг, которым будем все ловить
    circle =[ASPGLSprite spriteWithTextureName:@"circle.png" effect:self.effect];
	circle.hidden = YES;
    circle.contentSize = CGSizeMake(1,1);
    circle.position = GLKVector2Make(-10, -10); // Задаем позицию
    [self.sprites addObject:circle]; // Запихиваем в массив круг
    // Шарики, которые ловим
    for (int i=0; i<RED; i++){
        [self MakeBallWithTexture:@"red.png" withVelocity:SPEED withDiameter:18 angleParts:RED];
    }
    for (int i=0; i<GREEN; i++){
        [self MakeBallWithTexture:@"green.png" withVelocity:SPEED withDiameter:18 angleParts:GREEN];
    }
    for (int i=0; i<BLUE; i++){
        [self MakeBallWithTexture:@"blue.png" withVelocity:SPEED withDiameter:18 angleParts:BLUE];
    }
}

-(void)collectBalls{
    for (ASPGLSprite *sp in self.sprites) {
        GLKVector2 vect = GLKVector2Subtract(touchPos,sp.centerPosition); // вектор, соединяющий середину шарика и наш палец
        float length = GLKVector2Length(vect);
        if(length < circle.contentSize.width){ // Если шарик ближе, чем радиус круга
            if(sp.fileName == @"red"){
                caughtRed++;
            }else
                if(sp.fileName == @"green"){
                    caughtGreen++;
                }else
                    if(sp.fileName == @"blue"){
                        caughtBlue++;
                    }
			sp.contentSize = CGSizeMake(sp.contentSize.height-1, sp.contentSize.width-1);
			vect = GLKVector2Normalize(vect); // Привели к единичной длине
			sp.velocity = GLKVector2MultiplyScalar(vect, 30); // Теперь шарик движется красиво к центру круга и уменьшается.
        }
        [sp update:self.timeSinceLastUpdate];
    }
}

#define WALLFORCE 5
-(void)update{
    if (touching){ // Если дотронулись, то рисуем круг, обновляем его положение размеры
        touchingTime += self.timeSinceLastUpdate;
		if (circle.hidden){
			circle.hidden = NO;
			circle.centerPosition = touchPos;
		}
		GLKVector2 sc = GLKVector2Subtract(touchPos, circle.centerPosition); // вектор, соединяющий центр круга и наш палец
		
        if (circle.radious<50){
            circle.radious += 100*self.timeSinceLastUpdate; // круг растет
			circle.velocity = GLKVector2MultiplyScalar(sc, 3); // направляем скорость круга в сторону пальца
        }else {
			circle.velocity = GLKVector2MultiplyScalar(sc, 3);
		}
		// circle.centerPosition = touchPos;
//    }else {
//        if (!circle.hidden) {
//            if (circle.radious>1.0){
//                circle.radious -= 100*self.timeSinceLastUpdate;
//                // circle.centerPosition = touchPos;
//            }else{
//                circle.hidden = YES;
//                circle.contentSize = CGSizeMake(1,1);
//                touchingTime = 0;
//		}
	}
    for (ASPGLSprite *sp in self.sprites) {
        
        // Стенки
        if (sp.centerPosition.x+sp.radious>self.viewIOSize.width){
            sp.velocity=GLKVector2Make(sp.velocity.x-WALLFORCE, sp.velocity.y);
        }else if(sp.centerPosition.x-sp.radious<0){
			sp.velocity=GLKVector2Make(sp.velocity.x+WALLFORCE, sp.velocity.y);
		}
        // Пол и потолок
        if(sp.centerPosition.y-sp.radious<0){
            sp.velocity=GLKVector2Make(sp.velocity.x, sp.velocity.y+WALLFORCE);
        }else if(sp.centerPosition.y+sp.radious>self.viewIOSize.height){
			sp.velocity=GLKVector2Make(sp.velocity.x, sp.velocity.y-WALLFORCE);
		}
        
        if ([circle isEqual:sp]) continue; // Если тарелка, пропускаем
        // Сивухин, 1ый том. Примерно 160 стр. прочитай, будет понятнее.
        // Начинаем играть со скоростями при столкновении:
        GLKVector2 vect = GLKVector2Subtract(circle.centerPosition,sp.centerPosition); // вектор, соединяющий середины шариков
        float length = GLKVector2Length(vect);
        // Если столкнулись с тарелкой:
        if( length < circle.radious+sp.radious ){
            double m1 = circle.radious * DENSITY; // Масса тарелки
            double m2 = sp.radious * DENSITY; // Масса астероида
            // Расписываем скорости по осям:
            GLKVector2 vect = GLKVector2Normalize(
                                GLKVector2Subtract(circle.centerPosition,sp.centerPosition)); // Вектор, соединяющий центры
            GLKVector2 norm = GLKVector2Normalize(GLKVector2Make(-vect.y, vect.x));
            // Нормальная составляющая скоростей:
            double normVelocityCircle = (circle.velocity.x*norm.x + circle.velocity.y*norm.y)/sqrt(norm.x*norm.x + norm.y*norm.y);
            double normVelocitySp = (sp.velocity.x*norm.x + sp.velocity.y*norm.y)/sqrt(norm.x*norm.x + norm.y*norm.y);
            // Тангенсальная составляющая скоростей:
            double vectVelocityCircle = (circle.velocity.x*vect.x + circle.velocity.y*vect.y)/sqrt(vect.x*vect.x + vect.y*vect.y);
            double vectVelocitySp = (sp.velocity.x*vect.x + sp.velocity.y*vect.y)/sqrt(vect.x*vect.x + vect.y*vect.y);
            // Тангенсальные скорости после соударения:
            double newVectVelocityCircle = (vectVelocityCircle-vectVelocitySp)*(m1-m2)/(m1+m2)+vectVelocitySp;
            double newVectVelocitySp = (vectVelocityCircle-vectVelocitySp)*2*m1/(m1+m2)+vectVelocitySp;
            // Возвращаемся в начальную систему координат:
            GLKVector2 tmpVectVelocityCircle = GLKVector2MultiplyScalar(vect, newVectVelocityCircle);
            GLKVector2 tmpNormVelocityCircle = GLKVector2MultiplyScalar(norm, normVelocityCircle);
            GLKVector2 tmpVectVelocitySp = GLKVector2MultiplyScalar(vect, newVectVelocitySp);
            GLKVector2 tmpNormVelocitySp = GLKVector2MultiplyScalar(norm, normVelocitySp);
            // Новые скорости:
            circle.velocity = GLKVector2Make(tmpNormVelocityCircle.x + tmpVectVelocityCircle.x,
                                             tmpNormVelocityCircle.y + tmpVectVelocityCircle.y);
            sp.velocity = GLKVector2Make(tmpNormVelocitySp.x + tmpVectVelocitySp.x,
                                         tmpNormVelocitySp.y + tmpVectVelocitySp.y);
            
        }
        [sp update:self.timeSinceLastUpdate];
    }
    [circle update:self.timeSinceLastUpdate];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    touchingTime = 0;
	touching=YES;
	CGPoint point=[[touches anyObject] locationInView:self.view];
	touchPos=GLKVector2Make(point.x, self.viewIOSize.height-point.y);
	circle.rotation=4;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint point=[[touches anyObject] locationInView:self.view];
	touchPos=GLKVector2Make(point.x, self.viewIOSize.height-point.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	touching=NO;
	
}

@end
