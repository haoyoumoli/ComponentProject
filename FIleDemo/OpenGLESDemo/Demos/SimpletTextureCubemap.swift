//
//  SimpletTextureCubeMap.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/8/17.
//

import Foundation
import OpenGLES


final class SimpletTextureCubemap:DemoProtocol {
    private(set) var programObject:GLuint = 0
    private(set) var samplerLoc:GLint = 0
    private(set) var textureId:GLuint = 0
    
    private(set) var sphere:Shapes.Model? = nil
    
    init?() {
        let vShaderStr = """
        #version 300 es
        layout(location = 0) in vec4 a_position;
        layout(location = 1) in vec3 a_normal;
        out vec3 v_normal;
        void main()
        {
            gl_Position = a_position;
            v_normal = a_normal;
        }
        """
        let fShaderStr = """
        #version 300 es
        precision mediump float;
        in vec3 v_normal;
        layout(location = 0) out vec4 outColor;
        uniform samplerCube s_texture;
        void main()
        {
            outColor = texture(s_texture,v_normal);
        }
        """
        
        let shaderCompiler = ShaderCompiler.init(vertexShaderCode: vShaderStr, fragmentShaderCode: fShaderStr)
        do {
            let result = try shaderCompiler.complie().get()
            programObject = try shaderCompiler.link(result).get()
        } catch {
            return nil
        }
        
        "s_texture".withCString { p in
            let pointer:UnsafePointer<GLchar>? = p
            self.samplerLoc = glGetUniformLocation(self.programObject, pointer)
        }
        
        
        textureId = SimpletTextureCubemap.createSimpleTextureCubemap()
        
        sphere = Shapes.genSphere(numSlices: 20, radius: 0.75)
        
        glClearColor(1.0, 1.0, 1.0, 0.0)
        
    }
    
    deinit {
        self.shutDown()
    }
    
    func draw(width: Int, height: Int) {
        
        guard var sphere = self.sphere else {
            return
        }
        
        glViewport(0, 0, GLsizei(width), GLsizei(height))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glCullFace(GLenum(GL_BACK))
        glEnable(GLenum(GL_CULL_FACE))
        
        glUseProgram(programObject)
        
        
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, &sphere.vertices)
        
        glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, &sphere.normals)
        
        glEnableVertexAttribArray(0)
        glEnableVertexAttribArray(1)
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_CUBE_MAP), textureId)
        
        // Set the sampler texture unit to 0
        glUniform1i(samplerLoc, 0)
        
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(sphere.numIndices), GLenum(GL_UNSIGNED_INT), &sphere.indices)

    }
    
    func shutDown() {
        glDeleteTextures(1, &textureId)
        glDeleteProgram(programObject)
    }
    
    
}


//MARK: -
extension SimpletTextureCubemap {
    static func createSimpleTextureCubemap() -> GLuint {
        var textureId:GLuint = 0
        var cubePixels:[GLubyte] = [
            // Face 0 - Red
            255, 0, 0,
            // Face 1 - Green,
            0, 255, 0,
            // Face 2 - Blue
            0, 0, 255,
            // Face 3 - Yellow
            255, 255, 0,
            // Face 4 - Purple
            255, 0, 255,
            // Face 5 - White
            255, 255, 255
        ]
        
        glGenTextures(1, &textureId)
        glBindTexture(GLenum(GL_TEXTURE_CUBE_MAP), textureId)
        
        // Load the cube face - Positive X
        glTexImage2D(GLenum(GL_TEXTURE_CUBE_MAP_POSITIVE_X), 0, GL_RGB, 1, 1, 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), &cubePixels)
    
        
        cubePixels.withUnsafeBufferPointer { p in
            // Load the cube face - Negative X
            glTexImage2D(GLenum(GL_TEXTURE_CUBE_MAP_NEGATIVE_X), 0, GL_RGB, 1, 1, 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), p.baseAddress! + (1 * 3))
        }
        
        cubePixels.withUnsafeBufferPointer { p in
            // Load the cube face - Positive Y
            glTexImage2D(GLenum(GL_TEXTURE_CUBE_MAP_POSITIVE_Y), 0, GL_RGB, 1, 1, 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), p.baseAddress! + (2 * 3) )
        }
        
        
        cubePixels.withUnsafeBufferPointer { p in
            //Load the cube face - Negative Y
            glTexImage2D(GLenum(GL_TEXTURE_CUBE_MAP_NEGATIVE_Y), 0, GL_RGB, 1, 1, 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), p.baseAddress! + (3 * 3))
        }
        
        cubePixels.withUnsafeBufferPointer { p in
            // Load the cube face - Positive Z
            glTexImage2D(GLenum(GL_TEXTURE_CUBE_MAP_POSITIVE_Z), 0, GL_RGB, 1, 1, 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), p.baseAddress! + (4 * 3))
        }
        
        
        cubePixels.withUnsafeBufferPointer { p in
            //Load the cube face - Negative Z
            glTexImage2D(GLenum(GL_TEXTURE_CUBE_MAP_NEGATIVE_Z), 0, GL_RGB, 1, 1, 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), p.baseAddress! + (5 * 3))
        }
        
        glTexParameteri(GLenum(GL_TEXTURE_CUBE_MAP), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST)
        
        glTexParameteri(GLenum(GL_TEXTURE_CUBE_MAP), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST)
        
        return textureId
    }
}
