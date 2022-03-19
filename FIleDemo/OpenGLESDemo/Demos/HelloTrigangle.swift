//
//  Hello_Trigangle.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/7/20.
//


import Foundation
import OpenGLES
import GLKit

/// https://www.cnblogs.com/duzhaoquan/p/12905065.html
///
/// https://www.raywenderlich.com/9211-moving-from-opengl-to-metal

class HelloTrigangle:DemoProtocol {
    func draw(width: Int, height: Int) {
        self.width = GLsizei(width)
        self.height = GLsizei(height)
        
        var vVertices:[GLfloat] = [
            0.0, 0.5 , 0.0,
            -0.5 ,-0.5,0.0,
            0.5,-0.5,0.0
        ]
        
        ///设置视口大小
        glViewport(0, 0, self.width,self.height)
        
        ///清除颜色缓冲区
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        
        ///使用编译好的顶点和片元着色器
        glUseProgram(programObject)
        
        ///加载顶点数据
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, &vVertices)
        
        glEnableVertexAttribArray(0)
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
        
    }
    
    
    let programObject:GLuint
    
    var width:GLsizei = 320
    var height:GLsizei = 480
    
    private(set) var glView:GLKView? = nil
        
    /// 初始化,编译顶点和片元着色器,失败返回nil
    required init?() {

        let vShaderStr:String = """
            #version 300 es
            layout(location = 0) in vec4 vPosition;
            void main()
            {
                gl_Position = vPosition;
            }
            """
        
        let fShaderStr = """
            #version 300 es
            precision mediump float;
            out vec4 fragColor;
            void main()
            {
                fragColor = vec4 ( 1.0, 0.0, 0.0, 1.0 );
            }
            """
        
        let shaderCompiler = ShaderCompiler(vertexShaderCode: vShaderStr, fragmentShaderCode: fShaderStr)
        
        do {
            
            let (vertexShader,fragmentShader) = try shaderCompiler.complie().get()
            
            programObject = try shaderCompiler.link(vertexShader: vertexShader, fragmentShader: fragmentShader).get()
            
        } catch {
            return nil
        }
    
        glClearColor(0.0, 0.0, 0.0, 0.0)
    }
    
    
    deinit {
        glDeleteProgram(programObject)
    }
    
   
    
    func shutDown() {
        glDeleteProgram(programObject)
    }
    
}





