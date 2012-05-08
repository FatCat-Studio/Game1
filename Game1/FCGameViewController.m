//
//  FCGameViewController.m
//  Game1
//
//  Created by Руслан Федоров on 4/24/12.
//  Copyright (c) 2012 MIPT iLab. All rights reserved.
//

#import "FCGameViewController.h"

#define BOYS 60
#define GIRLS 15
@implementation FCGameViewController{
    ASPGLSprite *first;
    ASPGLSprite *second;
    float t[BOYS+GIRLS];
    float w;
    GLKVector2 touchPos;
	BOOL touching;
    ASPGLSprite* blackHole;
    int boysNumber;
    int girlsNumber;
}
#pragma mark - Loading -
-(void) positionPauseView{
	CGRect bounds=pauseView.bounds;
	if (bounds.origin.y==0){
//		Т.к. координаты у iOS через жопу, надо переставить вид под экран
		bounds.origin.y=-self.viewIOSize.height-bounds.size.height;
	}
	bounds.origin.x=0;
	pauseView.bounds=bounds;
}
-(void) viewDidLoad{
    [super viewDidLoad];
    blackHole =[ASPGLSprite spriteWithTextureName:@"player.png" effect:self.effect]; //наша черная дыра под пальцем
	blackHole.hidden = YES;
    blackHole.contentSize = CGSizeMake(100,100);
    for (int i=0; i<=BOYS+GIRLS; ++i){
        ASPGLSprite *sp;
        if(i<=BOYS){ // Если парень
            sp = [ASPGLSprite spriteWithTextureName:@"newball.png" effect: self.effect]; //Задаем текстуру
            sp.fileName = @"boy"; // Задаем пол
            sp.position = GLKVector2Make(self.viewIOSize.width/2 + rand()%400 - 200, self.viewIOSize.height/2+rand()%300-150); // Задаем позиции
        } else { // Парни кончились, пошли девушки
            sp = [ASPGLSprite spriteWithTextureName:@"newball2.png" effect: self.effect]; //Задаем текстуру
            sp.fileName = @"girl";// Задаем пол
            sp.position = GLKVector2Make(self.viewIOSize.width/2 + rand()%500 - 250, self.viewIOSize.height/2+rand()%300-150); // Задаем позиции
        }
        sp.contentSize = CGSizeMake(20,20); // Задаем размеры
        t[i]=(i*3.14)/(BOYS+GIRLS); // Задаем время отступа от нуля, чтобы они летали в разных фазах
        [self.sprites addObject:sp]; // Запихиваем в массив
    }
	[self.sprites addObject:blackHole]; // Запихиваем в массив
	
//	Ловим даблтапы для вызова паузы
	UITapGestureRecognizer *doubleTap = 
	[[UITapGestureRecognizer alloc]
	 initWithTarget:self 
	 action:@selector(showPauseView)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
//	Добавляем pauseView в вид игры, чтобы он отрисовывался
	if (pauseView){
		[self positionPauseView];
		[self.view addSubview:pauseView];
	}
}

#pragma mark - Logic -
// Максимальная скорость по X:
#define X 170
// Максимальная скорость по Y:
#define Y 170
// Количество раз пересечет экран по X прямой:
#define a 5
// Количество раз пересечет экран по Y прямой:
#define b 4

- (void) blackHoleLogicUpdate:(ASPGLSprite*) sp{
	blackHole.position = GLKVector2Make(touchPos.x, touchPos.y-blackHole.contentSize.height/2);
	//blackHole.hidden = NO;
	// Рассчитываем новую скорость шарика под действием силы притяжения Черной дыры
	GLKVector2 vect = GLKVector2Subtract(touchPos, sp.centerPosition); // Вектор от черной дыры к шарику
	int distance = sqrt(vect.x*vect.x+vect.y*vect.y); // Расстояние до черной дыры от шарика
	vect = GLKVector2Normalize(vect); // Привели к единичной длине
	CGFloat acceleration = 5;// Модуль силы
	GLfloat width = sp.contentSize.width; // Ширина спрайта
	GLfloat height = sp.contentSize.height; // Высота спрайта
	if(distance < 50){
		sp.contentSize = CGSizeMake(width-1, height-1);
		acceleration = 20;
	}else {
		sp.contentSize = CGSizeMake(20, 20); //Если вылетели из круга и шар есть, то возвращаем размер
	}
	vect = GLKVector2MultiplyScalar(vect, acceleration); // Задали направление ускорения
	sp.velocity = GLKVector2MultiplyScalar(vect, 20); // Новая скорость шарика
	if(width+height<20){ //Если исчезли, то очистить память
		if([sp.fileName compare:@"boy"]==0){
			[boysField setText:[NSString stringWithFormat:@"%d", boysNumber++]];
		} else {
			[girlsField setText:[NSString stringWithFormat:@"%d", girlsNumber++]];
		}
		[sp outOfView];
	}
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self positionPauseView];
}
-(void)update{
    for (int i = 0; i <= BOYS+GIRLS; ++i){
        ASPGLSprite* sp = [self.sprites objectAtIndex:i];
		if (!sp) continue;
		if (sp.hidden) continue;
        //Палец
        if(touching){
            [self blackHoleLogicUpdate:sp];
        }else{
            sp.contentSize = CGSizeMake(20, 20); // Если отпустили и шар есть, то возвращаем размер
            sp.velocity = GLKVector2Make(X*sin(a*t[i]+w), Y*sin(b*t[i]));
            t[i]+=0.01;
        }
        [sp update:self.timeSinceLastUpdate];
    }
	[blackHole update:self.timeSinceLastUpdate];
}

#pragma mark - Touches -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	touching=YES;
	CGPoint point=[[touches anyObject] locationInView:self.view];
	touchPos=GLKVector2Make(point.x, self.viewIOSize.height-point.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	touching=NO;
    blackHole.hidden = YES;
}

#pragma mark - Pause -

- (void) showPauseView{
	[UIView animateWithDuration:0.5 animations:^{
		pauseView.bounds=CGRectOffset(pauseView.bounds, 0, pauseView.bounds.size.height);
	} completion:^(BOOL finished){
		[pauseView becomeFirstResponder];
	}];
	//[UIView commitAnimations];
}

- (IBAction)hidePauseView{
	[UIView animateWithDuration:0.5 animations:^{
		pauseView.bounds=CGRectOffset(pauseView.bounds, 0, -pauseView.bounds.size.height);
	} completion:^(BOOL finished){
		[pauseView resignFirstResponder];
	}];
}

- (IBAction)cancel:(id)sender{
	
}

- (IBAction)menu:(id)sender{
	
}

@end
