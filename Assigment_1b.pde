/* 
Please increase maximum available memory as otherwise it 
will throw a Runtime Exception for OutOfMemoryError
*/
import com.jogamp.opengl.GLProfile;
{
  GLProfile.initSingleton();
}

ArrayList<Orb> orbs = new ArrayList<Orb>(15);
String[] TEXTURES = { "grass.jpg", "mars.jpg" , "earth.jpg", "uranus.jpg", "wood.jpg", "abstract.jpg"};
int numberOfTextures = TEXTURES.length;

//Physics constants 
float GRAVITY = 1;
float SPRING = 0.65;
float FRICTION = -0.95;
float ENERGY_LOST = 0.8;
float GRAVITY_LOST = 0.65;

class Orb {
    //These will be used to store position and speed of the orb
    int x;
    float xSpeed;
    int y;
    float ySpeed;
    int z;
    float zSpeed;
    
    //To keep track of whether the orb is still moving
    boolean verticleMovement;
    boolean horizontalMovement;
    
    PShape orb;
    int orbSize;
    PImage texture;
    
    Orb(int x, int y, int z) {
        this.x = x;
        this.y = y;
        this.z = z;
        
        // Load a random texture
        int index = int(random(0, numberOfTextures));
        texture = loadImage(TEXTURES[index]);
        
        //Generate a random orb size and assign random speeds
        orbSize = 45;
        xSpeed = int(random( - 30,40));
        ySpeed = int(random( - 15,10));
        zSpeed = int(random( - 10,70));
        
        orb = createShape(SPHERE, orbSize);
        orb.setTexture(texture);
        orb.setStroke(false); //to display textures better
        
        // Begin movement
        verticleMovement = true;
        horizontalMovement = true;
    }
    
    void spawnOrb() {
        // push/pull matrix to avoid transforming other orbs
        pushMatrix();
        translate(x,y,z);
        shape(orb, 0,0);
        popMatrix();
        
    }
    
    
    /* CODE DECLARATION 
    The following code is based off these two references:
    1. https://www.youtube.com/watch?v=9iaEqGOh5WM&list=PLRqwX-V7Uu6bR4BcLjHHTopXItSjRA7yG&index=4
    2. https://processing.org/examples/bouncybubbles.html 
    */
    void checkCollision() {
        for (Orb orb : orbs) {
            
            // Use pythag to calculate
            float xDist = orb.x - x;
            float yDist = orb.y - y;
            // float zDist = orb.z - z;
            float c = sqrt((xDist * xDist) + (yDist * yDist));
            // float dist = orb.orb_size/2 + orb_size/2;
            
            //Collision has occured
            if (orbSize > c) {
                float theta = atan2(yDist, xDist);
                float sine = sin(theta);
                float cosine = cos(theta);
                float tangent = sine / cosine;
                
                float tY = (sine * orbSize) + y;
                float ay = (tY - orb.y) * SPRING; // slows down after collision
                ySpeed -= ay;
                orb.ySpeed += ay;
                
                float tX = (cosine * orbSize) + x;
                float ax = (tX - orb.x) * SPRING;
                xSpeed -= ax;
                orb.xSpeed += ax;
                
                // float tZ = (tangent * orbSize) + z;
                // float az = (tZ - orb.z) * SPRING;
                // zSpeed -= az;
                // orb.zSpeed += az;
                
            }
            
        }
    }
    /* CODE DECLARATION 
    The following code is based off this reference:
    21 https://processing.org/examples/bouncybubbles.html 
    */
    void verticleGravity() {
        float prevSpeed = ySpeed;
        
        //To avoid infinite bounces, if too slow then simply stop the movement
        if (abs(prevSpeed) < 5 && abs(ySpeed) < 5 && y > width - orbSize / 2) {
            verticleMovement = false;
        }

        // To avoid bouncing in place infinitely
        if (!horizontalMovement && ySpeed < 3) {
          ySpeed *= GRAVITY_LOST;
        }
        
        // Update our y values and speed with our GRAVITY constant
        y += ySpeed + GRAVITY;
        ySpeed += GRAVITY; 
        
        // Check boundary collision - if it hits, slow it down a little
        if (y <= 0) {
            y = 0;
            ySpeed *= FRICTION * ENERGY_LOST; // Friction slows it down to 95% of original speed
        }
        
        if (y > width) {
            y = width;
            ySpeed *=  FRICTION * ENERGY_LOST; 
        }
    }
    
    void horizontalGravity() {
        x += xSpeed;
        if (!verticleMovement) {
            xSpeed *= GRAVITY_LOST;
        }
        if (abs(xSpeed) < 2 || !verticleMovement) {
            horizontalMovement = false;
        }
        if (x > width) {
            xSpeed *= -GRAVITY_LOST;
            x = width;
        }
        else if (x <= 0) {
            xSpeed *= -GRAVITY_LOST;
            x = 0;
        }
    }  
    
    void depthGravity() {
        z += zSpeed;
        if (!verticleMovement) {
            zSpeed *= FRICTION * ENERGY_LOST;
        }
        if (abs(zSpeed) < 3 || !verticleMovement) {
            horizontalMovement = false;
        }
        if (z < - width) {
            zSpeed *= FRICTION * ENERGY_LOST;
            z = -width;
        }
        else if (z >= 0) {
            zSpeed *= FRICTION * ENERGY_LOST;
            z = 0;
        }
        
    }
    
    
}

void setup() {
    //fullScreen(P3D);
    size(640,640,P3D);
    background(0);
    smooth();
}

void draw() {
    
    pushMatrix();
    background(0);
    translate(width / 2, height / 2, -width / 2);
    noFill();
    stroke(255);
    box(width);
    popMatrix();
    
    if (mousePressed) {
        orbs.add(new Orb(mouseX, mouseY, 0));
    }
    for (Orb o : orbs) {
        o.spawnOrb();
        o.checkCollision();
        if (o.verticleMovement) {
            o.verticleGravity();
        }
        if (o.horizontalMovement) {
            o.horizontalGravity();
            o.depthGravity();
        }
        
    }
}
