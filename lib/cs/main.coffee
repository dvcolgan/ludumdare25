ig.module(
	'game.main'
)
.requires(
    'game.entities.player'
	'impact.entity'
	'impact.game'
	'impact.font'
    'game.levels.level1'
)
.defines ->

    window.sounds = {}

    #window.EntityParticle = ig.Entity.extend
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



    #window.EntityChildParticle = window.EntityParticle.extend
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




    window.LD25Game = ig.Game.extend
        
        font: new ig.Font('media/04b03.font.png')
        clearColor: '#7fffff'
        gravity: 20
        
        init: ->
            ig.input.bind(ig.KEY.LEFT_ARROW, 'left')
            ig.input.bind(ig.KEY.RIGHT_ARROW, 'right')
            ig.input.bind(ig.KEY.UP_ARROW, 'up')
            ig.input.bind(ig.KEY.DOWN_ARROW, 'down')
            ig.input.bind(ig.KEY.SPACE, 'jump')
            @loadLevel(LevelLevel1)
            @player = ig.game.getEntityByName('player')
            #window.sounds['sound'].play()
            
        
        update: ->
            @parent()

            
            # screen follows the player
            if @player
                @screen.x = @player.pos.x - ig.system.width/2
                @screen.y = @player.pos.y - ig.system.height/2
                if @screen.x < 0 then @screen.x = 0
                if @screen.y < 0 then @screen.y = 0

                colMap = ig.game.collisionMap
                levelWidth = colMap.width * colMap.tilesize
                levelHeight = colMap.height * colMap.tilesize

                if @screen.x > levelWidth - ig.system.width then @screen.x = levelWidth - ig.system.width
                if @screen.y > levelHeight - ig.system.height  then @screen.y = levelHeight - ig.system.height
        draw: ->
            @parent()

            @font.draw("SUPAR", 10, 10)

    if !ig.global.wm
        soundManager.setup {
            url: 'lib/soundmanager/swf/'
            onready: ->
                window.sounds =
                    'sound': soundManager.createSound { id: 'sound', url: 'media/sound.wav' }

                ig.main('#canvas', window.LD25Game, 60, 256, 240, 2)
            ontimeout: ->
                alert('Could not start Soundmanager.  Is Flash blocked?')
        }
    else
        ig.main('#canvas', window.LD25Game, 60, 256, 240, 2)
