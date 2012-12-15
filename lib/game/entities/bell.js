// Generated by CoffeeScript 1.3.3
(function() {

  ig.module('game.entities.bell').requires('impact.entity').defines(function() {
    return window.EntityBell = ig.Entity.extend({
      name: 'bell',
      size: {
        x: 16,
        y: 16
      },
      offset: {
        x: 0,
        y: 0
      },
      collides: ig.Entity.COLLIDES.FIXED,
      gravityFactor: 0,
      type: ig.Entity.TYPE.B,
      animSheet: new ig.AnimationSheet('media/bell.png', 16, 16),
      init: function(x, y, settings) {
        this.addAnim('idle', 0.2, [0]);
        this.addAnim('ringing', 0.2, [0, 1, 0, 2]);
        return this.parent(x, y, settings);
      },
      ring: function() {
        return this.currentAnim = this.anims.ringing;
      },
      update: function() {
        return this.parent();
      }
    });
  });

}).call(this);