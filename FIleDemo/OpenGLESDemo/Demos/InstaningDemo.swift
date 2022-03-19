//
//  InstaningDemo.swift
//  OpenGLESDemo
//
//  Created by apple on 2021/7/28.
//

import Foundation
import OpenGLES
import GLKit

final class InstaningDemo: DemoProtocol {
 
    static let position_loc:GLuint = 0
    static let color_loc:GLuint = 1
    static let mvpMat_loc:GLuint = 2
    
    private(set) var userData:DataContext
    
    init?() {
        let vShaderStr = """
        #version 300 es
        layout(location = 0) in vec4 a_position;
        layout(location = 1) in vec4 a_color;
        layout(location = 2) in mat4 a_mvpMatrix;
        out vec4 v_color;
        void main()
        {
            v_color = a_color;
            gl_Position = a_mvpMatrix * a_position;
        }
        """
        
        let fShaderStr = """
        #version 300 es
        precision mediump float;
        in vec4 v_color;
        layout(location = 0) out vec4 outColor;
        void main()
        {
            outColor = v_color;
        }
        """
        var ud = DataContext()
        do {
            let shaderComplier = ShaderCompiler(vertexShaderCode: vShaderStr, fragmentShaderCode: fShaderStr)
            let shaders = try shaderComplier.complie().get()
            
            ud.propramObject = try shaderComplier.link(shaders).get()
            
        } catch {
            return nil
        }
        
        var cube = Shapes.genCube(scale: 0.1)
        
        ud.numIndices = cube.numIndices
        
        var indices = cube.indices
        var vertices = cube.vertices
        
        ///copy 索引数组到 gpu 缓存
        glGenBuffers(1, &ud.indicesIBO)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ud.indicesIBO)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLuint>.stride * ud.numIndices), &indices, GLenum(GL_STATIC_DRAW))
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)

        
        ///copy VBO 到 GPU 缓存
        glGenBuffers(1, &ud.positionVBO)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), ud.positionVBO)
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLfloat>.stride * vertices.count), &vertices, GLenum(GL_STATIC_DRAW))
        
        //Random color for each instance
        do {
            var instance = 0
            var colors:[GLubyte] = []
            srandom(0)
            while instance <  DataContext.NUM_INSTANCES {
                colors.append(GLubyte(arc4random() % 255))
                colors.append(GLubyte(arc4random() % 255))
                colors.append(GLubyte(arc4random() % 255))
                colors.append(0)

                instance += 1
            }
            
            glGenBuffers(1, &ud.colorVBO)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), ud.colorVBO)
            glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLubyte>.stride * colors.count), &colors, GLenum(GL_STATIC_DRAW))
        }
        
        //Allocate storage to store MVP per instance
        do {
            var instance = 0
            
            while instance < DataContext.NUM_INSTANCES  {
                ud.angle[instance] = GLfloat(arc4random() % 32768) / 32767.0 * 360
                instance += 1
            }
            
            glGenBuffers(1, &ud.mvpVBO)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), ud.mvpVBO)
            ///4x4矩阵
            glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<GLfloat>.stride * 16 * DataContext.NUM_INSTANCES), nil,GLenum(GL_DYNAMIC_DRAW))
            
        }
        
        ///将OpenGL恢复成默认
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glClearColor(1.0, 1.0, 1.0, 0.0)
        
        userData = ud
     
    }
    
    deinit {
        self.shutDown()
    }
    
    func shutDown() {
        userData.clearGL()
    }
    
    func isSupportUpdate() -> Bool {
        return true
    }
    
    func update()  {
        self.update(deltaTime: 0.06)
    }
    
    func update(deltaTime:Float) {
        
        
        let aspect = userData.width / userData.height
        
        var perspective:Matrix4x4 = Matrix4x4()
        perspective.becomeIdentity()
        
        perspective.perspective(fovy: 60.0, aspect: aspect, nearZ: 1.0, farZ: 20.0)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), userData.mvpVBO)
        
        guard let matrixBuf = glMapBufferRange(GLenum(GL_ARRAY_BUFFER), 0, GLsizeiptr(Matrix4x4.stride) * DataContext.NUM_INSTANCES, GLbitfield(GL_MAP_WRITE_BIT)) else {
            debugPrint("glMapBufferRange error:\(glGetError())")
            return
        }
        
        
        let aMatBuf = matrixBuf.bindMemory(to: GLfloat.self, capacity: 16 * DataContext.NUM_INSTANCES)
        
        //Compute a per-instance MVP that translate and rotates each instance differnetly
        let numRows = Int(sqrt(Double(DataContext.NUM_INSTANCES)))
        let numColums = numRows
        var instance = 0
        
        var modelView = Matrix4x4()
      
        while instance < DataContext.NUM_INSTANCES {

            modelView.becomeIdentity()

            let translateX = ( (Float)( instance % numRows) / (Float)(numRows) * 2.0 - 1.0 )

            let translateY = ((Float)( instance / numColums) / (Float)(numColums)) * 2.0 - 1.0

            modelView.translate(tx: translateX, ty: translateY, tz: -2.0)

            userData.angle[instance] += (deltaTime * 40.0)

            if (userData.angle[instance] >= 360.0) {
                userData.angle[instance] -= 360.0
            }

            //模型视图矩阵旋转
            modelView.rotate(angle: userData.angle[instance], x: 1.0, y: 0.0, z: 1.0)

            //乘以投影矩阵
            modelView.mutiply(perspective)

            for r in 0..<modelView.rows {
                for c in 0..<modelView.cols {
                    aMatBuf[instance * 16 + (r * modelView.cols + c)] = modelView[at: r, c]
                }
            }

            instance += 1
        }

        glUnmapBuffer(GLenum(GL_ARRAY_BUFFER))
    }
    
    
    func draw(width:Int,height:Int) {
        
        userData.width = GLfloat(width)
        userData.height = GLfloat(height)
        
        glViewport(0, 0, GLsizei(width), GLsizei(height))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glUseProgram(userData.propramObject)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), userData.positionVBO)
        glVertexAttribPointer(InstaningDemo.position_loc, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 3), UnsafePointer(bitPattern: 0))
        glEnableVertexAttribArray(InstaningDemo.position_loc)
        
        ///load the instance color buffer
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), userData.colorVBO)
        glVertexAttribPointer(InstaningDemo.color_loc,
                              4,
                              GLenum(GL_UNSIGNED_BYTE),
                              GLboolean(GL_TRUE),
                              GLsizei(MemoryLayout<GLubyte>.stride * 4),
                              UnsafePointer(bitPattern: 0))
        glEnableVertexAttribArray(InstaningDemo.color_loc)
        //One color per instance
        glVertexAttribDivisor(InstaningDemo.color_loc, 1)
        
        
        // load the instance MVP buffer
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), userData.mvpVBO)
        
        ///Load each matrix row of the mvp.
        ///Each rows gets an increasing attribute location
        let matrixStride = GLsizei(Matrix4x4.stride)
        glVertexAttribPointer(InstaningDemo.mvpMat_loc + 0, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), matrixStride, UnsafePointer(bitPattern: 0))
        glVertexAttribPointer(InstaningDemo.mvpMat_loc + 1, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), matrixStride, UnsafePointer(bitPattern: MemoryLayout<GLfloat>.stride * 4 ))
        glVertexAttribPointer(InstaningDemo.mvpMat_loc + 2, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), matrixStride, UnsafePointer(bitPattern: MemoryLayout<GLfloat>.stride * 8 ))
        glVertexAttribPointer(InstaningDemo.mvpMat_loc + 3, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), matrixStride, UnsafePointer(bitPattern: MemoryLayout<GLfloat>.stride * 12 ))
        
        glEnableVertexAttribArray(InstaningDemo.mvpMat_loc + 0)
        glEnableVertexAttribArray(InstaningDemo.mvpMat_loc + 1)
        glEnableVertexAttribArray(InstaningDemo.mvpMat_loc + 2)
        glEnableVertexAttribArray(InstaningDemo.mvpMat_loc + 3)
        
        
        //One Mvp per instance
        glVertexAttribDivisor(InstaningDemo.mvpMat_loc + 0, 1)
        glVertexAttribDivisor(InstaningDemo.mvpMat_loc + 1, 1)
        glVertexAttribDivisor(InstaningDemo.mvpMat_loc + 2, 1)
        glVertexAttribDivisor(InstaningDemo.mvpMat_loc + 3, 1)
        
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), userData.indicesIBO)
        
        //Draw the cubes
        glDrawElementsInstanced(GLenum(GL_TRIANGLES),
                                GLsizei(userData.numIndices),
                                GLenum(GL_UNSIGNED_INT),
                                UnsafeRawPointer(bitPattern: 0),
                                GLsizei(DataContext.NUM_INSTANCES))
    }
    
    
   
}
