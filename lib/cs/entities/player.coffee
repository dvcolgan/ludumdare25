ig.module(
	'game.entities.player'
)
.requires(
	'impact.entity'
)
.defines ->

    window.EntityPlayer = ig.Entity.extend
        name: 'player'
        
        size: { x:10, y:28 }
        offset: { x:2, y:4 }
        friction: {x: 80, y: 80}
        collides: ig.Entity.COLLIDES.PASSIVE

        animSheet: new ig.AnimationSheet('media/player/player.png', 16, 32)

        type: ig.Entity.TYPE.A

        flip: false
        maxVel: {x: 70, y: 70}

        init: (x, y, settings) ->
            @addAnim('idle', 0.1, [0,0,0,0,1,0,1,0,0,0,0,0,0,0,2,0,2,0])
            #@addAnim('walking', 0.1, [3,4,5,4])
            #@addAnim('flying', 0.2, [6,7])

            @parent(x, y, settings)

        draw: ->
            @parent()

        update: ->
            @accel.y = 70
            @currentAnim = @anims.idle
            if ig.input.state('left') == ig.input.state('right')
                @currentAnim = @anims.idle
                #@anims.walking.rewind()
            else
                if ig.input.state('left')
                    @accel.x = -70
                    #@currentAnim = @anims.walking
                    @flip = true
                else if ig.input.state('right')
                    @accel.x = 70
                    #@currentAnim = @anims.walking
                    @flip = false

            if ig.input.state('jump')
                @accel.y = -80

            if not ig.input.state('left') and not ig.input.state('right')
                @accel.x = 0

            if @pos.x < 0
                @pos.x = 0
                @accel.x = @vel.x = 0

            @parent()


            #if ig.input.state('up')
            #    @accel.y = -80
            #    @currentAnim = @anims.flying
            #    particle = ig.game.spawnEntity(NS.EntityRainbowParticle, @pos.x + 3, @pos.y + 4)
            #    particle.vel.x = -@vel.x * Math.random()
            #    if Math.random() < 0.04
            #        particle = ig.game.spawnEntity(NS.EntityBigPoop, @pos.x + 3, @pos.y + 4)
            #        particle.vel.x = @vel.x * -2 * Math.random()
            
            @currentAnim.flip.x = @flip

