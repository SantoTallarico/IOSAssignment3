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
#include "maze.h"

class Model {
public:
    MazeCell entrance;
    MazeCell exit;
    
    Model();
};

#endif /* Model_hpp */
