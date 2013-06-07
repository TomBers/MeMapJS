
ParticleSystem physics;

colourPicker cp;
static int NAV=0, CREATE=1, LINK=2, NAME=3, RESET=4, ZOOMIN=5, ZOOMOUT=6, DEL=7, SAVE=8, MOVENODE=9, COL=10;

int SMALLBUTTONWIDTH=40, BUTTONWIDTH=120, BUTTONHEIGHT=40;

float zoom = 1.0, offsetX = 0, offsetY = 0;

String typedText = "";

boolean naming = false, drag=false;

int txtMX=-10000, txtMY=-10000;

PVector mousePos, zoomPos, transPos;

loadSave loadSaveObject;

String mapFileName;

ArrayList<button> buttons;
button navMode, createMode, linkMode, nameMode, resetMode, zoomIn, zoomOut, delMode, saveMode, movMode, colMode;
PFont f;
Particle namingNode, selectedNode;
int MODE = NAV;

var mapFileNamelocation = window.location.href;


Particle me;
Particle draggedNode;
Particle toCol;

void setup()
{
  //  size( window.innerWidth, window.innerHeight );
  size( 750, 750 );
  smooth();
  fill( 0 );
  ellipseMode( CENTER );

  mousePos = new PVector();
  zoomPos = new PVector();
  transPos = new PVector();

  loadSaveObject = new loadSave();

  cp = new colourPicker();
  cp.setup();

  textFont(createFont("Mono", 24));
  textAlign(CENTER, CENTER);




  buttons = new ArrayList<button>();
  navMode = new button(0, 0, BUTTONWIDTH, BUTTONHEIGHT, "Navigate", NAV);
  navMode.setSelected(true);
  buttons.add(navMode);
  zoomIn = new button(BUTTONWIDTH+10, 0, SMALLBUTTONWIDTH, BUTTONHEIGHT, "+", ZOOMIN);
  buttons.add(zoomIn);
  zoomOut = new button(BUTTONWIDTH+SMALLBUTTONWIDTH+10, 0, SMALLBUTTONWIDTH, BUTTONHEIGHT, "-", ZOOMOUT);
  buttons.add(zoomOut);
  resetMode = new button(BUTTONWIDTH+SMALLBUTTONWIDTH+SMALLBUTTONWIDTH+10, 0, SMALLBUTTONWIDTH, BUTTONHEIGHT, "=", RESET);
  buttons.add(resetMode);


  createMode = new button(0, BUTTONHEIGHT+10, BUTTONWIDTH, BUTTONHEIGHT, "Add", CREATE);
  buttons.add(createMode);
  linkMode = new button(BUTTONWIDTH+10, BUTTONHEIGHT+10, BUTTONWIDTH, BUTTONHEIGHT, "Link", LINK);
  buttons.add(linkMode);


  nameMode = new button(0, BUTTONHEIGHT+BUTTONHEIGHT+10, BUTTONWIDTH, BUTTONHEIGHT, "Name", NAME);
  buttons.add(nameMode);
  delMode = new button(BUTTONWIDTH+10, BUTTONHEIGHT+BUTTONHEIGHT+10, BUTTONWIDTH, BUTTONHEIGHT, "Delete", DEL);
  buttons.add(delMode);


  saveMode = new button(0, BUTTONHEIGHT+BUTTONHEIGHT+BUTTONHEIGHT+10, BUTTONWIDTH, BUTTONHEIGHT, "Save", SAVE);
  buttons.add(saveMode);

  movMode = new button(BUTTONWIDTH+10, BUTTONHEIGHT+BUTTONHEIGHT+BUTTONHEIGHT+10, BUTTONWIDTH, BUTTONHEIGHT, "Move", MOVENODE);
  buttons.add(movMode); 

  colMode = new button(0, BUTTONHEIGHT+BUTTONHEIGHT+BUTTONHEIGHT+BUTTONHEIGHT+10, BUTTONWIDTH, BUTTONHEIGHT, "Col", COL);
  buttons.add(colMode); 

  String[] mapName = split(mapFileNamelocation, '=');
  mapFileName = mapName[1];
  if (mapFileName =="undefined") mapFileName = "default.xml";
  physics = loadSaveObject.testMap();
}




void draw()
{
  physics.tick();       
  pushMatrix();
  scale(zoom); 
  translate(offsetX, offsetY);
  background(50);

  if (MODE == LINK && selectedNode != null) {
    fill(100);
    line( selectedNode.position.x, selectedNode.position.y, (mouseX / zoom)  - offsetX, (mouseY / zoom) - offsetY);
  }

  drawNetwork();   

  if (MODE == NAME && naming) {
    textFont(createFont("Mono", 24));
    text(typedText+(frameCount/10 % 2 == 0 ? "|" : ""), (txtMX / zoom), (txtMY / zoom));
  }     
  popMatrix();

  //    DrawButtons
  for (button b : buttons) b.display();
  cp.draw();
}

void drawNetwork() {

  stroke(180);  


  for ( int j = 0; j < physics.numberOfSprings(); j++ ) {
    Spring link = physics.getSpring( j );
    line( (link.getOneEnd().position.x ), (link.getOneEnd().position.y), (link.getTheOtherEnd().position.x), (link.getTheOtherEnd().position.y ) );
  }

  for ( int i = 0; i < physics.numberOfParticles(); i++ )
  {
    strokeWeight(2);
    Particle v = physics.getParticle( i );
    fill( v.getCol() );
    //      fill(50);
    stroke( v.getCol() );
    if (v.getCol() == color(50)) stroke(180);
    ellipse( v.position.x, v.position.y, v.getRad() * 2, v.getRad() * 2);
    stroke(255);
    fill(255);
    //      fill( v.getCol() );
    int fsize = getFontSize(v.getRad(), v.getNodeLabel());
    textFont(createFont("Mono", fsize));
    text(v.getNodeLabel(), v.position.x, v.position.y );
  }
}

int getFontSize(int rd, String st) {
  int stLength = st.length();
  int FS = (int)((rd *2)/stLength);

  return FS + 2;
}

void updateButtons() {
  for (button b : buttons) {
    if (b.buttonPressed(mousePos, zoom))
      for (button bb : buttons) if (bb.getBMode() != b.getBMode()) bb.setSelected(false);
  }
}
int getMode() {
  for (button b : buttons)
    if (b.getSelected() == true) return b.getBMode(); 
  return 0;
}  

void setMode(int nm, int om) {
  for (button b : buttons) {
    if (b.getBMode() == nm) b.setSelected(true);
    if (b.getBMode() == om) b.setSelected(false);
  }
  MODE = nm;
}






void keyPressed() {
  if (key == 'r') {
    zoom =1.0;
  }
}

void keyReleased() {

  if (MODE == NAME && namingNode !=null) {
    if (key != CODED) {
      typedText += String.fromCharCode(key);
    }
    if (keyCode == ENTER) {
      namingNode.setNodeLabel(typedText);
      namingNode.setRad(60);
      typedText = "";
      naming = false;
    }
    if (keyCode == BACKSPACE) {      
      int nl = typedText.length() - 2;
      typedText = typedText.substring(0, nl);
    }
  }
}

void mouseReleased() {

  mousePos.x = mouseX - (offsetX * zoom);
  mousePos.y = mouseY - (offsetY * zoom); 


  if (MODE == LINK && selectedNode !=null) {
    Particle rn = getNodeclicked();   
    if (rn != null) {
      Spring s = physics.makeSpring( selectedNode, rn, .05, 0.4, 500 );
      s.turnOff();
    }
  }
  selectedNode = null; 

  if (MODE == CREATE) selectedNode = null;
  if (MODE == MOVENODE) draggedNode = null;
}


void mousePressed() {
  Particle pn = getNodeclicked(); 

  if (MODE == NAV) {
    transPos.x = mouseX;
    transPos.y = mouseY;
    zoomPos.x = mouseX;
    zoomPos.y = mouseY;
  }

  if (MODE == LINK && pn !=null) {
    selectedNode = pn;
  }
  if (MODE == CREATE && pn !=null) {
    selectedNode = pn;
  }


  if ( (MODE == COL) && (toCol == null) && (pn != null) && (!cp.isVisible())) {
    toCol = pn;
    cp.showColorMap();
  }

  else if ((cp.isVisible()) && (toCol !=null)) {       
    color tmp = cp.returnSelectedCol();    
    toCol.setCol(tmp); 
    toCol = null;
  }
  else if (cp.isVisible && toCol == null) {
    cp.setVisible(false);
  }

  if (MODE == DEL) {
    for (int i = 0 ; i < physics.numberOfSprings() ; i++) {
      Spring link = physics.getSpring( i );
      if (link.getOneEnd() == pn || link.getTheOtherEnd() == pn)       
        physics.removeSpring(link);
    }
    physics.removeParticle(pn);
  }
}

int calcRestingLength(Particle cp) {
  //   find number of connections particle has 
  int spacing = 150;
  int springCons = 0;
  for (int sprgCnt = 0 ; sprgCnt < physics.numberOfSprings() ; sprgCnt++) {
    Spring link = physics.getSpring( sprgCnt );
    if (link.getOneEnd() == cp || link.getTheOtherEnd() == cp)       
      springCons++;
  }

  return spacing + ( (int)(springCons / 10) * 120 );
}
void mouseClicked()
{

  updateButtons();
  MODE = getMode();

  Particle p = getNodeclicked();  
    
  if (MODE == CREATE && p !=null) {

    Particle np = physics.makeParticle( 1.0, mousePos.x, mousePos.y, 0);
    np.setRad(40);
    for ( int i = 0; i < physics.numberOfParticles(); ++i )
    {
      physics.makeAttraction( np, physics.getParticle(i), -150, 50 );
    }
    int restingLength = calcRestingLength(p);
    Spring s = physics.makeSpring( p, np, 0.15, 0.15, restingLength );
  }

  if (MODE == RESET) {
    offsetX = 0;
    offsetY = 0;
    zoom = 1.0;
    setMode(NAV, RESET);
  }

  if (MODE == ZOOMIN) {        
    zoom += 0.05;
    setMode(NAV, ZOOMIN);
  }
  if (MODE == ZOOMOUT) {        
    if (zoom >= 0.1) zoom -= 0.05;
    setMode(NAV, ZOOMOUT);
  }            

  if (MODE == NAME && p !=null) {
    
    var name=prompt("Enter Node Name", "");
    if (name!=null) {
      p.setNodeLabel(""+name);
    }
    namingNode = p;
    naming = false;
    txtMX = (int)mousePos.x;
    txtMY = (int)mousePos.y;
  }  

  if (MODE == SAVE) {       
    loadSaveObject.saveMap(physics, mapFileName);
    setMode(NAV, SAVE);
    alert("Map Saved");
  }
}

void mouseDragged() {

  if (MODE == NAV && mouseButton == LEFT) {

    PVector nmp = new PVector(mouseX, mouseY, 0);
    PVector omp = new PVector(pmouseX, pmouseY, 0);    
    if (transPos.dist(nmp) < transPos.dist(omp)) transPos = nmp;



    float oldOffSetX = offsetX;
    float oldOffSetY = offsetY;

    offsetX = oldOffSetX - ((transPos.x - mouseX) / 10 );
    offsetY = oldOffSetY - ((transPos.y - mouseY) / 10 );
  }     

  if (MODE == MOVENODE) {

    if (draggedNode == null) draggedNode = getNodeclicked();    
    PVector mdv = new PVector();
    mdv.x = (mouseX / zoom)  - offsetX;
    mdv.y = (mouseY / zoom) - offsetY; 
    draggedNode.setNodePos(mdv);
  }
}

void mouseMoved() {
  mousePos.x = mouseX - (offsetX * zoom);
  mousePos.y = mouseY - (offsetY * zoom);
}




Particle getNodeclicked() {

  for ( int i = 0; i < physics.numberOfParticles(); ++i )
  {

    Particle v = physics.getParticle( i );
    if (v.contains(mousePos, zoom)) return v;
  }

  return null;
}  






class button
{
  int x,y,w,h,mode;
  boolean over,selected;
  String label;
  color recCol,txtCol; 
  PVector mPos;
  float zoom;
  
  
  button(int bx,int by,int bw,int bh,String bl,int ids){
   x = bx;
   y = by;
   w = bw;
   h = bh;
   label = bl;
   mPos = new PVector(0,0,0);
   zoom = 1;
   mode = ids;
   
  }
  
 
  
  
  
  void setup(){
   
    
  }
  
  int getBMode(){
   return mode; 
  }
  
  boolean getSelected(){
   return selected; 
  }
  
  void setSelected(boolean s){
  selected = s;
  }
  
  boolean overButton(){

if (mouseX >= (x) && mouseX <= ((x+w)) && mouseY >= (y) && mouseY <= ((y+h)))
       return true;
    else 
       return false;
    
  }
  
  void display(){
   
    textFont(createFont("Mono",14));
  
    if(this.overButton() || selected){
      recCol = 255;
      txtCol = 50;           
     }
     else {
      recCol = 50;
      txtCol = 255;
     }
     fill(recCol);
      rect(x, y, w, h);
      fill(txtCol);
      text(label,x+(w/2), y + (h / 2));
      noFill();
     
    stroke(255);
    
    
    noFill();
    
  }
  boolean buttonPressed(PVector msPos, float zm){
       zoom = zm;    
       mPos = msPos;
       
    if(this.overButton()) {
     selected = true; 
      return true;
    }
    return false;
//    else selected=false;
  }
  
    
  }
// The next line is needed if running in JavaScript Mode with Processing.js
/* @pjs preload="colormap.gif"; */ 

class colourPicker{

  PImage bg;
  int mx, my,w = 234,h=199;
  boolean show = false;
  color selected = new color(51);
  
   void setup(){
    
      bg = loadImage("colormap.gif");
  }
  colourPicker(){
   my = 50;
   mx=50; 
  }
  
  boolean isVisible(){
   return show; 
  }
  
  void setVisible(boolean viz){
   show = viz; 
  }
  
  void showColorMap(){
     if( (mouseX + w) < width) { 
     mx = mouseX;
     
     }
     else{
      mx = width - w;      
     }
     
     if((mouseY + h) < height){
       my = mouseY;
     }
     else{
      my = height - h; 
     }
     
     show = true; 
  }
  
  
 color returnSelectedCol(){
   
  
   if(show && (mouseX >= mx) && (mouseX <= (mx + w)) && (mouseY > my) && (mouseY <= (mouseY+h))) {
  
  selected = bg.get(mouseX-mx,mouseY-my);
  show = false;
   }
  
   return selected;
 }
  
void draw(){
  //fill(150);
  if(show){ 
//    background(10);
    fill(selected);
    rect(mx, my, w, h);
//   background(selected);
   image(bg,mx,my);

  }
}

}
public class loadSave {

  loadSave() {
  }

  public void saveMap(ParticleSystem ps, String fileName) {

    String msg = "";


    for ( int spc = 0; spc < ps.numberOfParticles(); spc++ )
    {

      Particle spp = ps.getParticle(spc);

      msg +=spc+","+spp.getNodeLabel()+","+(int)spp.position.x+","+(int)spp.position.y+","+spp.getRad()+","+spp.getCol().toString()+"::";
    }
    msg += "||";
    for ( int j = 0; j < ps.numberOfSprings(); j++ ) {
      Spring link = ps.getSpring( j );
      msg += ""+ps.getParticleIndex(link.getOneEnd())+","+ps.getParticleIndex(link.getTheOtherEnd())+","+(int)link.restLength()+"::";
    }

   
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.open("POST", "saveData.php?map="+fileName, false);
    xmlhttp.send(msg);

  }



  public ParticleSystem loadMapXML(String fn) {
  
      ParticleSystem loadPS = new ParticleSystem( 0, 0.05 );
      var xmlhttp = new XMLHttpRequest();
      xmlhttp.open("GET", "loadMap.php?map="+fn, false);
      xmlhttp.send();
      XMLElement xml= new XMLElement(xmlhttp.responseText);
      XMLElement loadGraph = xml.getChild("graph");
      XMLElement[] nodesXML = loadGraph.getChildren("node");
      XMLElement[] linksXML = loadGraph.getChildren("edge");


      Particle[] lps = new Particles[nodesXML.length];

      String[] lbls = new String[nodesXML.length];


      for (int i = 0 ; i < nodesXML.length ; i++) {

        int nn = nodesXML[i].getInt("id");
        String loadLabel = nodesXML[i].getString("label");
        int xposs =  (int)nodesXML[i].getInt("xpos");
        int yposs =  (int)nodesXML[i].getInt("ypos");
        int psize = (int)nodesXML[i].getInt("size");
        int col = (int)nodesXML[i].getInt("col");

        lps[i] = loadPS.makeParticle( 1.0, xposs, yposs, 0);

        lps[i].nodeLabel = loadLabel; 
        lps[i].setRad(psize);
        lps[i].setColCode(col);
        for ( int pcnt = 0; pcnt < loadPS.numberOfParticles(); ++pcnt )
        {         
          loadPS.makeAttraction( lps[i], loadPS.getParticle(pcnt), -150, 50 );
        }
      }


      for (int j = 0 ; j < linksXML.length ; j++) {     
        int source = (int)linksXML[j].getInt("source");
        int target = (int)linksXML[j].getInt("target");
        int restLength = (int)linksXML[j].getInt("restlength");
     
        Particle src = loadPS.getParticle(source);
        Particle tgt = loadPS.getParticle(target); 
   
        if (src != null && tgt !=null) {
          Spring news = loadPS.makeSpring( src, tgt, 0.15, 0.15, restLength );
          if (restLength == 500) news.turnOff();
        }
      }

      return loadPS;
    }
    
  


  public ParticleSystem testMap() {

    ParticleSystem loadPS = new ParticleSystem( 0, 0.05 );

    Particle np = loadPS.makeParticle( 1.0, 300, 200, 0);
    np.setNodeLabel("ME"); 
    np.setRad(75);

    Particle np = loadPS.makeParticle( 1.0, 150, 300, 0);
    np.setRad(50);
    np.setNodeLabel("A");

    Particle np = loadPS.makeParticle( 1.0, 400, 150, 0);
    np.setRad(50);
    np.setNodeLabel("B");
    ////      
    Particle src = loadPS.getParticle(0);
    Particle tgt = loadPS.getParticle(1); 
    
    Spring s = loadPS.makeSpring( src, tgt, 0.5, 0.4, 200 );

    Particle src = loadPS.getParticle(0);
    Particle tgt = loadPS.getParticle(2); 

    Spring s = loadPS.makeSpring( src, tgt, 0.5, 0.4, 200 );

    return loadPS;
  }
}

// Traer Physics 3.0
// Terms from Traer's download page, http://traer.cc/mainsite/physics/
//   LICENSE - Use this code for whatever you want, just send me a link jeff@traer.cc
//
// traer3a.pde 
//   From traer.physics - author: Jeff Traer
//     Attraction              Particle                     
//     EulerIntegrator         ParticleSystem  
//     Force                   RungeKuttaIntegrator         
//     Integrator              Spring
//     ModifiedEulerIntegrator Vector3D          
//
//   From traer.animator - author: Jeff Traer   
//     Smoother                                       
//     Smoother3D                  
//     Tickable     
//
//   New - author: Carl Pearson
//     UniversalAttraction
//     Pulse
//

// 13 Dec 2010: Copied 3.0 src from http://traer.cc/mainsite/physics/ and ported to Processingjs,
//              added makeParticle2(), makeAttraction2(), replaceAttraction(), and removeParticle(int) -mrn (Mike Niemi)
//  9 Feb 2011: Fixed bug in Euler integrators where they divided by time instead of 
//              multiplying by it in the update steps,
//              eliminated the Vector3D class (converting the code to use the native PVector class),
//              did some code compaction in the RK solver,
//              added a couple convenience classes, UniversalAttraction and Pulse, simplifying 
//              the Pendulums sample (renamed to dynamics.pde) considerably. -cap (Carl Pearson)

//===========================================================================================
//                                      Attraction
//===========================================================================================
// attract positive repel negative
//package traer.physics;
public class Attraction implements Force
{
  Particle one;
  Particle b;
  float k;
  boolean on = true;
  float distanceMin;
  float distanceMinSquared;
  
  public Attraction( Particle a, Particle b, float k, float distanceMin )
  {
    this.one = a;
    this.b = b;
    this.k = k;
    this.distanceMin = distanceMin;
    this.distanceMinSquared = distanceMin*distanceMin;
  }

  protected void        setA( Particle p )            { one = p; }
  protected void        setB( Particle p )            { b = p; }
  public final float    getMinimumDistance()          { return distanceMin; }
  public final void     setMinimumDistance( float d ) { distanceMin = d; distanceMinSquared = d*d; }
  public final void     turnOff()                     { on = false; }
  public final void     turnOn()                { on = true;  }
  public final void     setStrength( float k )        { this.k = k; }
  public final Particle getOneEnd()                   { return one; }
  public final Particle getTheOtherEnd()              { return b; }
  
  public void apply() 
  { if ( on && ( one.isFree() || b.isFree() ) )
      {
        PVector a2b = PVector.sub(one.position, b.position, new PVector());
        float a2bDistanceSquared = a2b.dot(a2b);

  if ( a2bDistanceSquared < distanceMinSquared )
     a2bDistanceSquared = distanceMinSquared;

  float force = k * one.mass0 * b.mass0 / (a2bDistanceSquared * (float)Math.sqrt(a2bDistanceSquared));

        a2b.mult( force );

  // apply
        if ( b.isFree() )
     b.force.add( a2b );  
        if ( one.isFree() ) {
           a2b.mult(-1f);
     one.force.add( a2b );
        }
      }
  }

  public final float   getStrength() { return k; }
  public final boolean isOn()        { return on; }
  public final boolean isOff()       { return !on; }
} // Attraction

//===========================================================================================
//                                    UniversalAttraction
//===========================================================================================
// attract positive repel negative
public class UniversalAttraction implements Force {
  public UniversalAttraction( float k, float distanceMin, ArrayList targetList )
  {
    this.k = k;
    this.distanceMin = distanceMin;
    this.distanceMinSquared = distanceMin*distanceMin;
    this.targetList = targetList;
  }
  
  float k;
  boolean on = true;
  float distanceMin;
  float distanceMinSquared;
  ArrayList targetList;
  public final float    getMinimumDistance()          { return distanceMin; }
  public final void     setMinimumDistance( float d ) { distanceMin = d; distanceMinSquared = d*d; }
  public final void     turnOff()                     { on = false; }
  public final void     turnOn()                { on = true;  }
  public final void     setStrength( float k )        { this.k = k; }
  public final float   getStrength() { return k; }
  public final boolean isOn()        { return on; }
  public final boolean isOff()       { return !on; }

  
  public void apply() 
  { 
    if ( on ) {
        for (int i=0; i < targetList.size(); i++ ) {
          for (int j=i+1; j < targetList.size(); j++) {
            Particle a = (Particle)targetList.get(i);
            Particle b = (Particle)targetList.get(j);
            if ( a.isFree() || b.isFree() ) {
              PVector a2b = PVector.sub(a.position, b.position, new PVector());
              float a2bDistanceSquared = a2b.dot(a2b);
              if ( a2bDistanceSquared < distanceMinSquared )
              a2bDistanceSquared = distanceMinSquared;
              float force = k * a.mass0 * b.mass0 / (a2bDistanceSquared * (float)Math.sqrt(a2bDistanceSquared));
              a2b.mult( force );

              if ( b.isFree() ) b.force.add( a2b );  
              if ( a.isFree() ) {
                 a2b.mult(-1f);
                 a.force.add( a2b );
              }
            }
          }
        }
    }
  }
} //UniversalAttraction

//===========================================================================================
//                                    Pulse
//===========================================================================================
public class Pulse implements Force {
  public Pulse( float k, float distanceMin, PVector origin, float lifetime, ArrayList targetList )
  {
    this.k = k;
    this.distanceMin = distanceMin;
    this.distanceMinSquared = distanceMin*distanceMin;
    this.origin = origin;
    this.targetList = targetList;
    this.lifetime = lifetime;
  }
  
  float k;
  boolean on = true;
  float distanceMin;
  float distanceMinSquared;
  float lifetime;
  PVector origin;
  ArrayList targetList;
  
  public final void     turnOff() { on = false; }
  public final void     turnOn()  { on = true;  }
  public final boolean  isOn()    { return on; }
  public final boolean  isOff()   { return !on; }
  public final boolean  tick( float time ) { 
    lifetime-=time; 
    if (lifetime <= 0f) turnOff(); 
    return on;
  }
  
  public void apply() {
    if (on) {
      PVector holder = new PVector();
      int count = 0;
      for (Iterator i = targetList.iterator(); i.hasNext(); ) {
        Particle p = (Particle)i.next();
        if ( p.isFree() ) {
          holder.set( p.position.x, p.position.y, p.position.z );
          holder.sub( origin );
          float distanceSquared = holder.dot(holder);
          if (distanceSquared < distanceMinSquared) distanceSquared = distanceMinSquared;
          holder.mult(k / (distanceSquared * (float)Math.sqrt(distanceSquared)) );
          p.force.add( holder );
        }
      }
    }
  }
}//Pulse

//===========================================================================================
//                                      EulerIntegrator
//===========================================================================================
//package traer.physics;
public class EulerIntegrator implements Integrator
{
  ParticleSystem s;
  
  public EulerIntegrator( ParticleSystem s ) { this.s = s; }
  public void step( float t )
  {
    s.clearForces();
    s.applyForces();
    
    for ( Iterator i = s.particles.iterator(); i.hasNext(); )
      {
  Particle p = (Particle)i.next();
  if ( p.isFree() )
          {
      p.velocity.add( PVector.mult(p.force, t/p.mass0) );
      p.position.add( PVector.mult(p.velocity, t) );
    }
      }
  }
} // EulerIntegrator

//===========================================================================================
//                                          Force
//===========================================================================================
// May 29, 2005
//package traer.physics;
// @author jeffrey traer bernstein
public interface Force
{
  public void    turnOn();
  public void    turnOff();
  public boolean isOn();
  public boolean isOff();
  public void    apply();
} // Force

//===========================================================================================
//                                      Integrator
//===========================================================================================
//package traer.physics;
public interface Integrator 
{
  public void step( float t );
} // Integrator

//===========================================================================================
//                                    ModifiedEulerIntegrator
//===========================================================================================
//package traer.physics;
public class ModifiedEulerIntegrator implements Integrator
{
  ParticleSystem s;
  public ModifiedEulerIntegrator( ParticleSystem s ) { this.s = s; }
  public void step( float t )
  {
    s.clearForces();
    s.applyForces();
    
    float halft = 0.5f*t;
    PVector a = new PVector();
    PVector holder = new PVector();
    for ( int i = 0; i < s.numberOfParticles(); i++ )
      {
  Particle p = s.getParticle( i );
  if ( p.isFree() )
    {
            PVector.div(p.force, p.mass0, a);  
      p.position.add( PVector.mult(p.velocity, t, holder) );
            p.velocity.add( PVector.mult(a, t, a) );
      p.position.add( PVector.mult(a, halft, a) );
    }
      }
  }
} // ModifiedEulerIntegrator

//===========================================================================================
//                                         Particle
//===========================================================================================
//package traer.physics;
public class Particle
{
  PVector position = new PVector();
  PVector velocity = new PVector();
  PVector force = new PVector();
  protected float    mass0;
  protected float    age0 = 0;
  protected float    rad = 0;
  protected boolean  dead0 = false;
  boolean            fixed0 = false;
  String nodeLabel ="";
  color drawCol = color(50); 
  
  public Particle( float m )
  { mass0 = m; 
  }
  
  public void setNodeLabel(String snl){
    
   nodeLabel = trim(snl); 
  }
  
  public void setRad(float r){
    rad = r;
  }
  
  public void setCol(color setC){
   drawCol = setC; 
  }
  public void setColCode(int colCode){
   drawCol = color(colCode); 
  }
  
  public color getCol(){
   return drawCol; 
  }
  
  public float getRad(){
   return rad; 
  }
  
  public String getNodeLabel(){
   return nodeLabel; 
  }
  
  public void setNodePos(PVector mp){
   this.position = mp; 
  }
  
 public boolean contains( PVector tmp, float zm) {
  
  PVector npos = new PVector( (this.position.x * zm), (this.position.y * zm), 0); 
  if((npos.dist(tmp)) < ((rad) * zm))  return true;
  else return false;
 
}
  
  // @see traer.physics.AbstractParticle#distanceTo(traer.physics.Particle)
  public final float distanceTo( Particle p ) { return this.position.dist( p.position ); }
  
  // @see traer.physics.AbstractParticle#makeFixed()
  public final Particle makeFixed() {
    fixed0 = true;
    velocity.set(0f,0f,0f);
    force.set(0f, 0f, 0f);
    return this;
  }
  
  // @see traer.physics.AbstractParticle#makeFree()
  public final Particle makeFree() {
    fixed0 = false;
    return this;
  }

  // @see traer.physics.AbstractParticle#isFixed()
  public final boolean isFixed() { return fixed0; }
  
  // @see traer.physics.AbstractParticle#isFree()
  public final boolean isFree() { return !fixed0; }
    
  // @see traer.physics.AbstractParticle#mass()
  public final float mass() { return mass0; }
  
  // @see traer.physics.AbstractParticle#setMass(float)
  public final void setMass( float m ) { mass0 = m; }
    
  // @see traer.physics.AbstractParticle#age()
  public final float age() { return age0; }
  
  protected void reset()
  {
    age0 = 0;
    dead0 = false;
    position.set(0f,0f,0f);
    velocity.set(0f,0f,0f);
    force.set(0f,0f,0f);
    mass0 = 1f;
  }
} // Particle

//===========================================================================================
//                                      ParticleSystem
//===========================================================================================
// May 29, 2005
//package traer.physics;
//import java.util.*;
public class ParticleSystem
{
  public static final int RUNGE_KUTTA = 0;
  public static final int MODIFIED_EULER = 1;
  protected static final float DEFAULT_GRAVITY = 0;
  protected static final float DEFAULT_DRAG = 0.001f;  
  ArrayList  particles = new ArrayList();
  ArrayList  springs = new ArrayList();
  ArrayList  attractions = new ArrayList();
  ArrayList  customForces = new ArrayList();
  ArrayList  pulses = new ArrayList();
  Integrator integrator;
  PVector    gravity = new PVector();
  float      drag;
  boolean    hasDeadParticles = false;
  
  public final void setIntegrator( int which )
  {
    switch ( which )
    {
      case RUNGE_KUTTA:
  this.integrator = new RungeKuttaIntegrator( this );
  break;
      case MODIFIED_EULER:
  this.integrator = new ModifiedEulerIntegrator( this );
  break;
    }
  }
  
  public final void setGravity( float x, float y, float z ) { gravity.set( x, y, z ); }

  // default down gravity
  public final void     setGravity( float g ) { gravity.set( 0, g, 0 ); }
  public final void     setDrag( float d )    { drag = d; }
  public final void     tick()                { tick( 1 ); }
  public final void     tick( float t )       {
    integrator.step( t );
    for (int i = 0; i<pulses.size(); ) {
      Pulse p = (Pulse)pulses.get(i);
      p.tick(t);
      if (p.isOn()) { i++; } else { pulses.remove(i); }
    }
    if (pulses.size()!=0) for (Iterator i = pulses.iterator(); i.hasNext(); ) {
      Pulse p = (Pulse)(i.next());
      p.tick( t );
      if (!p.isOn()) i.remove();
    }
  }
  
  public final Particle makeParticle( float mass, float x, float y, float z )
  {
    Particle p = new Particle( mass );
    p.position.set( x, y, z );
    particles.add( p );
    return p;
  }
  
  public final int makeParticle2( float mass, float x, float y, float z )
  { // mrn
    makeParticle(mass, x, y, z);
    return particles.size()-1;
  }
  
  public final Particle makeParticle() { return makeParticle( 1.0f, 0f, 0f, 0f ); }
  
  public final Spring   makeSpring( Particle a, Particle b, float ks, float d, float r )
  {
    Spring s = new Spring( a, b, ks, d, r );
    springs.add( s );
    return s;
  }
  
  public final Attraction makeAttraction( Particle first, Particle b, float k, float minDistance )
  {
    Attraction m = new Attraction( first, b, k, minDistance );
    attractions.add( m );
    return m;
  }
  
  public final int makeAttraction2( Particle a, Particle b, float k, float minDistance )
  { // mrn
    makeAttraction(a, b, k, minDistance);
    return attractions.size()-1; // return the index 
  }

  public final void replaceAttraction( int i, Attraction m )
  { // mrn
    attractions.set( i, m );
  }  

  public final void addPulse(Pulse pu){ pulses.add(pu); }

  public final void clear()
  {
    particles.clear();
    springs.clear();
    attractions.clear();
    customForces.clear();
    pulses.clear();
  }
  
  public ParticleSystem( float g, float somedrag )
  {
    setGravity( 0f, g, 0f );
    drag = somedrag;
    integrator = new RungeKuttaIntegrator( this );
  }
  
  public ParticleSystem( float gx, float gy, float gz, float somedrag )
  {
    setGravity( gx, gy, gz );
    drag = somedrag;
    integrator = new RungeKuttaIntegrator( this );
  }
  
  public ParticleSystem()
  {
    setGravity( 0f, ParticleSystem.DEFAULT_GRAVITY, 0f );
    drag = ParticleSystem.DEFAULT_DRAG;
    integrator = new RungeKuttaIntegrator( this );
  }
  
  protected final void applyForces()
  {
    if ( gravity.mag() != 0f )
      {
        for ( Iterator i = particles.iterator(); i.hasNext(); )
    {
            Particle p = (Particle)i.next();
            if (p.isFree()) p.force.add( gravity );
    }
      }
      
    PVector target = new PVector();
    for ( Iterator i = particles.iterator(); i.hasNext(); )
      {
        Particle p = (Particle)i.next();
        if (p.isFree()) p.force.add( PVector.mult(p.velocity, -drag, target) );

      }
      
    applyAll(springs);
    applyAll(attractions);
    applyAll(customForces);
    applyAll(pulses);
      
    
  }
  
  private void applyAll(ArrayList forces) {
    if( forces.size()!=0 ) for ( Iterator i = forces.iterator(); i.hasNext(); ) ((Force)i.next()).apply();
  }
  
  protected final void clearForces()
  {
    for (Iterator i = particles.iterator(); i.hasNext(); ) ((Particle)i.next()).force.set(0f, 0f, 0f);
  }
  
  public final int        numberOfParticles()              { return particles.size(); }
  public final int        numberOfSprings()                { return springs.size(); }
  public final int        numberOfAttractions()            { return attractions.size(); }
  public final Particle   getParticle( int i )             { return (Particle)particles.get( i ); }
  
  public final int        getParticleIndex( Particle P ){
   for(int i = 0 ; i < particles.size() ; i++){
    if( (Particle)particles.get( i ) == P ) return i;  
   }
     return -1;
  }
  
  public final Spring     getSpring( int i )               { return (Spring)springs.get( i ); }
  public final Attraction getAttraction( int i )           { return (Attraction)attractions.get( i ); }
  public final void       addCustomForce( Force f )        { customForces.add( f ); }
  public final int        numberOfCustomForces()           { return customForces.size(); }
  public final Force      getCustomForce( int i )          { return (Force)customForces.get( i ); }
  public final Force      removeCustomForce( int i )       { return (Force)customForces.remove( i ); }
  public final void       removeParticle( int i )          { particles.remove( i ); } //mrn
  public final void       removeParticle( Particle p )     { particles.remove( p ); }
  public final Spring     removeSpring( int i )            { return (Spring)springs.remove( i ); }
  public final Attraction removeAttraction( int i )        { return (Attraction)attractions.remove( i ); }
  public final void       removeAttraction( Attraction s ) { attractions.remove( s ); }
  public final void       removeSpring( Spring a )         { springs.remove( a ); }
  public final void       removeCustomForce( Force f )     { customForces.remove( f ); }
} // ParticleSystem

//===========================================================================================
//                                      RungeKuttaIntegrator
//===========================================================================================
//package traer.physics;
//import java.util.*;
public class RungeKuttaIntegrator implements Integrator
{  
  ArrayList originalPositions = new ArrayList();
  ArrayList originalVelocities = new ArrayList();
  ArrayList k1Forces = new ArrayList();
  ArrayList k1Velocities = new ArrayList();
  ArrayList k2Forces = new ArrayList();
  ArrayList k2Velocities = new ArrayList();
  ArrayList k3Forces = new ArrayList();
  ArrayList k3Velocities = new ArrayList();
  ArrayList k4Forces = new ArrayList();
  ArrayList k4Velocities = new ArrayList();
  ParticleSystem s;

  public RungeKuttaIntegrator( ParticleSystem s ) { this.s = s;  }
  
  final void allocateParticles()
  {
    while( s.particles.size() > originalPositions.size() ) {
        originalPositions.add( new PVector() );
    originalVelocities.add( new PVector() );
    k1Forces.add( new PVector() );
    k1Velocities.add( new PVector() );
    k2Forces.add( new PVector() );
    k2Velocities.add( new PVector() );
    k3Forces.add( new PVector() );
    k3Velocities.add( new PVector() );
    k4Forces.add( new PVector() );
    k4Velocities.add( new PVector() );
    }
  }
  
  private final void setIntermediate(ArrayList forces, ArrayList velocities) {
    s.applyForces();
    for ( int i = 0; i < s.particles.size(); ++i )
      {
  Particle p = (Particle)s.particles.get( i );
  if ( p.isFree() )
    {
      ((PVector)forces.get( i )).set( p.force.x, p.force.y, p.force.z );
      ((PVector)velocities.get( i )).set( p.velocity.x, p.velocity.y, p.velocity.z );
            p.force.set(0f,0f,0f);
    }
      }
  }
  
  private final void updateIntermediate(ArrayList forces, ArrayList velocities, float multiplier) {
    PVector holder = new PVector();
    
    for ( int i = 0; i < s.particles.size(); ++i )
      {
  Particle p = (Particle)s.particles.get( i );
  if ( p.isFree() )
    {
        PVector op = (PVector)(originalPositions.get( i ));
            p.position.set(op.x, op.y, op.z);
            p.position.add(PVector.mult((PVector)(velocities.get( i )), multiplier, holder));    
      PVector ov = (PVector)(originalVelocities.get( i ));
            p.velocity.set(ov.x, ov.y, ov.z);
            p.velocity.add(PVector.mult((PVector)(forces.get( i )), multiplier/p.mass0, holder));  
          }
       }
  }
  
  private final void initialize() {
    for ( int i = 0; i < s.particles.size(); ++i )
      {
  Particle p = (Particle)(s.particles.get( i ));
  if ( p.isFree() )
    {    
      ((PVector)(originalPositions.get( i ))).set( p.position.x, p.position.y, p.position.z );
      ((PVector)(originalVelocities.get( i ))).set( p.velocity.x, p.velocity.y, p.velocity.z );
    }
  p.force.set(0f,0f,0f);  // and clear the forces
      }
  }
  
  public final void step( float deltaT )
  {  
    allocateParticles();
    initialize();       
    setIntermediate(k1Forces, k1Velocities);
    updateIntermediate(k1Forces, k1Velocities, 0.5f*deltaT );
    setIntermediate(k2Forces, k2Velocities);
    updateIntermediate(k2Forces, k2Velocities, 0.5f*deltaT );
    setIntermediate(k3Forces, k3Velocities);
    updateIntermediate(k3Forces, k3Velocities, deltaT );
    setIntermediate(k4Forces, k4Velocities);
    
    /////////////////////////////////////////////////////////////
    // put them all together and what do you get?
    for ( int i = 0; i < s.particles.size(); ++i )
      {
  Particle p = (Particle)s.particles.get( i );
  p.age0 += deltaT;
  if ( p.isFree() )
    {
      // update position
      PVector holder = (PVector)(k2Velocities.get( i ));
            holder.add((PVector)k3Velocities.get( i ));
            holder.mult(2.0f);
            holder.add((PVector)k1Velocities.get( i ));
            holder.add((PVector)k4Velocities.get( i ));
            holder.mult(deltaT / 6.0f);
            holder.add((PVector)originalPositions.get( i ));
            p.position.set(holder.x, holder.y, holder.z);
                          
      // update velocity
      holder = (PVector)k2Forces.get( i );
      holder.add((PVector)k3Forces.get( i ));
            holder.mult(2.0f);
            holder.add((PVector)k1Forces.get( i ));
            holder.add((PVector)k4Forces.get( i ));
            holder.mult(deltaT / (6.0f * p.mass0 ));
            holder.add((PVector)originalVelocities.get( i ));
      p.velocity.set(holder.x, holder.y, holder.z);
    }
      }
  }
} // RungeKuttaIntegrator

//===========================================================================================
//                                         Spring
//===========================================================================================
// May 29, 2005
//package traer.physics;
// @author jeffrey traer bernstein
public class Spring implements Force
{
  float springConstant0;
  float damping0;
  float restLength0;
  Particle one, b;
  boolean on = true;
    
  public Spring( Particle A, Particle B, float ks, float d, float r )
  {
    springConstant0 = ks;
    damping0 = d;
    restLength0 = r;
    one = A;
    b = B;
  }
  
  public final void     turnOff()                { on = false; }
  public final void     turnOn()                 { on = true; }
  public final boolean  isOn()                   { return on; }
  public final boolean  isOff()                  { return !on; }
  public final Particle getOneEnd()              { return one; }
  public final Particle getTheOtherEnd()         { return b; }
  public final float    currentLength()          { return one.distanceTo( b ); }
  public final float    restLength()             { return restLength0; }
  public final float    strength()               { return springConstant0; }
  public final void     setStrength( float ks )  { springConstant0 = ks; }
  public final float    damping()                { return damping0; }
  public final void     setDamping( float d )    { damping0 = d; }
  public final void     setRestLength( float l ) { restLength0 = l; }
  
  public final void apply()
  {  
    if ( on && ( one.isFree() || b.isFree() ) )
      {
        PVector a2b = PVector.sub(one.position, b.position, new PVector());

        float a2bDistance = a2b.mag();  
  
  if (a2bDistance!=0f) {
          a2b.div(a2bDistance);
        }

  // spring force is proportional to how much it stretched 
  float springForce = -( a2bDistance - restLength0 ) * springConstant0; 
  
        PVector vDamping = PVector.sub(one.velocity, b.velocity, new PVector());
        
        float dampingForce = -damping0 * a2b.dot(vDamping);
                           
  // forceB is same as forceA in opposite direction
  float r = springForce + dampingForce;
    
  a2b.mult(r);
      
  if ( one.isFree() )
     one.force.add( a2b );
  if ( b.isFree() )
     b.force.add( PVector.mult(a2b, -1, a2b) );
      }
  }
  protected void setA( Particle p ) { one = p; }
  protected void setB( Particle p ) { b = p; }
} // Spring

//===========================================================================================
//                                       Smoother
//===========================================================================================
//package traer.animator;
public class Smoother implements Tickable
{
  public Smoother(float smoothness)                     { setSmoothness(smoothness);  setValue(0.0F); }
  public Smoother(float smoothness, float start)        { setSmoothness(smoothness); setValue(start); }
  public final void     setSmoothness(float smoothness) { a = -smoothness; gain = 1.0F + a; }
  public final void     setTarget(float target)         { input = target; }
  public void           setValue(float x)               { input = x; lastOutput = x; }
  public final float    getTarget()                     { return input; }
  public final void     tick()                          { lastOutput = gain * input - a * lastOutput; }
  public final float    getValue()                      { return lastOutput; }
  public float a, gain, lastOutput, input;
} // Smoother

//===========================================================================================
//                                      Smoother3D
//===========================================================================================
//package traer.animator;
public class Smoother3D implements Tickable
{
  public Smoother3D(float smoothness)
  {
    x0 = new Smoother(smoothness);
    y0 = new Smoother(smoothness);
    z0 = new Smoother(smoothness);
  }
  public Smoother3D(float initialX, float initialY, float initialZ, float smoothness)
  {
    x0 = new Smoother(smoothness, initialX);
    y0 = new Smoother(smoothness, initialY);
    z0 = new Smoother(smoothness, initialZ);
  }
  public final void setXTarget(float X) { x0.setTarget(X); }
  public final void setYTarget(float X) { y0.setTarget(X); }
  public final void setZTarget(float X) { z0.setTarget(X); }
  public final float getXTarget()       { return x0.getTarget(); }
  public final float getYTarget()       { return y0.getTarget(); }
  public final float getZTarget()       { return z0.getTarget(); }
  public final void setTarget(float X, float Y, float Z)
  {
    x0.setTarget(X);
    y0.setTarget(Y);
    z0.setTarget(Z);
  }
  public final void setValue(float X, float Y, float Z)
  {
    x0.setValue(X);
    y0.setValue(Y);
    z0.setValue(Z);
  }
  public final void setX(float X)  { x0.setValue(X); }
  public final void setY(float Y)  { y0.setValue(Y); }
  public final void setZ(float Z)  { z0.setValue(Z); }
  public final void setSmoothness(float smoothness)
  {
    x0.setSmoothness(smoothness);
    y0.setSmoothness(smoothness);
    z0.setSmoothness(smoothness);
  }
  public final void tick()         { x0.tick(); y0.tick(); z0.tick(); }
  public final float x()           { return x0.getValue(); }
  public final float y()           { return y0.getValue(); }
  public final float z()           { return z0.getValue(); }
  public Smoother x0, y0, z0;
} // Smoother3D

//===========================================================================================
//                                      Tickable
//===========================================================================================
//package traer.animator;
public interface Tickable
{
  public abstract void tick();
  public abstract void setSmoothness(float f);
} // Tickable

