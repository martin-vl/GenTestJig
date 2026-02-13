include <params.scad>;

pcb = "pcb/24-clocks.stl";
pcbTicknes = 1.6;
clearancePcbTop=1;
clearancePcbEdge=0.5;
holderY=10;
holderX=20;

$fn=60;

module pcbBorder(pcb) {
    minkowski() {
        hull()projection(cut=true)import(pcb);
        circle(clearancePcbEdge*2);
    }
}

module topkeepout(pcb) {
    minkowski() {
        projection(cut=false)intersection(){
            import(pcb);
            translate([pcb_min_x-5,pcb_min_y-5,pcbTicknes+0.1])cube([pcb_max_x-pcb_min_x+10,pcb_max_y-pcb_min_y+10,pcb_max_z-pcb_min_z+10]);
        }
        circle(clearancePcbTop*2);
    }
}

module topPusher(z) {
    clPcbTop=5;
    topTick=20;
    difference() {
        // greate main block
        translate([pcb_min_x-holderX,pcb_min_y-holderY,pcbTicknes])cube([pcb_max_x-pcb_min_x+holderX*2,pcb_max_y-pcb_min_y+holderY*2,pcb_max_z+clPcbTop+topTick]);
        // substract PCB keepout
        linear_extrude(h=pcb_max_z+clPcbTop)children();
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

module pogoSet (x,y,z) {
    translate([x,y,z]) {
        R752W(0,0,0);
        P75B1(0,0,15.8-10+2);
    }
}

module pogoSetFromTestpoints(z = -5) {
    for (pt = pcb_testpoints_xy) {
        pogoSet(pt[0], pt[1], z);
    }
}

//color("Red", 0.2)import(pcb);


color("Blue",1)topPusher(0){
    topkeepout(pcb);
}

pogoSetFromTestpoints();

//pcbBorder(pcb);
