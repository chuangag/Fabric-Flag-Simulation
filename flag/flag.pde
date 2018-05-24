import toxi.physics.*;
import toxi.physics.behaviors.*;
import toxi.physics.constraints.*;
import toxi.geom.*;

int resolution=2;
int cols=80/resolution;
int rows=80/resolution;
Particle[][] particles=new Particle[cols][rows];
ArrayList<Spring> springs;
Vec3D wind=new Vec3D(0,0,0);
AABB world=new AABB(400);
float w=5*resolution;
Vec3D attachPoint1;
Vec3D attachPoint2;

VerletPhysics physics;
PImage background;
PImage texture;

void setup(){
  size(800,800,P3D);
  background=loadImage("KTH.jpg");
  
  springs=new ArrayList<Spring>();
  
  physics=new VerletPhysics();
  Vec3D gravity =new Vec3D(0,0.1,0);
  GravityBehavior gb=new GravityBehavior(gravity);
  physics.addBehavior(gb);
  physics.setWorldBounds(world);
  
  float x=cols*w/2-400;
  
  for(int i=0;i<cols;i++){
    float y=-rows*w/2;
    for(int j=0;j<rows;j++){
      Particle p=new Particle(x,y,0);
      particles[i][j]=p;
      physics.addParticle(p);
      y+=w;
    }
    x+=w;
  }
  
  
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      Particle a = particles[i][j];
      if (i != cols-1) {
        Particle b1 = particles[i+1][j];
        Spring s1 = new Spring(a, b1);
        springs.add(s1);
        physics.addSpring(s1);
      }
      if (j != rows-1) {
        Particle b2 = particles[i][j+1];
        Spring s2 = new Spring(a, b2);
        springs.add(s2);
        physics.addSpring(s2);
      }
    }
  }
  // set attach points
  particles[0][0].lock();
  particles[0][rows-1].lock();
  attachPoint1=new Vec3D(particles[0][0].x,particles[0][0].y,particles[0][0].z);
  attachPoint2=new Vec3D(particles[0][rows-1].x,particles[0][rows-1].y,particles[0][rows-1].z);
  
  texture=loadImage("flag.jpg");
}

float a=0;
void draw(){
  background(background);
  //background(51);
  translate(width/2,height/2);
  //rotateY(a);
  //rotateX(-0.3);
  //a+=0.001;
  physics.update();

  noFill();
  noStroke();
  //strokeWeight(1);
  textureMode(NORMAL);
  
  float xoff=0; //offset for perlin noise
  for(int j=0;j<rows-1;j++){
    xoff+=0.1;
    float yoff=0;
    beginShape(TRIANGLE_STRIP);
    texture(texture);
    for(int i=0;i<cols-1;i++){
      yoff+=0.1;
      float windnoiseX=noise(xoff,yoff)*0.5;
      float windnoiseY=noise(xoff+1000,yoff+1000)*0.5;
      float windnoiseZ=noise(xoff+2000,yoff+2000)*0.5;
      //particles[i][j].display();
      particles[i][j].clearForce();
    
      //Blow off the flag if wind is too strong
      if(wind.dot(wind)>9){
        particles[0][0].unlock();
        particles[0][rows-1].unlock();  
      }
      else if(particles[0][0].isLocked())
        particles[i][j].addForce(wind.add(windnoiseX,windnoiseY,windnoiseZ));
        
      // uv mapping for texture
      float u=map(i,0,cols,0,1);
      float v1=map(j,0,rows,0,1);
      float v2=map(j+1,0,rows,0,1);
      // TODO: only texture when the flag is connecte
      
      if(physics.getSpring(particles[i][j],particles[i][j+1])==null){
        Particle p2=particles[i][j+1];
        if(physics.getSpring(particles[i-1][j+1],particles[i][j+1])!=null)
          vertex(p2.x,p2.y,p2.z,u,v2);
        endShape();
        beginShape(TRIANGLE_STRIP);
        texture(texture);
        Particle p1=particles[i][j];
        if(physics.getSpring(particles[i-1][j+1],particles[i][j+1])!=null)
          vertex(p1.x,p1.y,p1.z,u,v1);
        continue;
      }
      Particle p1=particles[i][j];
      vertex(p1.x,p1.y,p1.z,u,v1);
      Particle p2=particles[i][j+1];
      vertex(p2.x,p2.y,p2.z,u,v2);
    }
    endShape();
  }
  
  for(Spring s: springs){
    //s.display();
  }
  stroke(204, 102, 0);
  strokeWeight(8);
  line(cols*w/2-400,-rows*w/2,cols*w/2-400,height);
}

void keyPressed() {
  // Controls the direction of the major wind
  if (keyCode == LEFT) {
    wind=wind.add(-1,0,0);
  }
  if (keyCode == UP) {
    wind=wind.add(0,0,-0.2);
  }
  if (keyCode == RIGHT) {
    wind=wind.add(1,0,0);
  }
  if (keyCode == SHIFT) {
    wind=wind.add(0,0.2,0);
  }
  if (keyCode == DOWN) {
    wind=wind.add(0,0,0.2);
  }
  if (keyCode == ENTER) {
    wind=wind.add(0,-0.2,0);
  }
  
  // Tear the flag apart
  if (keyCode == ALT){
    println("tearing");
    for(int n=0;n<rows-1;n++){
       if(physics.getSpring(particles[n][n],particles[n+1][n])!=null ){
          springs.remove(physics.getSpring(particles[n][n],particles[n+1][n]));
          physics.removeSpring(physics.getSpring(particles[n][n],particles[n+1][n]));
       }
       if(physics.getSpring(particles[n+1][n],particles[n+1][n+1])!=null ){
          springs.remove(physics.getSpring(particles[n+1][n],particles[n+1][n+1]));
          physics.removeSpring(physics.getSpring(particles[n+1][n],particles[n+1][n+1]));
       }
    }
  }
  
  // make random holes on the flag
  if (keyCode == CONTROL){
    println("breaking");
    int xk=int(random(1,rows-6));
    int yk=int(random(1,cols-6));
    int xs=int(random(2,5));
    int ys=int(random(2,5));
    for(int i=xk;i<xk+xs;i++){
      for(int j =yk;j<yk+ys;j++){
       if(physics.getSpring(particles[i][j],particles[i+1][j])!=null ){
          springs.remove(physics.getSpring(particles[i][j],particles[i+1][j]));
          physics.removeSpring(physics.getSpring(particles[i][j],particles[i+1][j]));
       }
       if(physics.getSpring(particles[i+1][j],particles[i+1][j+1])!=null ){
          springs.remove(physics.getSpring(particles[i+1][j],particles[i+1][j+1]));
          physics.removeSpring(physics.getSpring(particles[i+1][j],particles[i+1][j+1]));
       }
      }  
    }
  }
  
  println(wind);
}

void mouseDragged() 
{
  float topy=-rows*w/2;
  
  println("lower flag");
  //println(topy,mouseY-400,particles[0][0].y);
  if(mouseY-600>topy){
    Vec3D newap1=attachPoint1.add(0,(mouseY-400),0);
    Vec3D newap2=attachPoint2.add(0,(mouseY-400),0);
    particles[0][0].set(newap1);
    particles[0][rows-1].set(newap2);
    particles[0][0].update();
    particles[0][rows-1].update();
  }
}
