//
//  DataContext.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/7/28.
//

import Foundation
import OpenGLES

struct DataContext {
    
    static let NUM_INSTANCES = 100
    
    var propramObject:GLuint = 0
    
    var positionVBO:GLuint = 0
    var colorVBO:GLuint = 0
    var mvpVBO:GLuint = 0
    var indicesIBO:GLuint = 0
    
    var numIndices:Int = 0
    
    var angle:[GLfloat] = .init(repeating: 0.0, count: DataContext.NUM_INSTANCES)
    
    var width:GLfloat = 1.0
    var height:GLfloat = 1.0
    
    func clearGL() {
        var ud = self
        glDeleteBuffers(1, &ud.positionVBO)
        glDeleteBuffers(1, &ud.colorVBO)
        glDeleteBuffers(1, &ud.mvpVBO)
        glDeleteBuffers(1,&ud.indicesIBO)
        glDeleteProgram(ud.propramObject)
    }
}
