ig.module(
	'game.entities.bell'
)
.requires(
	'impact.entity'
)
.defines ->

    window.EntityBell = ig.Entity.extend

        name: 'bell'
        
        size: { x:16, y:16 }
        offset: { x:0, y:0 }
        collides: ig.Entity.COLLIDES.FIXED
        gravityFactor: 0

        type: ig.Entity.TYPE.B

        animSheet: new ig.AnimationSheet('media/bell.png', 16, 16)

        init: (x, y, settings) ->
            @addAnim('idle', 0.2, [0])
            @addAnim('ringing', 0.2, [0,1,0,2])

            @parent(x, y, settings)

        ring: ->
            @currentAnim = @anims.ringing

        update: ->

            @parent()




