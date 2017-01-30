 class Mosaic {
  int mosaicWidth = 20;
  int mosaicHeight = 20;

  void changeMosaic(int x, int y, int _width, int _height){
    loadPixels();
    for(int j = y; j < (y + _height); j += mosaicHeight) {  
      for(int i = x; i < (x +_width); i += mosaicWidth) {  
        // ordinary prosidure
         try {
          color c = pixels[j * (width) + i];
          fill(c);
          noStroke();
          rect(i, j, mosaicWidth, mosaicHeight);
         } catch (Exception e){
           // out of array bound
         }
      }
    } 
  }

  void changeMosaicWithCenter(float x,float y, int w_radius, int h_radius){
    int _x = (int)x - w_radius;
    int _y = (int)y - h_radius;
    int _width = 2 * w_radius;
    int _height = 2 * h_radius; 
    changeMosaic( _x,  _y,  _width,  _height);
  }

}
