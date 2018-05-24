import toxi.geom.*;
import toxi.physics.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import toxi.physics2d.constraints.*;

int cols=20;
int rows=20;
Particle[][] particles=new Particle[cols][rows];
ArrayList<Spring> springs;

float w=20;

VerletPhysics2D physics;

void setup(){
  size(800,800);
  //particles=new ArrayList<Particle>();
  springs=new ArrayList<Spring>();
  
  physics=new VerletPhysics2D();
  Vec2D gravity =new Vec2D(0,0.2);
  GravityBehavior gb=new GravityBehavior(gravity);
  physics.addBehavior(gb);
  
  float x=100;
  
  for(int i=0;i<cols;i++){
    float y=10;
    for(int j=0;j<rows;j++){
      Particle p=new Particle(x,y);
      particles[i][j]=p;
      physics.addParticle(p);
      y=y+w;

    }
    x=x+w;
  }
  for(int i=0;i<cols-1;i++){
    for(int j=0;j<rows-1;j++){
     Particle a=particles[i][j];
     Particle b=particles[i+1][j];
     Particle c=particles[i][j+1];
     Spring s1=new Spring(a,b);
     Spring s2=new Spring(a,c);
     springs.add(s1);
     springs.add(s2);
     physics.addSpring(s1);
     physics.addSpring(s2);
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
  //Particle p1=particles.get(0);
  //p1.lock();
  //Particle p2=particles.get(39);
  //p2.lock();
}

void draw(){
  background(51);
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
