LD25 = {}

ig.module(
	'game.main'
)
.requires(
	'impact.entity'
	'impact.game'
	'impact.font'
)
.defines ->

    LD25.sounds = {}

    #LD25.EntityParticle = ig.Entity.extend
    #    size: {x:1, y:1}
    #    offset: {x:0, y:0}

    #    type: ig.Entity.TYPE.NONE
    #    checkAgainst: ig.Entity.TYPE.NONE
    #    collides: ig.Entity.COLLIDES.LITE

    #    lifetime: 5
    #    fadetime: 1
    #    #minBounceVelocity: 0
    #    #bounciness: 1.0
    #    #friction: { x:0, y:0 }

    #    init: (x, y, settings) ->
    #        @parent(x, y, settings)
    #        @idleTimer = new ig.Timer()

    #    update: ->
    #        if @idleTimer.delta() > @lifetime
    #            @kill()
    #            return

    #        @currentAnim.alpha = @idleTimer.delta().map(@lifetime - @fadetime, @lifetime, 1, 0)
    #        @parent()



    #LD25.EntityChildParticle = LD25.EntityParticle.extend
    #    lifetime: 10.0
    #    fadetime: 0.5

    #    gravityFactor: 0
    #    friction: {x: 40, y: 40}

    #    bounciness: Math.random() * 0.25 + 0.25

    #    animSheet: new ig.AnimationSheet('media/particle.png',1,1)

    #    init: (x, y, settings) ->
    #        @addAnim('idle', 1.0, [[0,1,2,3,4,5,6,7,8,9].random()])
    #        @currentAnim.gotoRandomFrame()
    #        @vel.y = 50 + Math.random()*50

    #        @parent(x, y, settings)

    #    update: ->
    #        @accel.y = 200
    #        @parent()



    #LD25.EntityPlayer = ig.Entity.extend
    #    name: 'player'
    #    
    #    size: { x:6, y:8 }
    #    offset: { x:1, y:0 }
    #    friction: {x: 80, y: 80}
    #    collides: ig.Entity.COLLIDES.PASSIVE

    #    animSheet: new ig.AnimationSheet('media/player.png', 8, 8)

    #    type: ig.Entity.TYPE.A

    #    flip: false
    #    maxVel: {x: 70, y: 70}

    #    init: (x, y, settings) ->
    #        @addAnim('idle', 0.1, [1,0,1,2,1])
    #        @addAnim('walking', 0.1, [3,4,5,4])
    #        @addAnim('flying', 0.2, [6,7])

    #        @parent(x, y, settings)

    #    draw: ->
    #        @parent()

    #    update: ->
    #        @accel.y = 70
    #        if ig.input.state('left') == ig.input.state('right')
    #            @currentAnim = @anims.idle
    #            @anims.walking.rewind()
    #        else
    #            if ig.input.state('left')
    #                @accel.x = -70
    #                @currentAnim = @anims.walking
    #                @flip = true
    #            else if ig.input.state('right')
    #                @accel.x = 70
    #                @currentAnim = @anims.walking
    #                @flip = false

    #        if not ig.input.state('left') and not ig.input.state('right')
    #            @accel.x = 0


    #        if ig.input.state('up')
    #            @accel.y = -80
    #            @currentAnim = @anims.flying
    #            particle = ig.game.spawnEntity(NS.EntityRainbowParticle, @pos.x + 3, @pos.y + 4)
    #            particle.vel.x = -@vel.x * Math.random()
    #            if Math.random() < 0.04
    #                particle = ig.game.spawnEntity(NS.EntityBigPoop, @pos.x + 3, @pos.y + 4)
    #                particle.vel.x = @vel.x * -2 * Math.random()
    #        
    #        @currentAnim.flip.x = @flip


    LD25.LD25Game = ig.Game.extend
        
        font: new ig.Font('media/04b03.font.png')
        clearColor: '#7fffff'
        gravity: 20
        
        init: ->
            ig.input.bind(ig.KEY.LEFT_ARROW, 'left')
            ig.input.bind(ig.KEY.RIGHT_ARROW, 'right')
            ig.input.bind(ig.KEY.UP_ARROW, 'up')
            ig.input.bind(ig.KEY.DOWN_ARROW, 'down')
            ig.input.bind(ig.KEY.SPACE, 'jump')

            #map = [
            #    [2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]
            #    [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]
            #    [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]
            #    [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]
            #    [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]
            #    [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]
            #    [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]
            #    [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]
            #    [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]
            #    [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]
            #    [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]
            #    [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]
            #    [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]
            #    [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]
            #    [2,1,1,1,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,1,1,1,2]
            #    [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]
            #    [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]
            #    [2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]
            #    [3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3]
            #    [4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4]
            #    [4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4]
            #]
            #@backgroundMaps.push(new ig.BackgroundMap(8, map, 'media/tiles.png'))
            #colmap = [
            #    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
            #    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]
            #    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]
            #    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]
            #    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]
            #    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]
            #    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]
            #    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]
            #    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]
            #    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]
            #    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]
            #    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]
            #    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]
            #    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]
            #    [1,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,1]
            #    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]
            #    [1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]
            #    [1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]
            #    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
            #    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
            #    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
            #]
            #@collisionMap = new ig.CollisionMap(8, colmap, {})

            #@player = ig.game.spawnEntity(NS.EntityPlayer, 102, 100)
            #LD25.sounds['sound'].play()
            
        
        update: ->
            @parent()

            
            ## screen follows the player
            #if @player
            #    @screen.x = @player.pos.x - ig.system.width/2
            #    @screen.y = @player.pos.y - ig.system.height/2
        
        draw: ->
            @parent()

            @font.draw("Debug message", 10, 10)

    soundManager.setup {
        url: 'lib/soundmanager/swf/'
        onready: ->
            LD25.sounds =
                'sound': soundManager.createSound { id: 'sound', url: 'media/sound.wav' }

            ig.main('#canvas', LD25.LD25Game, 60, 256, 240, 2)
        ontimeout: ->
            alert('Could not start Soundmanager.  Is Flash blocked?')
    }
