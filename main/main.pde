/* --------------------------------------------------------------------------
 * SimpleOpenNI User Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;

SimpleOpenNI  context;
color[]       userClr = new color[]{ color(255,0,0),
                                     color(0,255,0),
                                     color(0,0,255),
                                     color(255,255,0),
                                     color(255,0,255),
                                     color(0,255,255)
                                   };
Mosaic ms = new Mosaic();
                                   
                                   
PVector com = new PVector();                                   
PVector com2d = new PVector();                                   

void setup()
{
  size(640,480);
  
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  // enable depthMap generation 
  context.enableDepth();
   
  // enable skeleton generation for all joints
  context.enableUser();
 
  // カラー画像を有効化
  context.enableRGB();
  context.alternativeViewPointDepthToImage();     

  background(200,0,0);
  // where is color
  stroke(0,0,255);
  strokeWeight(3);
  smooth();  
}

void draw()
{
  // update the cam
  context.update();
    image(context.rgbImage(), 0, 0);  // カラー画像の描画

  // draw depthImageMap
  //image(context.depthImage(),0,0);
  image(context.userImage(),0,0);
  image(context.rgbImage(), 0, 0);  // カラー画像の描画
 
  // TODO where is ditecting color of users depth?
  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for(int i=0;i<userList.length;i++)
  {
    if(context.isTrackingSkeleton(userList[i]))
    {  
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      getSkelton(userList[i]);
      // TMP位置取得
      float[] tmpPos = detectTMP(userList[i]);
      //モザイク表示
      ms.changeMosaicWithCenter(tmpPos[0], tmpPos[1], (int)tmpPos[2], (int)tmpPos[2]);
      drawSkeleton(userList[i]);
    }      
      
    // draw the center of mass
    if(context.getCoM(userList[i],com))
    {
      context.convertRealWorldToProjective(com,com2d);
      stroke(100,255,0);
      strokeWeight(1);
      beginShape(LINES);
        vertex(com2d.x,com2d.y - 5);
        vertex(com2d.x,com2d.y + 5);

        vertex(com2d.x - 5,com2d.y);
        vertex(com2d.x + 5,com2d.y);
      endShape();
      
      fill(0,255,100);
      text(Integer.toString(userList[i]),com2d.x,com2d.y);
    }
  }    
}

void getSkelton(int userId){
    // to get the 3d joint data
  PVector jointPos = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
  println(jointPos);
}

float[] detectTMP(int userId){
  // 右肩の3次元位置を取得する
  PVector right_sholder3d = new PVector(); // 3次元位置
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, right_sholder3d);
   // 右肩の2次元位置を取得する
  PVector right_sholder2d = new PVector(); // 2次元位置
  context.convertRealWorldToProjective(right_sholder3d, right_sholder2d);
  //println(right_sholder2d);
  //println(right_sholder2d.x);
  //println(right_sholder2d.y);
  // 右肩にとりあえず円を書く
  ellipse(right_sholder2d.x,right_sholder2d.y,30,30);
  
  // 左肩の3次元位置を取得する
  PVector left_sholder3d = new PVector(); // 3次元位置
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, left_sholder3d);
   // 左肩の2次元位置を取得する
  PVector left_sholder2d = new PVector(); // 2次元位置
  context.convertRealWorldToProjective(left_sholder3d, left_sholder2d);
  ellipse(left_sholder2d.x,left_sholder2d.y,30,30);
  
  // 中心の3次元位置を取得する
  PVector center3d = new PVector(); // 3次元位置
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_TORSO, center3d);
   // 中心の2次元位置を取得する
  PVector center2d = new PVector(); // 2次元位置
  context.convertRealWorldToProjective(center3d, center2d);
  // 中心にとりあえず円を書く
  ellipse(center2d.x,center2d.y,30,30);
  
  float diff_y_from_sholder_to_center = center2d.y - right_sholder2d.y;
  float tmp_center_y = 1.1 * (center2d.y + diff_y_from_sholder_to_center);
  //モザイクの大きさを定義する、差分diff_y_from_sholder_to_centerが大きければ大きいほど、カメラに近いのでモザイクは大きく、近い場合は離れているので小さくする
  int mos_size = (int)(0.45 * diff_y_from_sholder_to_center);
  
  //ellipse(center2d.x, tmp_center_y, 50,50);
  
  float[] ret = {center2d.x, tmp_center_y, mos_size};
  return ret;
}


// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  
  //一旦スケルトンの色を太くする
  strokeWeight(5);
  // スケルトンの画面表示するところ
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
  
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


void keyPressed()
{
  switch(key)
  {
  case ' ':
    context.setMirror(!context.mirror());
    break;
  }
}  

