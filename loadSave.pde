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

