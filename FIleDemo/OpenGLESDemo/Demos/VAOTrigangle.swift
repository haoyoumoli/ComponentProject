//
//  VAOTrigangle.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/7/27.
//

import Foundation
import OpenGLES

final class VAOAndIndicesTrigangle:DemoProtocol {
        
    let programObject:GLuint
    
    private(set) var vaoId:GLuint = 0
    private(set) var vboIds:[GLuint] = [0,0]
    
    init?() {

        let vertex_pos_size:GLint = 3
        let vertex_color_size:GLint = 4
        let vertex_pos_indx:GLuint = 0
        let vertex_color_indx:GLuint = 1
        let vertex_stride:GLint = GLint( MemoryLayout<GLfloat>.stride) * (vertex_pos_size + vertex_color_size)
        
        
        let vShaderStr = """
        #version 300 es
        layout(location = 0) in vec4 a_position;
        layout(location = 1) in vec4 a_color;
        out vec4 v_color;
        void main()
        {
            v_color = a_color;
            gl_Position = a_position;
        }
        """
        
        let fShaderStr = """
        #version 300 es
        precision mediump float;
        in vec4 v_color;
        out vec4 o_fragColor;
        void main()
        {
            o_fragColor = v_color;
        }
        """
        
        let shaderComplier = ShaderCompiler.init(vertexShaderCode: vShaderStr, fragmentShaderCode: fShaderStr)
        
        do {
            let shaders = try shaderComplier.complie().get()
            
            programObject = try shaderComplier.link(vertexShader: shaders.vertexShader, fragmentShader: shaders.fragmentShader).get()
            
        } catch  {
            return nil
        }
        
        var vertices:[GLfloat] = [
             0.0,  0.5,  0.0,        //v0
             1.0,  0.0,  0.0, 1.0,   //c0
            -0.5, -0.5,  0.0,        //v1
             0.0,  1.0,  0.0, 1.0,   //c1
             0.5, -0.5,  0.0,        //v2
             0.0,  0.5,  1.0, 1.0    //c2
        ]
      
        ///顶点索引数组
        var indices:[GLushort] = [0,1,2]
        
      
        glGenBuffers(2, &vboIds)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vboIds[0])
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLfloat>.stride * vertices.count), &vertices, GLenum(GL_STATIC_DRAW))
        
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vboIds[1])
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLushort>.stride * indices.count), &indices, GLenum(GL_STATIC_DRAW))
        
        glGenVertexArrays(1, &vaoId)
        
        glBindVertexArray(vaoId)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vboIds[0])
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vboIds[1])
        
        glEnableVertexAttribArray(vertex_pos_indx)
        glEnableVertexAttribArray(vertex_color_indx)
        

        glVertexAttribPointer(vertex_pos_indx, vertex_pos_size, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vertex_stride,UnsafeRawPointer.init(bitPattern: 0)
        )
        
        glVertexAttribPointer(vertex_color_indx, vertex_color_size, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vertex_stride, UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.stride * Int(vertex_pos_size)))
        
        
        //Reset to the default vao
        glBindVertexArray(0)
        glClearColor(0.0, 0.0, 0.0, 0.0)
    }
    
    deinit {
        self.shutDown()
    }
    
    func draw(width:Int,height:Int) {
        glViewport(0, 0, GLsizei(width), GLsizei(height))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        glUseProgram(programObject)
        glBindVertexArray(vaoId)
        
        let zero = UnsafeRawPointer(bitPattern: 0)
        defer { zero?.deallocate() }
        
        glDrawElements(GLenum(GL_TRIANGLES), 3, GLenum(GL_UNSIGNED_SHORT), zero)
        
        glBindVertexArray(0)
    }
    
    func shutDown()   {
        glDeleteProgram(programObject)
        glDeleteVertexArrays(1, &vaoId)
        glDeleteBuffers(GLsizei(vboIds.count), &vboIds)
    }
}
