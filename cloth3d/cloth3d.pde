import toxi.physics.*;
import toxi.physics.behaviors.*;
import toxi.physics.constraints.*;
import toxi.geom.*;

int cols=40;
int rows=40;
Particle[][] particles=new Particle[cols][rows];
ArrayList<Spring> springs;

float w=10;

VerletPhysics physics;

void setup(){
  size(800,800,P3D);
  //particles=new ArrayList<Particle>();
  springs=new ArrayList<Spring>();
  
  physics=new VerletPhysics();
  Vec3D gravity =new Vec3D(0,0.2,0);
  GravityBehavior gb=new GravityBehavior(gravity);
  physics.addBehavior(gb);
  
  float x=-200;
  
  for(int i=0;i<cols;i++){
    float z=-200;
    for(int j=0;j<rows;j++){
      Particle p=new Particle(x,0,z);
      particles[i][j]=p;
      physics.addParticle(p);
      z=z+w;

    }
    x=x+w;
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
  //for (int i=0;i<particles.size()-1;i++){
   // Particle a=particles.get(i);
   // Particle b=particles.get(i+1);
   // Spring s=new Spring(a,b);
    //springs.add(s);
   // physics.addSpring(s);
  //}
  particles[0][0].lock();
  particles[cols-1][0].lock();
  particles[0][rows-1].lock();
  particles[cols-1][rows-1].lock();
  //Particle p1=particles.get(0);
  //p1.lock();
  //Particle p2=particles.get(39);
  //p2.lock();
}

float a=0;
void draw(){
  background(51);
  translate(width/2,height/2);
  rotateY(a);
  rotateX(-0.3);
  a+=0.001;
  physics.update();

  for(int i=0;i<cols;i++){
    for(int j=0;j<rows;j++){
     //particles[i][j].display();
    }
  }
  for(Spring s: springs){
    s.display();
  }
}
