//
//  Shapes.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/7/28.
//

import Foundation
import OpenGLES

final class Shapes {
    
    struct Model {
       var numIndices:Int
       var vertices:[GLfloat]
       var normals:[GLfloat]
       var texCoords:[GLfloat]
       var indices:[GLuint]
    }
    
    static func genCube(scale:GLfloat)
    -> Model
    {
        let numIndices = 36
        
        let cubeVerts:[GLfloat] = [
            -0.5, -0.5, -0.5,
            -0.5, -0.5,  0.5,
            0.5, -0.5,  0.5,
            0.5, -0.5, -0.5,
            -0.5,  0.5, -0.5,
            -0.5,  0.5,  0.5,
            0.5,  0.5,  0.5,
            0.5,  0.5, -0.5,
            -0.5, -0.5, -0.5,
            -0.5,  0.5, -0.5,
            0.5,  0.5, -0.5,
            0.5, -0.5, -0.5,
            -0.5, -0.5, 0.5,
            -0.5,  0.5, 0.5,
            0.5,  0.5, 0.5,
            0.5, -0.5, 0.5,
            -0.5, -0.5, -0.5,
            -0.5, -0.5,  0.5,
            -0.5,  0.5,  0.5,
            -0.5,  0.5, -0.5,
            0.5, -0.5, -0.5,
            0.5, -0.5,  0.5,
            0.5,  0.5,  0.5,
            0.5,  0.5, -0.5,
        ]
        
        let cubeNormals:[GLfloat] = [
            0.0, -1.0, 0.0,
            0.0, -1.0, 0.0,
            0.0, -1.0, 0.0,
            0.0, -1.0, 0.0,
            0.0, 1.0, 0.0,
            0.0, 1.0, 0.0,
            0.0, 1.0, 0.0,
            0.0, 1.0, 0.0,
            0.0, 0.0, -1.0,
            0.0, 0.0, -1.0,
            0.0, 0.0, -1.0,
            0.0, 0.0, -1.0,
            0.0, 0.0, 1.0,
            0.0, 0.0, 1.0,
            0.0, 0.0, 1.0,
            0.0, 0.0, 1.0,
            -1.0, 0.0, 0.0,
            -1.0, 0.0, 0.0,
            -1.0, 0.0, 0.0,
            -1.0, 0.0, 0.0,
            1.0, 0.0, 0.0,
            1.0, 0.0, 0.0,
            1.0, 0.0, 0.0,
            1.0, 0.0, 0.0,
        ]
        
        let cubeTex:[GLfloat] = [
            0.0, 0.0,
            0.0, 1.0,
            1.0, 1.0,
            1.0, 0.0,
            1.0, 0.0,
            1.0, 1.0,
            0.0, 1.0,
            0.0, 0.0,
            0.0, 0.0,
            0.0, 1.0,
            1.0, 1.0,
            1.0, 0.0,
            0.0, 0.0,
            0.0, 1.0,
            1.0, 1.0,
            1.0, 0.0,
            0.0, 0.0,
            0.0, 1.0,
            1.0, 1.0,
            1.0, 0.0,
            0.0, 0.0,
            0.0, 1.0,
            1.0, 1.0,
            1.0, 0.0,
        ]
        
        let vertices:[GLfloat] = cubeVerts.map({ $0 * scale})
        
        let cubeIndices:[GLuint] = [
            0, 2, 1,
            0, 3, 2,
            4, 5, 6,
            4, 6, 7,
            8, 9, 10,
            8, 10, 11,
            12, 15, 14,
            12, 14, 13,
            16, 17, 18,
            16, 18, 19,
            20, 23, 22,
            20, 22, 21
        ]
         
        return Model(numIndices: numIndices, vertices: vertices, normals: cubeNormals, texCoords: cubeTex, indices: cubeIndices)
    }
    
    
    static func genSphere(numSlices:GLint,radius: GLfloat) -> Model {
        let numParallels = numSlices / 2;
        let numVertices = (numParallels + 1) * (numSlices + 1)
        let numIndices = numParallels * numSlices * 6;
        let angleStep = (2.0 * GLfloat.pi) / Float(numSlices)
        
        
        var vertices = [GLfloat].init(repeating: 0, count: 3 * Int(numVertices))
        
        var normals = [GLfloat].init(repeating: 0, count: 3 * Int(numVertices))
        
        var texCoords = [GLfloat].init(repeating: 0, count: 2 * Int(numVertices))
        
        var indices = [GLuint].init(repeating: 0, count: Int(numIndices))
        
        for i in 0...numParallels {
            for j in 0...numSlices {
                let vertex = ( i * (numSlices + 1) + j) * 3
            
                vertices[Int(vertex) + 0] = radius * sinf(angleStep * Float(i)) * sinf(angleStep * Float(j))
                vertices[Int(vertex) + 1] = radius * cosf(angleStep * Float(i))
                vertices[Int(vertex) + 2] = radius * sinf(angleStep * Float(i)) + cosf(angleStep * Float(j))
                
                normals[Int(vertex) + 0] = vertices[Int(vertex) + 0] / radius
                normals[Int(vertex) + 1] = vertices[Int(vertex) + 1] / radius
                normals[Int(vertex) + 2] = vertices[Int(vertex) + 2] / radius
                
                let texIndex = (i * (numSlices + 1) + j) * 2
                texCoords[Int(texIndex) + 0] = Float(j) / Float(numSlices)
                texCoords[Int(texIndex) + 1] = (1.0 - Float(i)) / Float(numParallels - 1)
                
            }
        }
        
       
        
        do {
            var idx = 0
            for i in 0..<numParallels {
                for j in 0..<numSlices {
                    indices[idx] = GLuint(i * (numSlices + 1) + j);
                    idx += 1
                    
                    indices[idx] = GLuint((i + 1) * (numSlices + 1) + j)
                    idx += 1
                    
                    indices[idx] = GLuint((i + 1) * (numSlices + 1) + (j + 1))
                    idx += 1
                    
                    indices[idx] = GLuint(i * (numSlices + 1) + j)
                    idx += 1
                    
                    indices[idx] = GLuint(( i + 1 ) * ( numSlices + 1 ) + ( j + 1 ))
                    idx += 1
                    
                    indices[idx] = GLuint( i * ( numSlices + 1 ) + ( j + 1 ))
                    idx += 1
                }
            }
        }
       
        
        return Model.init(numIndices: Int(numIndices), vertices: vertices, normals: normals, texCoords: texCoords, indices: indices)
    }
}
