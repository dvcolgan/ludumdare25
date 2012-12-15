ig.module(
    'plugins.box2d.game'
)
    .requires(
    'plugins.box2d.lib',
    'impact.game'
)
    .defines(function() {


        ig.Box2DGame = ig.Game.extend({

            collisionRects: [],
            collisionTriangles: [],
            collisionPolys4: [],
            debugCollisionRects: false,

            loadLevel: function(data) {

                // Find the collision layer and create the box2d world from it
                for (var i = 0; i < data.layer.length; i++) {
                    var ld = data.layer[i];
                    if (ld.name == 'collision') {
                        ig.world = this.createWorldFromMap(ld.data, ld.width, ld.height, ld.tilesize);
                        break;
                    }
                }

                this.parent(data);
            },

            createWorldFromMap: function(origData, width, height, tilesize) {
                var worldBoundingBox = new b2.AABB();
                worldBoundingBox.lowerBound.Set(0, 0);
                worldBoundingBox.upperBound.Set(
                    (width + 1) * tilesize * b2.SCALE,
                    (height + 1) * tilesize * b2.SCALE
                );

                var gravity = new b2.Vec2(0, this.gravity * b2.SCALE);
                var world = new b2.World(worldBoundingBox, gravity, true);

                // We need to delete those tiles that we already processed. The original
                // map data is copied, so we don't destroy the original.
                var data = ig.copy(origData);

                // Get all the Collision Rects and Slopes from the map
                this.collisionRects = []; // Original Rectangle Polygons
                this.collisionTriangles = []; // New Triangle slope Polygons
                this.collisionPolys4 = []; // New 4 point slope Polygons

                for (var y = 0; y < height; y++) {
                    for (var x = 0; x < width; x++) {

                        // Create Triangle slope polygons
                        if (data [y][x] == 2 || data [y][x] == 13 || data [y][x] == 24 || data [y][x] == 35 ||
                            data [y][x] == 3 || data [y][x] == 14 || data [y][x] == 26 || data [y][x] == 37 ||
                            data [y][x] == 5 || data [y][x] == 16 || data [y][x] == 29 || data [y][x] == 40 ||
                            data [y][x] == 10 || data [y][x] == 11 || data [y][x] == 19 || data [y][x] == 20 ||
                            data [y][x] == 32 || data [y][x] == 33 || data [y][x] == 52 || data [y][x] == 53) {

                            var poly = {y:y,x:x,ptype:data [y][x]};
                            data[y][x] = 0; //unset Tile
                            this.collisionTriangles.push(poly);
                        }
                        // Create 4 point slope polygons
                        else if (data [y][x] == 4 || data [y][x] == 15 || data [y][x] == 25 || data [y][x] == 36 ||
                            data [y][x] == 6 || data [y][x] == 17 || data [y][x] == 28 || data [y][x] == 39 ||
                            data [y][x] == 7 || data [y][x] == 18 || data [y][x] == 27 || data [y][x] == 38 ||
                            data [y][x] == 8 || data [y][x] == 9 || data [y][x] == 21 || data [y][x] == 22 ||
                            data [y][x] == 41 || data [y][x] == 42 || data [y][x] == 43 || data [y][x] == 44 ||
                            data [y][x] == 30 || data [y][x] == 31 || data [y][x] == 54 || data [y][x] == 55) {

                            var poly = {y:y,x:x,ptype:data [y][x]};
                            data[y][x] = 0; //unset Tile
                            this.collisionPolys4.push(poly);
                        }
                        // If this tile is solid, find the rect of solid tiles starting
                        // with this one
                        else if (data[y][x] == 1) {

                            var r = this._extractRectFromMap(data, width, height, x, y);
                            this.collisionRects.push(r);
                        }
                    }
                }

                // Go through all rects we gathered and create Box2D objects from them
                for (var i = 0; i < this.collisionRects.length; i++) {
                    var rect = this.collisionRects[i];


                    var bodyDef = new b2.BodyDef();
                    bodyDef.position.Set(
                        rect.x * tilesize * b2.SCALE + rect.width * tilesize / 2 * b2.SCALE,
                        rect.y * tilesize * b2.SCALE + rect.height * tilesize / 2 * b2.SCALE
                    );

                    var body = world.CreateBody(bodyDef);
                    var shape = new b2.PolygonDef();
                    shape.SetAsBox(
                        rect.width * tilesize / 2 * b2.SCALE,
                        rect.height * tilesize / 2 * b2.SCALE
                    );
                    body.CreateShape(shape);
                }

                // Calculate rise for slope Polygons.
                var rise1 = (Math.tan((26.5).toRad()) * tilesize);
                var rise2 = (Math.tan((18.43).toRad()) * tilesize);
                var rise3 = (Math.tan((18.43).toRad()) * (2 * tilesize));

                // Go through all triangle polygons we gathered and create Box2D objects from them
                for (var i = 0; i < this.collisionTriangles.length; i++) {
                    var poly = this.collisionTriangles[i];

                    var bodyDef = new b2.BodyDef();
                    bodyDef.position.Set(
                        poly.x * tilesize * b2.SCALE + 1 * tilesize / 2 * b2.SCALE,
                        poly.y * tilesize * b2.SCALE + 1 * tilesize / 2 * b2.SCALE
                    );

                    var body = world.CreateBody(bodyDef);
                    var shape = new b2.PolygonDef();
                    shape.vertexCount = 3;

                    if (poly.ptype == 2) {// NW 45
                        var x1 = -.5 * tilesize * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = .5 * tilesize * b2.SCALE;
                        var y2 = .5 * tilesize * b2.SCALE;
                        var x3 = .5 * tilesize * b2.SCALE;
                        var y3 = -.5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 13) {// SW 45
                        var x1 = -.5 * tilesize * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = .5 * tilesize * b2.SCALE;
                        var y2 = .5 * tilesize * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = -.5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 24) {  // SW 45
                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = .5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = -.5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 35) {  // SE 45
                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 3) {  // NW 26.5

                        var x1 = ((.5 * tilesize) - rise1) * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = .5 * tilesize * b2.SCALE;
                        var y2 = .5 * tilesize * b2.SCALE;
                        var x3 = .5 * tilesize * b2.SCALE;
                        var y3 = -.5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 14) {  // SE 26.5

                        var x1 = ((.5 * tilesize) - rise1) * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;

                    }
                    else if (poly.ptype == 26) {  // SE 26.5

                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -((.5 * tilesize) - rise1) * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = .5 * tilesize * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;

                    }
                    else if (poly.ptype == 37) {  // SE 26.5

                        var x1 = ((.5 * tilesize) - rise1) * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;

                    }

                    else if (poly.ptype == 5) {  // NW 15

                        var x1 = ((.5 * tilesize) - rise2) * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = .5 * tilesize * b2.SCALE;
                        var y2 = .5 * tilesize * b2.SCALE;
                        var x3 = .5 * tilesize * b2.SCALE;
                        var y3 = -.5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 16) {  // SE 15

                        var x1 = -((.5 * tilesize) - rise2) * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 29) {  // SE 15

                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = ((.5 * tilesize) - rise2) * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = .5 * tilesize * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 40) {  // SE 15

                        var x1 = -((.5 * tilesize) - rise2) * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;
                    }

                    else if (poly.ptype == 10) {  // SE 15

                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = .5 * tilesize * b2.SCALE;
                        var y2 = ((.5 * tilesize) - rise1) * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 11) {  // SE 15

                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = .5 * tilesize * b2.SCALE;
                        var y3 = ((.5 * tilesize) - rise1) * b2.SCALE;
                    }

                    else if (poly.ptype == 19) {  // SE 15

                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = -((.5 * tilesize) - rise1) * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 20) {  // SE 15

                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = -((.5 * tilesize) - rise1) * b2.SCALE;
                    }

                    else if (poly.ptype == 32) {  // NW 15

                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = .5 * tilesize * b2.SCALE;
                        var y2 = ((.5 * tilesize) - rise2) * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 33) {  // SE 15

                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = .5 * tilesize * b2.SCALE;
                        var y3 = -((.5 * tilesize) - rise2) * b2.SCALE;
                    }
                    else if (poly.ptype == 52) {  // SE 15

                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = ((.5 * tilesize) - rise2) * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 53) {  // SE 15

                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = -((.5 * tilesize) - rise2) * b2.SCALE;
                    }

                    shape.vertices[0].Set(y1, x1);
                    shape.vertices[1].Set(y2, x2);
                    shape.vertices[2].Set(y3, x3);

                    body.CreateShape(shape);
                }

                // Go through all 4 point slope polygons we gathered and create Box2D objects from them
                for (var i = 0; i < this.collisionPolys4.length; i++) {
                    var poly = this.collisionPolys4[i];

                    var bodyDef = new b2.BodyDef();
                    bodyDef.position.Set(
                        poly.x * tilesize * b2.SCALE + 1 * tilesize / 2 * b2.SCALE,
                        poly.y * tilesize * b2.SCALE + 1 * tilesize / 2 * b2.SCALE

                    );

                    var body = world.CreateBody(bodyDef);
                    var shape = new b2.PolygonDef();
                    shape.vertexCount = 4;



                    if (poly.ptype == 4) {
                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = ((.5 * tilesize) - rise1) * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;
                        var x4 = .5 * tilesize * b2.SCALE;
                        var y4 = .5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 15) {
                        var x1 = -.5 * tilesize * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = .5 * tilesize * b2.SCALE;
                        var y2 = .5 * tilesize * b2.SCALE;
                        var x3 = ((.5 * tilesize) - rise1) * b2.SCALE;
                        var y3 = -.5 * tilesize * b2.SCALE;
                        var x4 = -.5 * tilesize * b2.SCALE;
                        var y4 = -.5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 25) {
                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = -((.5 * tilesize) - rise1) * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;
                        var x4 = .5 * tilesize * b2.SCALE;
                        var y4 = .5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 36) {
                        var x1 = -.5 * tilesize * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = .5 * tilesize * b2.SCALE;
                        var y3 = -.5 * tilesize * b2.SCALE;
                        var x4 = ((.5 * tilesize) - rise1) * b2.SCALE;
                        var y4 = .5 * tilesize * b2.SCALE;
                    }

                    else if (poly.ptype == 6) {
                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = ((.5 * tilesize) - rise2) * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = ((.5 * tilesize) - rise3) * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;
                        var x4 = .5 * tilesize * b2.SCALE;
                        var y4 = .5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 17) {
                        var x1 = -.5 * tilesize * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = ((.5 * tilesize) - rise2) * b2.SCALE;
                        var y2 = .5 * tilesize * b2.SCALE;
                        var x3 = ((.5 * tilesize) - rise3) * b2.SCALE;
                        var y3 = -.5 * tilesize * b2.SCALE;
                        var x4 = -.5 * tilesize * b2.SCALE;
                        var y4 = -.5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 28) {
                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -((.5 * tilesize) - rise2) * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = -((.5 * tilesize) - rise3) * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;
                        var x4 = .5 * tilesize * b2.SCALE;
                        var y4 = .5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 39) {
                        var x1 = -.5 * tilesize * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = ((.5 * tilesize) - rise3) * b2.SCALE;
                        var y2 = .5 * tilesize * b2.SCALE;
                        var x3 = ((.5 * tilesize) - rise2) * b2.SCALE;
                        var y3 = -.5 * tilesize * b2.SCALE;
                        var x4 = -.5 * tilesize * b2.SCALE;
                        var y4 = -.5 * tilesize * b2.SCALE;
                    }

                    else if (poly.ptype == 7) {
                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = ((.5 * tilesize) - rise3) * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;
                        var x4 = .5 * tilesize * b2.SCALE;
                        var y4 = .5 * tilesize * b2.SCALE;
                    }

                    else if (poly.ptype == 18) {
                        var x1 = -.5 * tilesize * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = .5 * tilesize * b2.SCALE;
                        var y2 = .5 * tilesize * b2.SCALE;
                        var x3 = -((.5 * tilesize) - rise3) * b2.SCALE;
                        var y3 = -.5 * tilesize * b2.SCALE;
                        var x4 = -.5 * tilesize * b2.SCALE;
                        var y4 = -.5 * tilesize * b2.SCALE;
                    }

                    else if (poly.ptype == 27) {
                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = ((.5 * tilesize) - rise3) * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;
                        var x4 = .5 * tilesize * b2.SCALE;
                        var y4 = .5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 38) {
                        var x1 = -.5 * tilesize * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = .5 * tilesize * b2.SCALE;
                        var y3 = -.5 * tilesize * b2.SCALE;
                        var x4 = -((.5 * tilesize) - rise3) * b2.SCALE;
                        var y4 = .5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 8) {
                        var x1 = -.5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = .5 * tilesize * b2.SCALE;
                        var x3 = .5 * tilesize * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;
                        var x4 = .5 * tilesize * b2.SCALE;
                        var y4 = ((.5 * tilesize) - rise1) * b2.SCALE;
                    }
                    else if (poly.ptype == 9) {
                        var x1 = -.5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = .5 * tilesize * b2.SCALE;
                        var x3 = .5 * tilesize * b2.SCALE;
                        var y3 = ((.5 * tilesize) - rise1) * b2.SCALE;
                        var x4 = .5 * tilesize * b2.SCALE;
                        var y4 = -.5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 21) {
                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = ((.5 * tilesize) - rise1) * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;
                        var x4 = .5 * tilesize * b2.SCALE;
                        var y4 = .5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 22) {
                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = -((.5 * tilesize) - rise1) * b2.SCALE;
                        var x4 = .5 * tilesize * b2.SCALE;
                        var y4 = .5 * tilesize * b2.SCALE;
                    }

                    else if (poly.ptype == 41) {
                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = .5 * tilesize * b2.SCALE;
                        var y2 = -((.5 * tilesize) - rise3) * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = -((.5 * tilesize) - rise2) * b2.SCALE;
                        var x4 = -.5 * tilesize * b2.SCALE;
                        var y4 = .5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 42) {
                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = ((.5 * tilesize) - rise2) * b2.SCALE;
                        var x4 = .5 * tilesize * b2.SCALE;
                        var y4 = ((.5 * tilesize) - rise3) * b2.SCALE;

                    }
                    else if (poly.ptype == 43) {
                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = .5 * tilesize * b2.SCALE;
                        var y2 = -((.5 * tilesize) - rise2) * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = -((.5 * tilesize) - rise3) * b2.SCALE;
                        var x4 = -.5 * tilesize * b2.SCALE;
                        var y4 = .5 * tilesize * b2.SCALE;
                    }
                    else if (poly.ptype == 44) {
                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = ((.5 * tilesize) - rise3) * b2.SCALE;
                        var x4 = .5 * tilesize * b2.SCALE;
                        var y4 = ((.5 * tilesize) - rise2) * b2.SCALE;
                    }

                    else if (poly.ptype == 30) {
                        var x1 = -.5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = .5 * tilesize * b2.SCALE;
                        var x3 = .5 * tilesize * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;
                        var x4 = .5 * tilesize * b2.SCALE;
                        var y4 = ((.5 * tilesize) - rise3) * b2.SCALE;
                    }

                    else if (poly.ptype == 31) {
                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = -.5 * tilesize * b2.SCALE;
                        var x2 = -.5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = .5 * tilesize * b2.SCALE;
                        var x4 = .5 * tilesize * b2.SCALE;
                        var y4 = -((.5 * tilesize) - rise3) * b2.SCALE;
                    }

                    else if (poly.ptype == 54) {
                        var x1 = -.5 * tilesize * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = .5 * tilesize * b2.SCALE;
                        var y2 = .5 * tilesize * b2.SCALE;
                        var x3 = .5 * tilesize * b2.SCALE;
                        var y3 = -.5 * tilesize * b2.SCALE;
                        var x4 = -.5 * tilesize * b2.SCALE;
                        var y4 = ((.5 * tilesize) - rise3) * b2.SCALE;
                    }
                    else if (poly.ptype == 55) {
                        var x1 = .5 * tilesize * b2.SCALE;
                        var y1 = .5 * tilesize * b2.SCALE;
                        var x2 = .5 * tilesize * b2.SCALE;
                        var y2 = -.5 * tilesize * b2.SCALE;
                        var x3 = -.5 * tilesize * b2.SCALE;
                        var y3 = -.5 * tilesize * b2.SCALE;
                        var x4 = -.5 * tilesize * b2.SCALE;
                        var y4 = -((.5 * tilesize) - rise3) * b2.SCALE;
                    }

                    shape.vertices[0].Set(y1, x1);
                    shape.vertices[1].Set(y2, x2);
                    shape.vertices[2].Set(y3, x3);
                    shape.vertices[3].Set(y4, x4);

                    body.CreateShape(shape);
                }

                return world;
            },


            _extractRectFromMap: function(data, width, height, x, y) {
                var rect = {x: x, y: y, width: 1, height: 1};


                // Find the width of this rect
                for (var wx = x + 1; wx < width && data[y][wx] == 1; wx++) {
                    rect.width++;
                    data[y][wx] = 0; // unset tile
                }

                // Check if the next row with the same width is also completely solid
                for (var wy = y + 1; wy < height; wy++) {
                    var rowWidth = 0;
                    for (wx = x; wx < x + rect.width && data[wy][wx] == 1; wx++) {
                        rowWidth++;
                    }

                    // Same width as the rect? -> All tiles are solid; increase height
                    // of this rect
                    if (rowWidth == rect.width) {
                        rect.height++;

                        // Unset tile row from the map
                        for (wx = x; wx < x + rect.width; wx++) {
                            data[wy][wx] = 0;
                        }
                    }
                    else {
                        return rect;
                    }
                }
                return rect;
            },


            update: function() {
                ig.world.Step(ig.system.tick, 5);
                this.parent();
            },

            draw: function() {
                this.parent();

                if (this.debugCollisionRects) {
                    // Draw outlines of all collision rects
                    var ts = this.collisionMap.tilesize;
                    for (var i = 0; i < this.collisionRects.length; i++) {
                        var rect = this.collisionRects[i];
                        ig.system.context.strokeStyle = '#00ff00';
                        ig.system.context.strokeRect(
                            ig.system.getDrawPos(rect.x * ts - this.screen.x),
                            ig.system.getDrawPos(rect.y * ts - this.screen.y),
                            ig.system.getDrawPos(rect.width * ts),
                            ig.system.getDrawPos(rect.height * ts)
                        );
                    }
                }
            }


        });

    });

//
//
//ig.module( 
//	'plugins.box2d.game'
//)
//.requires(
//	'plugins.box2d.lib',
//	'impact.game'
//)
//.defines(function(){
//	
//	
//	
//ig.Box2DGame = ig.Game.extend({
//		
//	collisionRects: [],
//	debugCollisionRects: false,
//	
//	
//	loadLevel: function( data ) {
//		
//		// Find the collision layer and create the box2d world from it
//		for( var i = 0; i < data.layer.length; i++ ) {
//			var ld = data.layer[i];
//			if( ld.name == 'collision' ) {
//				ig.world = this.createWorldFromMap( ld.data, ld.width, ld.height, ld.tilesize );
//				break;
//			}
//		}
//		
//		this.parent( data );
//	},
//	
//	
//	createWorldFromMap: function( origData, width, height, tilesize ) {	
//		var worldBoundingBox = new b2.AABB();
//		worldBoundingBox.lowerBound.Set( 0, 0 );
//		worldBoundingBox.upperBound.Set(
//			(width + 1) * tilesize * b2.SCALE,
//			(height + 1) * tilesize  * b2.SCALE
//		);
//		
//		var gravity = new b2.Vec2( 0, this.gravity * b2.SCALE );
//		var world = new b2.World( worldBoundingBox, gravity, true );
//		
//		
//		// We need to delete those tiles that we already processed. The original
//		// map data is copied, so we don't destroy the original.
//		var data = ig.copy( origData );
//		
//		// Get all the Collision Rects from the map
//		this.collisionRects = [];
//		for( var y = 0; y < height; y++ ) {
//			for( var x = 0; x < width; x++ ) {
//				// If this tile is solid, find the rect of solid tiles starting
//				// with this one
//				if( data[y][x] ) {
//					var r = this._extractRectFromMap( data, width, height, x, y );
//					this.collisionRects.push( r );
//				}
//			}
//		}
//		
//		// Go through all rects we gathered and create Box2D objects from them
//		for( var i = 0; i < this.collisionRects.length; i++ ) {
//			var rect = this.collisionRects[i];
//			
//			var bodyDef = new b2.BodyDef();
//			bodyDef.position.Set(
//				rect.x * tilesize * b2.SCALE + rect.width * tilesize / 2 * b2.SCALE,
//				rect.y * tilesize * b2.SCALE + rect.height * tilesize / 2 * b2.SCALE
//			);
//			
//			var body = world.CreateBody( bodyDef );
//			var shape = new b2.PolygonDef();
//			shape.SetAsBox(
//				rect.width * tilesize / 2 * b2.SCALE,
//				rect.height * tilesize / 2 * b2.SCALE
//			);
//			body.CreateShape( shape );
//		}
//		
//		return world;
//	},
//	
//	
//	_extractRectFromMap: function( data, width, height, x, y ) {
//		var rect = {x: x, y: y, width: 1, height: 1};
//		
//		// Find the width of this rect
//		for(var wx = x + 1; wx < width && data[y][wx]; wx++ ) {
//			rect.width++;
//			data[y][wx] = 0; // unset tile
//		}
//		
//		// Check if the next row with the same width is also completely solid
//		for( var wy = y + 1; wy < height; wy++ ) {
//			var rowWidth = 0;
//			for( wx = x; wx < x + rect.width && data[wy][wx]; wx++ ) {
//				rowWidth++;
//			}
//			
//			// Same width as the rect? -> All tiles are solid; increase height
//			// of this rect
//			if( rowWidth == rect.width ) {
//				rect.height++;
//				
//				// Unset tile row from the map
//				for( wx = x; wx < x + rect.width; wx++ ) {
//					data[wy][wx] = 0;
//				}
//			}
//			else {
//				return rect;
//			}
//		}
//		return rect;
//	},
//	
//	
//	update: function() {
//		ig.world.Step( ig.system.tick, 5 );
//		this.parent();
//	},
//	
//	
//	draw: function() {
//		this.parent();
//		
//		if( this.debugCollisionRects ) {
//			// Draw outlines of all collision rects
//			var ts = this.collisionMap.tilesize;
//			for( var i = 0; i < this.collisionRects.length; i++ ) {
//				var rect = this.collisionRects[i];
//				ig.system.context.strokeStyle = '#00ff00';
//				ig.system.context.strokeRect(
//					ig.system.getDrawPos( rect.x * ts - this.screen.x ),
//					ig.system.getDrawPos( rect.y * ts - this.screen.y ),
//					ig.system.getDrawPos( rect.width * ts ),
//					ig.system.getDrawPos( rect.height * ts )
//				);
//			}
//		}
//	}
//	
//	
//});
//	
//});
//
