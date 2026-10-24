#!/usr/bin/env python3
"""Dome hubs with rounded cloth faces and flat inward-facing print bases.

The print +Z direction is the dome OUTSIDE. Socket axes slope down toward the
bed. The cloth follows a rounded envelope over those axes rather than a broad
flat plate. Node centers and dowel insertion stops are unchanged.
"""
from __future__ import annotations

import argparse
import json
import math
from pathlib import Path

import cadquery as cq
import numpy as np

import generate_dome as dome
import optimize_hubs as fast

OUT = Path(__file__).resolve().parent / "cloth-safe"
FLOOR = -19.2
OUTER_RADIUS = fast.BORE_RADIUS + 2.4
EDGE_RADIUS = 1.6


def frame(normal, directions):
    rotation = dome.rotation_between(normal, (0, 0, 1))
    return rotation, (rotation @ directions.T).T


def outer_body(directions):
    # The outer cap is a single shallow cone with a tangent spherical crown.
    # Intersecting it with a rounded star footprint avoids tube intersections
    # altogether, while still following the approximate slope of the struts.
    model=cq.Workplane("XY").circle(11).extrude(40).translate((0,0,FLOOR))
    for direction in directions:
        radial=dome.normalize((direction[0],direction[1],0))
        side=np.array((-radial[1],radial[0],0))
        end=direction*fast.MOUTH_DISTANCE
        points=[tuple((side*OUTER_RADIUS)[:2]),tuple((end+side*OUTER_RADIUS)[:2]),tuple((end-side*OUTER_RADIUS)[:2]),tuple((-side*OUTER_RADIUS)[:2])]
        arm=cq.Workplane("XY").polyline(points).close().extrude(40).translate((0,0,FLOOR))
        model=model.union(arm)
    model=model.clean().edges("|Z").fillet(2.4).clean()
    slope=0.29
    tangent_radius=4.0
    sphere_radius=tangent_radius*math.sqrt(1+1/slope**2)
    center_z=OUTER_RADIUS-sphere_radius
    tangent_z=center_z+math.sqrt(sphere_radius**2-tangent_radius**2)
    mid_z=center_z+math.sqrt(sphere_radius**2-2.0**2)
    cap=(cq.Workplane("XZ").moveTo(0,FLOOR-1).lineTo(45,FLOOR-1)
         .lineTo(45,tangent_z-slope*(45-tangent_radius)).lineTo(tangent_radius,tangent_z)
         .threePointArc((2,mid_z),(0,OUTER_RADIUS)).close().revolve(360,(0,0),(0,1)))
    model=model.intersect(cap).clean()
    edges=[edge for edge in model.val().Edges()if edge.BoundingBox().zmin>FLOOR+1 and edge.Length()>0.1]
    return model.newObject(edges).fillet(EDGE_RADIUS).clean()


def truncated_roof_bore(direction):
    up = dome.accessible_normal(np.array((0,0,1.0)),direction)
    side = dome.normalize(np.cross(direction,up))
    plane = cq.Plane(origin=dome.cq_vector(direction*dome.SOCKET_BORE_STOP),xDir=dome.cq_vector(side),normal=dome.cq_vector(direction))
    if np.dot(np.array(plane.yDir.toTuple()),up)<0:
        plane = cq.Plane(origin=dome.cq_vector(direction*dome.SOCKET_BORE_STOP),xDir=dome.cq_vector(-side),normal=dome.cq_vector(direction))
    r=fast.BORE_RADIUS
    tangent=r/math.sqrt(2)
    # The roof uses 45-degree flanks and a short 5.5 mm bridge at circle-top
    # height. A full teardrop apex would force a tall ridge under the cloth.
    cap_half_width=r*math.sqrt(2)-r
    length=fast.MOUTH_DISTANCE-dome.SOCKET_BORE_STOP+4
    circle=cq.Workplane(plane).circle(r).extrude(length)
    cap=(cq.Workplane(plane).polyline([(-tangent,tangent),(-cap_half_width,r),(cap_half_width,r),(tangent,tangent)]).close().extrude(length))
    return circle.union(cap).clean()


def build(directions):
    model=outer_body(directions)
    for direction in directions:
        model=model.cut(truncated_roof_bore(direction))
    # Retaining screws enter from the interior/bed side. Screw heads and
    # access holes are consequently kept away from the decorative cloth.
    for direction in directions:
        axis_point=direction*25.5
        model=model.cut(dome.cylinder_along(1.8,float(axis_point[2]-FLOOR+1),(axis_point[0],axis_point[1],FLOOR-1),(0,0,1)))
        # Stop the vertical cutter at the bore center, rather than continuing
        # through the rounded cloth-contact surface.
    return model.clean().translate((0,0,-FLOOR))


def write_interface_profile(model,direction):
    """Sample the real CAD crown along one long socket centerline."""
    from OCP.IntCurvesFace import IntCurvesFace_ShapeIntersector
    from OCP.gp import gp_Lin,gp_Pnt,gp_Dir
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    horizontal=float(np.linalg.norm(direction[:2]))
    radial=direction[:2]/horizontal
    ray=IntCurvesFace_ShapeIntersector()
    ray.Load(model.val().wrapped,1e-6)
    distances=np.linspace(0,fast.MOUTH_DISTANCE*horizontal-0.2,100)
    heights=[]
    for distance in distances:
        ray.Perform(gp_Lin(gp_Pnt(float(radial[0]*distance),float(radial[1]*distance),-50),gp_Dir(0,0,1)),0,120)
        heights.append(max(ray.Pnt(i).Z()for i in range(1,ray.NbPnt()+1))+FLOOR)
    fig,axis=plt.subplots(figsize=(9,4.5),constrained_layout=True)
    axis.plot(distances,heights,color="#287f9c",lw=3,label="New rounded cloth face (CAD section)")
    axis.plot(distances,np.full_like(distances,4.8),color="#d97706",lw=2,ls="--",label="Previous flat cloth face")
    wood_x=np.linspace(18,42,100)
    wood_z=wood_x*direction[2]/horizontal+dome.DOWEL_DIAMETER/2/horizontal
    axis.plot(wood_x,wood_z,color="#654321",lw=3,label="Outside of wooden dowel")
    axis.set_xlabel("Distance from joint center along a long socket (mm)")
    axis.set_ylabel("Toward the cloth / outside → (mm)")
    axis.set_title("Side profile: the cloth face now follows the dowel slope")
    axis.legend(loc="lower left",fontsize=8)
    axis.grid(alpha=0.2)
    fig.savefig(OUT/"cloth-interface-profile.png",dpi=180)
    plt.close(fig)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--all",action="store_true")
    parser.add_argument("--assembly",action="store_true")
    args=parser.parse_args()
    OUT.mkdir(parents=True,exist_ok=True)
    geometry=dome.classify_geometry(dome.DOME_RADIUS)
    kinds=("4-way-A","4-way-B","5-way","6-way")if args.all else("5-way","6-way")
    rows=[]
    models={}
    representatives={}
    for kind in kinds:
        _,normal,directions,_=dome.representative_data(geometry,kind)
        rotation,local=frame(normal,directions)
        model=build(local)
        dome.validate_solid(kind,model)
        fast.export(model,OUT/f"cloth-{kind}")
        rows.append({"name":kind,"volume_cm3":model.val().Volume()/1000,"height_mm":model.val().BoundingBox().zlen})
        models[kind]=model
        if kind=="6-way":
            write_interface_profile(model,local[int(np.argmin(local[:,2]))])
        representatives[kind]=dome.transform_workplane(model.translate((0,0,FLOOR)),rotation.T,np.zeros(3))
    old_out=fast.OUT
    fast.OUT=OUT
    fast.render(models,title="Cloth-facing side — rounded, sloping outward face; flat base faces inside")
    fast.OUT=old_out
    (OUT/"comparison.json").write_text(json.dumps(rows,indent=2)+"\n")
    angle=math.radians(18)
    coupon=build(np.array([(math.cos(angle),0,-math.sin(angle))]))
    dome.validate_solid("cloth-side socket test",coupon)
    fast.export(coupon,OUT/"cloth-socket-test")
    if args.assembly:
        if len(representatives)!=4:
            parser.error("assembly needs --all")
        assembly=dome.build_full_assembly(geometry,representatives)
        assembly.export(str(OUT/"dome-cloth-assembly.step"),exportType="STEP")
        print("Exported cloth-side assembly",flush=True)


if __name__=="__main__":
    main()
