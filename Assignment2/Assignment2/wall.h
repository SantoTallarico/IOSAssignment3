//
//  wall.h
//  Assignment2
//
//  Created by Santo Tallarico on 2016-03-05.
//  Copyright © 2016 Santo Tallarico. All rights reserved.
//

#ifndef wall_h
#define wall_h
#import <GLKit/GLKit.h>

class Wall {

public:
    Wall();
    Wall(GLuint _vertexData, GLuint _texture, GLuint _uniform, GLKVector3 _position, GLKVector3 _rotation);
    void Render();
    
    GLKVector3 position;
    GLKVector3 rotation;
    GLuint texture;
    GLuint uniform;
    GLuint vertexData;
};

#endif /* wall_h */
