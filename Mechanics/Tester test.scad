include <params.scad>;

pcb = "pcb/24-clocks.stl";
pcbTicknes = 1.6;
clearancePcbTop=1;
clearancePcbBot=2;
clearancePcbEdge=0.5;
holderY=10;
holderX=20;

botHolderAbovePCB2=4; //with 45 degree angle
botHolderAbovePCB1=pcbTicknes+0.4; //including PCB
botHolderPCBtoR75=2.5+3;

r75HoleDia=1.32+0.2;
r75HoldLength=10;

alignPole1X=pcb_min_x-holderX/2;
alignPole1Y=pcb_min_y+(pcb_max_y-pcb_min_y)/2-holderX;
alignPole2X=pcb_max_x+holderX/2;
alignPole2Y=pcb_min_y+(pcb_max_y-pcb_min_y)/2+holderX;
alignPoleH=pcb_max_z+10;
alignPoleD=8;
alignPoleCl=0.4; //diff between pole and hole

centerPinD=3;
centerPinHole=centerPinD+0.2;
centerPinL=25;

$fn=60;

module pcbBorder(pcb,cl) {
    minkowski() {
        hull()projection(cut=true)import(pcb);
        circle(cl);
    }
}

module topkeepout(pcb) {
    minkowski() {
        projection(cut=false)intersection(){
            import(pcb);
            translate([pcb_min_x-5,pcb_min_y-5,pcbTicknes+0.1])cube([pcb_max_x-pcb_min_x+10,pcb_max_y-pcb_min_y+10,pcb_max_z-pcb_min_z+10]);
        }
        circle(clearancePcbTop);
    }
}

module botkeepout(pcb,z) {
    minkowski() {
        projection(cut=false)intersection(){
            import(pcb);
            translate([pcb_min_x-5,pcb_min_y-5,z-(pcb_max_z-pcb_min_z+10)])cube([pcb_max_x-pcb_min_x+10,pcb_max_y-pcb_min_y+10,pcb_max_z-pcb_min_z+10]);
        }
        circle(clearancePcbBot);
    }
}

module topPusher(z) {
    clPcbTop=5;
    topTick=20;
    difference() {
        // greate main block
        translate([pcb_min_x-holderX,pcb_min_y-holderY,pcbTicknes])cube([pcb_max_x-pcb_min_x+holderX*2,pcb_max_y-pcb_min_y+holderY*2,pcb_max_z+clPcbTop+topTick]);
        // substract PCB keepout
        linear_extrude(h=pcb_max_z+clPcbTop)topkeepout(pcb);
        // remove botHolder space
        difference() {
            translate([pcb_min_x-holderX-1,pcb_min_y-holderY-1,0])cube([pcb_max_x-pcb_min_x+holderX*2+2,pcb_max_y-pcb_min_y+holderY*2+2,botHolderAbovePCB2+botHolderAbovePCB1]);
            translate([0,0,-0.1])linear_extrude(height=botHolderAbovePCB2+botHolderAbovePCB1+0.2)pcbBorder(pcb,0.01);
        }
        // align holes
        translate([alignPole1X,alignPole1Y,botHolderAbovePCB1+botHolderAbovePCB2-0.1]){
            cylinder(h=alignPoleH+5,d=alignPoleD+alignPoleCl);
        }
        translate([alignPole2X,alignPole2Y,botHolderAbovePCB1+botHolderAbovePCB2-0.1]){
            cylinder(h=alignPoleH+5,d=alignPoleD+alignPoleCl);
        }
        
        //center pin holes
        for (cp=pcb_center_pins_xy){
            centerPin(cp[0],cp[1],3-botHolderPCBtoR75-r75HoldLength,centerPinD+clearancePcbTop,centerPinL+5);
        }
        
    }

}

module botHolder() {
    difference(){// greate main block
        translate([pcb_min_x-holderX,pcb_min_y-holderY,-(botHolderPCBtoR75+r75HoldLength)])cube([pcb_max_x-pcb_min_x+holderX*2,pcb_max_y-pcb_min_y+holderY*2,botHolderAbovePCB2+botHolderAbovePCB1+botHolderPCBtoR75+r75HoldLength]);
        translate([(pcb_min_x+pcb_max_x)/2,(pcb_min_y+pcb_max_y)/2,botHolderAbovePCB1])linear_extrude(h=botHolderAbovePCB2+0.1,scale=1.1)translate([-(pcb_min_x+pcb_max_x)/2,-(pcb_min_y+pcb_max_y)/2,0])pcbBorder(pcb,clearancePcbEdge);
        translate([0,0,-botHolderPCBtoR75])linear_extrude(h=botHolderAbovePCB1+botHolderPCBtoR75+0.1)pcbBorder(pcb,clearancePcbEdge);
        // TP holes
        for (pt = pcb_testpoints_xy)translate([pt[0],pt[1],-r75HoldLength-botHolderPCBtoR75-0.1])cylinder(h=r75HoldLength+0.2,d=r75HoleDia);        
        //center pin holes
        for (cp=pcb_center_pins_xy){
            centerPin(cp[0],cp[1],3-botHolderPCBtoR75-r75HoldLength,centerPinHole,centerPinL);
        }
    }
    // align pins
    translate([alignPole1X,alignPole1Y,botHolderAbovePCB1+botHolderAbovePCB2-0.1]){
        cylinder(h=alignPoleH-5+0.1,d=alignPoleD);
        translate([0,0,alignPoleH-5])cylinder(h=5,d1=alignPoleD,d2=alignPoleD-5);
    }
    translate([alignPole2X,alignPole2Y,botHolderAbovePCB1+botHolderAbovePCB2-0.1]){
        cylinder(h=alignPoleH-5+0.1,d=alignPoleD);
        translate([0,0,alignPoleH-5])cylinder(h=5,d1=alignPoleD,d2=alignPoleD-5);
    }

}

module R752W (x,y,z) {
    translate([x,y,z])union(){
        translate([0,0,-12.5+2.5])cylinder(h=12.5,d=1.32);
        cylinder(h=0.5,d=1.45);
        translate([0,0,-12.5+2.5-1])cylinder(h=1,d1=1.22,d2=1.32);
        translate([0,0,-12.5+2.5-1-4])cylinder(h=4,d=1.22);
        translate([0,0,-12.5+2.5-1-4-8.3])cylinder(h=8.3,d=0.64);
        translate([0,0,-12.5+2.5-1-4-8.3-0.7])cylinder(h=0.7,d1=0,d2=0.64);
    }
}

module P75B1 (x,y,z) {
    translate([x,y,z])union(){
        translate([0,0,-(tan(15)/(0.75/2))])cylinder(h=tan(15)/(0.75/2),d1=0.75,d2=0);
        translate([0,0,-3.3])cylinder(h=3.3-(tan(15)/(0.75/2)),d=0.75);
        translate([0,0,-3.3-12.5])cylinder(h=12.5,d=1.02);
    }
}

module centerPin (x,y,z,d,l) {
    translate([x,y,z])color("Gray")cylinder(h=l,d=d);
}

module pogoSet (x,y,z) {
    translate([x,y,z]) {
        R752W(0,0,0);
        P75B1(0,0,15.8-10+2);
    }
}

module pogoSetFromTestpoints(z = -botHolderPCBtoR75) {
    for (pt = pcb_testpoints_xy) {
        pogoSet(pt[0], pt[1], z);
    }
}



if(false){
    render()difference(){
        union(){
            //pcb
            color("Red", 1)render()import(pcb);
            //top
            color("Blue",1)render()topPusher(0);
            //bottom
            render()botHolder();
            //TPs
            pogoSetFromTestpoints();
        }
        translate([-20+1000+pcb_min_x+(pcb_max_x-pcb_min_x)/2,0,0])cube([2000,2000,2000],center=true);
    }
} else {

    //pcb
    color("Red", 1)render()import(pcb);
    //top
    color("Blue",1)render()topPusher(0);
    //bottom
    botHolder();
    //TPs
    pogoSetFromTestpoints();
    //center pins
    for (cp=pcb_center_pins_xy){
        centerPin(cp[0],cp[1],3-botHolderPCBtoR75-r75HoldLength,centerPinD,centerPinL);
    }
}
