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
