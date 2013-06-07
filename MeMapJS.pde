
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






