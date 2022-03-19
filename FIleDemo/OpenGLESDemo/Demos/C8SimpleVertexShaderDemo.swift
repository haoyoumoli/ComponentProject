//
//  C8SimpleVertexShaderDemo.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/8/12.
//

import Foundation
import OpenGLES

final class  C8SimpleVertexShaderDemo : DemoProtocol {
    
    let programObject:GLuint
    private(set) var mvpLoc:GLint = 0
    private(set) var numIndices:Int = 0
    private(set) var angle:GLfloat = 0.0
    
    private(set) var mvpMarix:Matrix4x4 = .init()
    private(set) var vertices:[GLfloat] = []
    private(set) var indices:[GLuint] = []
    
    
    
    init?() {
        let vertexShader = """
        #version 300 es
        uniform mat4 u_mvpMatrix;
        layout(location = 0) in vec4 a_position;
        layout(location = 1) in vec4 a_color;
        out vec4 v_color;
        void main()
        {
            v_color = a_color;
            gl_Position = u_mvpMatrix * a_position;
        }
        """
        
        let fragmentShader = """
        #version 300 es
        precision mediump float;
        in vec4 v_color;
        layout(location = 0) out vec4 outColor;
        void main()
        {
            outColor = vec4(1.0,0.5,0.5,1.0);
        }
        """
        
       let shaderCompiler =  ShaderCompiler.init(vertexShaderCode: vertexShader, fragmentShaderCode: fragmentShader)
        do {
            let shaders = try shaderCompiler.complie().get()
            
            programObject = try shaderCompiler.link(vertexShader: shaders.vertexShader, fragmentShader: shaders.fragmentShader).get()
            
        } catch  {
            return nil
        }
        
        "u_mvpMatrix".withCString { pointer in
            let pon:UnsafePointer<GLchar>? = pointer
            self.mvpLoc = glGetUniformLocation(programObject, pon)
        }
        
        let cube = Shapes.genCube(scale: 1.0)
        numIndices = cube.numIndices
        vertices = cube.vertices
        indices = cube.indices
        
        angle = 45.0
        glClearColor(1.0, 1.0, 1.0, 1.0)
    }
    
    deinit {
        shutDown()
    }
    
    func isSupportUpdate() -> Bool {
        return true
    }
    
    func update() {
        var perspective = Matrix4x4.init()
        var modelView = Matrix4x4.init()
        var aspect:GLfloat = 0.0
        
        angle += (0.03 * 40.0)
        if (angle >= 360.0) {
            angle -= 360.0
        }
        
        aspect = 1.0
        
        perspective.becomeIdentity()
        perspective.perspective(fovy: 60.0, aspect: aspect, nearZ: 1.0, farZ: 20.0)
        
        modelView.becomeIdentity()
        modelView.translate(tx: 0.0, ty: 0.0, tz: -2.0)
        modelView.rotate(angle: angle, x: 1.0, y: 0.0, z: 1.0)
        
        modelView.mutiply(perspective)
        mvpMarix = modelView
        
    }
    
    func draw(width: Int, height: Int) {
        glViewport(0, 0, GLsizei(width), GLsizei(height))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glUseProgram(programObject)
        
        ///传递订单数据
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(3 * MemoryLayout<GLfloat>.stride), &vertices)
        glEnableVertexAttribArray(0)
        
        ///直接设置颜色数据
        var color:[GLfloat] = [0.0,1.0,0.0,1.0]
        glVertexAttrib4fv(1, &color)
        
        ///设置mvp矩阵
        var m = mvpMarix.getValues()
        glUniformMatrix4fv(mvpLoc, 1, GLboolean(GL_FALSE), &m)
        
        
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(numIndices), GLenum(GL_UNSIGNED_INT), &indices)
    }
    
    func shutDown() {
        glDeleteProgram(programObject)
    }
    
    
}
