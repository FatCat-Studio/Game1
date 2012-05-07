
/* Math by Timofey Korchagin */
static __inline__ GLKVector2 GLKVector2Mirror(GLKVector2 vect, GLKVector2 normal);

static __inline__ GLKVector2 GLKVector2Mirror(GLKVector2 vect,GLKVector2 normal){
    GLfloat nlen=GLKVector2Length(normal);
    return GLKVector2Add(GLKVector2MultiplyScalar(normal,-2*GLKVector2DotProduct(vect, normal)/(nlen*nlen)), vect);
}

static __inline__ GLKVector2 GLKVector2Normal(GLKVector2 vect);

static __inline__ GLKVector2 GLKVector2Normal(GLKVector2 vect){
	return GLKVector2Make(-vect.y, vect.x);
}
