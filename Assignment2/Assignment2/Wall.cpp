//
//  wall.cpp
//  Assignment2
//
//  Created by Santo Tallarico on 2016-03-05.
//  Copyright © 2016 Santo Tallarico. All rights reserved.
//

#include "wall.hpp"

Wall::Wall() {
    
}

Wall::Wall(GLuint _vertexData, GLuint _texture, GLuint _uniform, GLKVector3 _position, GLKVector3 _rotation) {
    vertexData = _vertexData;
    texture = _texture;
    uniform = _uniform;
    position = _position;
    rotation = _rotation;
}

void Wall::Render() {
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
}