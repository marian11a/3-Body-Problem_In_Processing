class Mover {
  PVector pos;
  PVector vel;
  PVector acc;
  float mass;
  float r;
  color c;
  ArrayList<PVector> trail;

  Mover(float x, float y, float vx, float vy, float m, color c) {
    pos = new PVector(x, y);
    vel = new PVector(vx, vy);
    acc = new PVector(0, 0);
    mass = m;
    r = sqrt(mass) * 2;
    this.c = c;
    trail = new ArrayList<PVector>();
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acc.add(f);
  }

  void attract(Mover mover) {
    PVector force = PVector.sub(pos, mover.pos);
    float distanceSq = constrain(force.magSq(), 100, 1000);
    float G = 1;
    float strength = (G * (mass * mover.mass)) / distanceSq;
    force.setMag(strength);
    mover.applyForce(force);
  }

  void attractTo(PVector target, float targetMass) {
    PVector force = PVector.sub(target, pos);
    float distanceSq = constrain(force.magSq(), 100, 1000);
    float G = 1;
    float strength = (G * (mass * targetMass)) / distanceSq;
    force.setMag(strength);
    applyForce(force);
  }

  void update() {
    vel.add(acc);
    pos.add(vel);
    acc.set(0, 0);
    
    // Add current position to trail
    trail.add(pos.copy());
    
    // Limit trail size
    if (trail.size() > 100) {
      trail.remove(0);
    }
  }

  void show() {
    // Draw the trail
    noFill();
    beginShape();
    for (PVector v : trail) {
      stroke(red(c), green(c), blue(c), 1000);
      vertex(v.x, v.y);
    }
    endShape();
    
    // Draw the current position
    noStroke();
    for (int i = 5; i > 0; i--) {
      fill(red(c), green(c), blue(c), 7);
      ellipse(pos.x, pos.y, r * 2 + i * 10, r * 2 + i * 10);
    }
    fill(c);
    ellipse(pos.x, pos.y, r * 2, r * 2);
  }
}

Mover m1, m2, m3, planet;
PVector centralAttractor;
float centralAttractorMass = 5;
int numStars = 400; // Number of stars
PVector[] stars; // Array to store star positions

void setup() {
  size(1600, 900, P2D);
  m1 = new Mover(width/2 + 300, height/2, 0, 2, 60, color(255, 253, 194));
  m2 = new Mover(width/2 - 500, height/2, 0, -4, 80, color(177, 219, 251));
  m3 = new Mover(width/2, height/2 + 370, -4, 0, 70, color(255, 225, 143));
  planet = new Mover(width/2 + 380, height/2, 0, -3, 10, color(49, 196, 59));
  centralAttractor = new PVector(width/2, height/2);
  
  // Initialize stars
  stars = new PVector[numStars];
  for (int i = 0; i < numStars; i++) {
    float starSize = random(1) > 0.5 ? 1 : 0.5;
    stars[i] = new PVector(random(width), random(height), starSize);
  }
}

void draw() {
  background(12, 1, 25);
  
  // Draw stars
  fill(255);
  for (int i = 0; i < numStars; i++) {
    float starSize = stars[i].z;
    ellipse(stars[i].x, stars[i].y, starSize, starSize);
  }
  
  // Attract each Mover to the central attractor (except the planet)
  m1.attractTo(centralAttractor, centralAttractorMass);
  m2.attractTo(centralAttractor, centralAttractorMass);
  m3.attractTo(centralAttractor, centralAttractorMass);

  // Attract each Mover to each other
  m1.attract(m2);
  m1.attract(m3);
  m1.attract(planet);
  
  m2.attract(m1);
  m2.attract(m3);
  m2.attract(planet);
  
  m3.attract(m1);
  m3.attract(m2);
  m3.attract(planet);
  
  planet.attract(m1);
  planet.attract(m2);
  planet.attract(m3);
  
  m1.update();
  m2.update();
  m3.update();
  planet.update();
  
  m1.show();
  m2.show();
  m3.show();
  planet.show();
}
