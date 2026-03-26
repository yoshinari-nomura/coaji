include <BOSL2/std.scad>

module show_faces(s=10, fg=undef, bg="white", overlap=0) {
  check = assert($parent_geom != undef);
  // font = "Meiryo";
  font = "Noto Sans CJK JP";

  faces = [TOP, BOT, LEFT, RIGHT, FRONT, BACK];
  names = ["上", "下", "左", "右", "前", "後"];

  echo($parent_geom);

  for (i = [0:5]) {
    attach(faces[i], BOT, overlap=overlap) {
      recolor(bg) cube([s/5, s/5, 0.1], center=true)
        color(fg) linear_extrude(height=0.2)
          text(text=names[i], size=s/8, anchor=CENTER, font=font);
    }
  }
  children();
}

left(10) recolor("red") cuboid([10, 10, 5])
  show_faces(fg="red");

right(10) cuboid(10)
  show_anchors(4)
    show_faces(4, overlap=-4);
