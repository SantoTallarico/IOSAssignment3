//
//  Model.cpp
//  Assignment2
//
//  Created by Santo Tallarico on 2016-03-17.
//  Copyright © 2016 Santo Tallarico. All rights reserved.
//

#include "Model.hpp"

Model::Model() {
    directions.push_back((vector_float3){1, 0, 0});
    directions.push_back((vector_float3){0, 0, 1});
    directions.push_back((vector_float3){-1, 0, 0});
    directions.push_back((vector_float3){0, 0, -1});
    direction = directions[rand() % 4];
}

void Model::Update() {
    position += direction / 100;
    if (position.z >= 8)
    {
        position.z = 7.99f;
        direction = directions[rand() % 4];
    }
    if (position.z <= 0)
    {
        position = 0.01f;
        direction = directions[rand() % 4];
    }
}

void Model::Collide() {
    position -= direction / 100;
    direction = directions[rand() % 4];
}