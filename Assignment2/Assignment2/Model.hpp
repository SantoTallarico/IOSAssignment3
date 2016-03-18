//
//  Model.hpp
//  Assignment2
//
//  Created by Santo Tallarico on 2016-03-17.
//  Copyright © 2016 Santo Tallarico. All rights reserved.
//

#ifndef Model_hpp
#define Model_hpp

#include <stdio.h>
#include <cstdlib>
#include <GLKit/GLKit.h>
#include <vector>
#include "maze.h"
#include "Hitbox.hpp"

class Model {
public:
    Hitbox hitbox;
    vector_float3 direction;
    vector_float3 position;
    std::vector<vector_float3> directions;
    
    Model();
    void Update();
    void Collide();
};

#endif /* Model_hpp */
