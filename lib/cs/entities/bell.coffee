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

        ringTimer: new ig.Timer()
        timesRung: 0
        ringing: false

        init: (x, y, settings) ->
            @addAnim('idle', 0.2, [0])
            @addAnim('ringing', 0.2, [0,1,0,2])

            @parent(x, y, settings)
            @ringTimer.reset()

        ring: ->
            window.soundManager.play('bell')
            @ringTimer.reset()
            @ringing = true
            @currentAnim = @anims.ringing
            @timesRung += 1

        update: ->
            if @ringing
                if @ringTimer.delta() > 1
                    window.soundManager.play('bell')
                    @ringTimer.reset()
                    @timesRung += 1
                    if @timesRung >= 3
                        @ringing = false
                        @timesRung = 0
            else
                if @ringTimer.delta() > 1
                    @currentAnim = @anims.idle
                    @ringTimer.reset()

            @parent()




