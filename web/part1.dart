// Copyright (c) 2013, John Thomas McDole.
/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
part of learn_gl;

/**
 * Staticly draw a triangle and a square!
 */
class Neuron1  extends NeuronPart {
  GlProgram program;

  Buffer tri_buff = gl.createBuffer();
  //Buffer on_color_buff = gl.createBuffer();
  //Buffer off_color_buff = gl.createBuffer();
  double fov = 45.0;
  

  Neuron1() {
    program = new GlProgram('''
          precision mediump float;

          uniform vec4 uColor;

          void main(void) {
              gl_FragColor = uColor;
          }
        ''','''
          attribute vec3 aVertexPosition;
          //attribute vec4 aVertexColor;

          uniform mat4 uMVMatrix;
          uniform mat4 uPMatrix;

          //varying vec4 vColor;

          void main(void) {
              gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
              //vColor = aVertexColor;
          }
        ''', //['aVertexPosition', 'aVertexColor'], ['uMVMatrix', 'uPMatrix']);
      ['aVertexPosition'], ['uMVMatrix', 'uPMatrix', 'uColor']);
    gl.useProgram(program.program);

    //Create buffers but in for loop. WILL THIS MADNESS EVER END?!


      gl.bindBuffer(ARRAY_BUFFER, tri_buff);
      gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList([
           0.0,  1.0,  0.0,
          -1.0, -1.0,  0.0,
           1.0, -1.0,  0.0
          ]), STATIC_DRAW);

      /*
      gl.bindBuffer(ARRAY_BUFFER, on_color_buff);
      gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList([
           1.0,  0.0,  0.0, 1.0,
           1.0,  0.0,  0.0, 1.0,
           1.0,  0.0,  0.0, 1.0
           ]), STATIC_DRAW);


      gl.bindBuffer(ARRAY_BUFFER, off_color_buff);
      gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList([
           1.0,  1.0,  1.0, 1.0,
           1.0,  1.0,  1.0, 1.0,
           1.0,  1.0,  1.0, 1.0
           ]), STATIC_DRAW);
      */

    // Specify the color to clear with (black with 100% alpha) and then enable
    // depth testing.
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
  }


  /**
   * Write the matrix uniforms (model view matrix and perspective matrix) so
   * WebGL knows what to do with them.
   */
void setMatrixUniforms() {
    gl.uniformMatrix4fv(program.uniforms['uPMatrix'], false, pMatrix.buf);
    gl.uniformMatrix4fv(program.uniforms['uMVMatrix'], false, mvMatrix.buf);
  }

  void animate(num now) {
    // We're not animating the scene, but if you want to experiment, here's
    // where you get to play around.
  }

  void handleKeys() {
    // We're not handling keys right now, but if you want to experiment, here's
    // where you'd get to play around.
  }

  void drawNeurons(int viewHeight, int viewWidth, num aspect, int ro, int co){
    // Basic viewport setup and clearing of the screen
    print ("in draw neuons");
    gl.viewport(0, 0, viewWidth, viewHeight);
    gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
    gl.enable(DEPTH_TEST);
    gl.disable(BLEND);
    
    double rows = ro.toDouble();
    double cols = co.toDouble();

    // Setup the perspective - you might be wondering why we do this every
    // time, and that will become clear in much later lessons. Just know, you
    // are not crazy for thinking of caching this.
    pMatrix = Matrix4.perspective(fov, aspect, 0.1, 100.0);
      double radians = fov * (PI/180);
      double unit_width = 2*75*tan(radians/2);
      print (unit_width);
      
      // Calculate space per neuron
      double neuron_volume_w = (cols*2);
      double num_of_spaces_w = cols + 1;
      double volume_of_spaces_w = unit_width-neuron_volume_w;
      double volume_of_a_space_w = volume_of_spaces_w/num_of_spaces_w;

      double neuron_volume_h = (rows*2);
      double num_of_spaces_h = rows+1 ;
      double volume_of_spaces_h = unit_width-neuron_volume_h;
      double volume_of_a_space_h = volume_of_spaces_h/num_of_spaces_h;
      

      

    // First stash the current model view matrix before we start moving around.
    mvPushMatrix();

    mvMatrix.translate([-((unit_width/2)),-(unit_width/2)+4, -75.0]);
    
    // triangle color
    double r = 1.0;
    double g = 0.0;
    double b = 0.0;
    double a = 1.0;

    for (int j = 0; j < cols; j++){
      if (j != 0){
        //Every time we reset the mvMatrix we want to place it in the upper left corner
        mvMatrix.translate([-((unit_width/2)),-(unit_width/2)+4, -75.0]);

        //Move a volume of space and a neuron size(2) in x dir per neuron already drawn
        //Add +1 space for the edge
        int spaces_needed = j+1;
        int neurons_already_drawn = j;
        mvMatrix.translate([spaces_needed*volume_of_a_space_w+(neurons_already_drawn)*2,0, 0]);
      }else{
        mvMatrix.translate([(j+1)*volume_of_a_space_w,0, 0]);
      }
    for (int i = 0; i < rows; i++){
      gl.bindBuffer(ARRAY_BUFFER,tri_buff);
      gl.vertexAttribPointer(program.attributes['aVertexPosition'], 3, FLOAT, false, 0, 0);
      //gl.bindBuffer(ARRAY_BUFFER, on_color_buff);
      //gl.vertexAttribPointer(program.attributes['aVertexColor'], 4, FLOAT, false, 0, 0);
      
      // triangle color
      g -= 1.0/255.0;
      if (g < 0.0) g = 1.0;
      b = g;
      gl.uniform4f(program.uniforms['uColor'], r, g, b, a);
      
      setMatrixUniforms();
      gl.drawArrays(TRIANGLE_STRIP, 0, 3);
      mvMatrix.translate([0.0, volume_of_a_space_h+2, 0.0]);
    }
    mvPopMatrix();
    mvPushMatrix();
    }
    
  }
}
