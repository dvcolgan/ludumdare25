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
      ringTimer: new ig.Timer(),
      timesRung: 0,
      ringing: false,
      init: function(x, y, settings) {
        this.addAnim('idle', 0.2, [0]);
        this.addAnim('ringing', 0.2, [0, 1, 0, 2]);
        this.parent(x, y, settings);
        return this.ringTimer.reset();
      },
      ring: function() {
        window.soundManager.play('bell');
        this.ringTimer.reset();
        this.ringing = true;
        this.currentAnim = this.anims.ringing;
        return this.timesRung += 1;
      },
      update: function() {
        if (this.ringing) {
          if (this.ringTimer.delta() > 1) {
            window.soundManager.play('bell');
            this.ringTimer.reset();
            this.timesRung += 1;
            if (this.timesRung >= 3) {
              this.ringing = false;
              this.timesRung = 0;
            }
          }
        } else {
          if (this.ringTimer.delta() > 1) {
            this.currentAnim = this.anims.idle;
            this.ringTimer.reset();
          }
        }
        return this.parent();
      }
    });
  });

}).call(this);
