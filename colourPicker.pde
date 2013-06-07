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
