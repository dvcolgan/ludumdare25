ig.module(
	'game.entities.player'
)
.requires(
	'impact.entity'
)
.defines ->

    window.EntityPlayer = ig.Entity.extend

        name: 'player'
        state: 'idle'
        
        size: { x:10, y:28 }
        offset: { x:2, y:4 }
        friction: {x: 400, y: 0}
        collides: ig.Entity.COLLIDES.PASSIVE

        animSheet: new ig.AnimationSheet('media/player/player.png', 16, 32)

        checkAgainst: ig.Entity.TYPE.B

        flip: false
        maxVel: {x: 200, y: 600}
        runAccel: 300
        jumpAccel: 250
        touchingWall: 'none'
        resurrectCount: 0
        yDeathThreshold: 350

        init: (x, y, settings) ->
            @addAnim('idle', 0.2, [0,0,0,0,1,0,1,0,0,0,0,0,0,0,2,0,2,0])
            @addAnim('running', 0.1, [3,4,5,6,5,4])
            @addAnim('jumping', 0.2, [7])
            @addAnim('falling', 0.2, [8])
            @addAnim('armjump', 0.05, [8,9,10,9,7], true)
            @addAnim('rolling', 0.1, [11,12,13,14,15,16])
            @addAnim('panting', 0.3, [0,17,0,17,0,17,0,17,0,0,0,0], true)
            @addAnim('dead', 0.1, [18,19,19,19,19,19,19,19,19,19,19,20,19,19,19,19,19,19,19,20,19,19,19])
            @addAnim('resurrecting', 0.3, [17,17,17,17,17,0])
            @addAnim('walljumping', 0.2, [21,22], true)

            @parent(x, y, settings)

        check: (entity) ->
            if entity.name == 'bell'
                entity.ring()
                @stateChange('panting')


        updateAirStrafing: ->
            if ig.input.state('left') and not ig.input.state('right')
                if @vel.x > 0
                    @vel.x -= 20
                else
                    @vel.x -= 10
            else if ig.input.state('right') and not ig.input.state('left')
                if @vel.x < 0
                    @vel.x += 20
                else
                    @vel.x += 10


        draw: ->
            @parent()
            if @state == 'dead' and ig.input.pressed('jump')
                x = Math.floor(Math.random() * (ig.system.width - 80 - 80 + 1)) + 80
                y = Math.floor(Math.random() * (ig.system.width - 80 - 80 + 1)) + 80
                ig.game.spawnEntity(window.EntityInsult, x, y)
                @resurrectCount += 1


        spawnDeathParticles: ->
            for i in [0..10]
                ig.game.spawnEntity(window.EntityDeathParticle, @pos.x + @size.x / 2, @pos.y + @size.y)


        spawnDustParticles: ->
            for i in [0..2]
                ig.game.spawnEntity(window.EntityDustParticle, @pos.x + @size.x / 2, @pos.y + @size.y)


        handleMovementTrace: (res) ->

            if res.collision.y and @vel.y > @yDeathThreshold and @state != 'rolling'
                window.soundManager.stop('falling-from-sky')
                window.soundManager.play('dead')
                @stateChange('dead')
                @resurrectCount = 0
                @spawnDeathParticles()

            if res.collision.x
                if Math.abs(@vel.x) > Math.abs(@wallJumpXVel)
                    @wallJumpXVel = @vel.x

            @parent(res)



        stateChange: (state) ->
            @state = state
            @anims[state].rewind()
            @currentAnim = @anims[state]
            @currentAnim.flip.x = @flip


        update: ->
            # first pass change states if needed

            if @state == 'idle'
                if ig.input.pressed('jump')
                    @stateChange('jumping')
                else if ig.input.state('left') or ig.input.state('right')
                    @stateChange('running')


            else if @state == 'running'
                if ig.input.pressed('jump')
                    @stateChange('jumping')
                else if ig.input.pressed('down')
                    @stateChange('rolling')
                else if @vel.y > 0
                    @stateChange('falling')
                else if @vel.y < 0 # doesn't seem possible but whatever
                    @stateChange('jumping')
                else if @vel.x == 0 and not @huggingWall
                    @stateChange('idle')


            else if @state == 'jumping'
                if @huggingWall and ig.input.pressed('jump')
                    @stateChange('walljumping')
                else if @standing and @vel.x == 0
                    @stateChange('idle')
                else if ig.input.pressed('down')
                    @stateChange('rolling')
                else if @standing and @vel.y == 0 # I guess if you landed on a platform perfectly after a jump?
                    @stateChange('running')
                else if @vel.y > 0
                    @stateChange('falling')


            else if @state == 'walljumping'
                if @standing
                    if @vel.x == 0
                        @stateChange('idle')
                    else
                        @stateChange('running')
                if @vel.x != 0
                    if @standing
                        @stateChange('running')
                    else
                        if @vel.y < 0
                            @stateChange('jumping')
                        else
                            @stateChange('falling')
                else if not ig.input.state('jump')
                    if @standing
                        @stateChange('idle')
                    else
                        if @vel.y < 0
                            @stateChange('jumping')
                        else
                            @stateChange('falling')


            else if @state == 'falling'
                if @huggingWall and ig.input.pressed('jump')
                    @stateChange('walljumping')
                else if ig.input.pressed('down')
                    @stateChange('rolling')
                else if @vel.y < 0
                    @stateChange('jumping')
                else if @standing
                    if @vel.x == 0
                        @stateChange('idle')
                    else
                        @stateChange('running')


            else if @state == 'rolling'
                if not @standing
                    if not ig.input.state('down')
                        @stateChange('falling')
                else if @currentAnim.loopCount > 0
                    if @standing
                        @stateChange('running')
                    else
                        @stateChange('falling')



            else if @state == 'dead'
                if @resurrectCount >= 7
                    @stateChange('resurrecting')

            else if @state == 'resurrecting'
                if @currentAnim.loopCount > 0
                    @stateChange('idle')

            else if @state == 'panting'
                if @currentAnim.loopCount > 0
                    @stateChange('idle')
                    ig.game.nextLevel()
                    

            # Canned for later
            #else if @state == 'armjump'
            #    if ig.input.state('up') and @currentAnim.frame == 2
            #        @currentAnim.pause()
            #    else
            #        @currentAnim.unpause()
            #    if @currentAnim.frame == 2
            #        @size = { x:10, y:12 }
            #        @offset = { x:2, y:4 }
            #    else
            #        @size = { x:10, y:28 }
            #        @offset = { x:2, y:4 }

            #    if ig.input.state('left') and not ig.input.state('right')
            #        # allow for some amount of air strafe
            #        @accel.x -= @runAccel * 0.1
            #    else if ig.input.state('right') and not ig.input.state('left')
            #        @accel.x += @runAccel * 0.1
            #    if not ig.input.state('up') and @currentAnim.frame >= 4
            #        if @vel.y > 0
            #            @stateChange('falling')
            #        else if @vel.y < 0
            #            @stateChange('jumping')
            #            
            #    else
            #        if @currentAnim.frame > 0 and @standing
            #            @vel.y -= @jumpAccel / 2


            # second pass do actions of each state

            if @state == 'idle'
                @accel.x = @vel.x = @accel.y = @vel.y = 0
            else if @state == 'running'
                @spawnDustParticles()
                if ig.input.state('left') or ig.input.state('right')
                    if ig.input.state('left') and not ig.input.state('right')
                        if @vel.x > 0 # if you are skidding, help make it faster
                            @vel.x *= 0.7
                        @accel.x = -@runAccel
                    else if ig.input.state('right') and not ig.input.state('left')
                        if @vel.x < 0 # if you are skidding, help make it faster
                            @vel.x *= 0.7
                        @accel.x = @runAccel
                    else
                        @accel.x = 0
                else
                    @accel.x = 0
                @currentAnim.frameTime = 0.3 - (Math.abs(@vel.x) / @maxVel.x) * 0.18


            else if @state == 'jumping'
                if @standing and ig.input.pressed('jump')
                    window.soundManager.play('jump')
                    @vel.y -= @jumpAccel
                else if not ig.input.state('jump') and @vel.y < 0
                    @vel.y *= 0.7
                @updateAirStrafing()


            else if @state == 'falling'
                @updateAirStrafing()

            else if @state == 'walljumping'
                if ig.input.pressed('jump')
                    @vel.y -= Math.abs(@wallJumpXVel)



            else if @state == 'rolling'
                if not @standing and ig.input.state('down')
                    @currentAnim.rewind()
                    @currentAnim.pause()
                if @standing
                    @currentAnim.unpause()
                    if @currentAnim.frame == 0
                        window.soundManager.play('rolling-ground-hit')
                        @currentAnim.gotoFrame(1)


            else if @state == 'dead'
                if @currentAnim.frame >= @currentAnim.numFrames() - 1
                    @currentAnim.gotoFrame(1)
                @accel.x = @vel.x = 0
            else if @state == 'resurrecting'
            else if @state == 'panting'
                @accel.x = @vel.x = 0
                if @currentAnim.loopCount > 0
                    ig.game.nextLevel()




                    

            if @standing
                @friction.x = 400
            else
                @friction.x = 50


            if @standing
                if @vel.x > 0
                    @flip = false
                if @vel.x < 0
                    @flip = true
                @currentAnim.flip.x = @flip

            if @pos.x < 0
                @pos.x = 0
                @accel.x = @vel.x = 0

            if @standing
                @wallJumpXVel = 0


            if @pos.y > ig.system.height + 200
                @pos.y = -500
                @accel.x = 0
                @vel.x = -200
                @accel.y += 200
                window.soundManager.play('falling-from-sky')
            if @pos.y < -20 or @pos.y > ig.system.height + 20
                @accel.x = 0


            @parent()


    window.EntityParticle = ig.Entity.extend
        size: {x:1, y:1}
        offset: {x:0, y:0}

        type: ig.Entity.TYPE.NONE
        checkAgainst: ig.Entity.TYPE.NONE
        collides: ig.Entity.COLLIDES.LITE

        lifetime: 5
        fadetime: 1
        #minBounceVelocity: 0
        #bounciness: 1.0
        #friction: { x:0, y:0 }
        maxVel: {x: 3000, y: 3000}

        init: (x, y, settings) ->
            @parent(x, y, settings)
            @idleTimer = new ig.Timer()

        update: ->
            if @idleTimer.delta() > @lifetime
                @kill()
                return

            @currentAnim.alpha = @idleTimer.delta().map(@lifetime - @fadetime, @lifetime, 1, 0)
            @parent()


    window.EntityInsult = ig.Entity.extend

        type: ig.Entity.TYPE.NONE
        checkAgainst: ig.Entity.TYPE.NONE
        collides: ig.Entity.COLLIDES.NEVER
        gravityFactor: 0

        lifetime: 1
        fadetime: 1
        insults: [
            'Wake up you!'
            'I know you\'re in there!'
            'Think of how sad everyone\'ll be!'
            'You can\'t quit now!'
            'We just got started!'
            'Everyone\'s counting on you!'
            'I\'m not done with you yet!'
            'What are you doing just laying around?'
            'I don\'t pay you to sleep!'
            'If you don\'t get up, I\'ll tell on you!'
            'My pet hamster is more exciting than you.'
            'Well?  I\'m waiting!'
            'Are you coming?'
            'Sign...'
            'This is why we can\'t have nice things...'
        ]

        init: (x, y, settings) ->
            @parent(x, y, settings)
            @insult = @insults.random()
            @idleTimer = new ig.Timer()
            @vel.x = -10 + Math.random() * 20
            @vel.y = -10 + Math.random() * 20

        draw: ->
            ig.game.font.alpha = @idleTimer.delta().map(@lifetime - @fadetime, @lifetime, 1, 0)
            ig.game.font.draw(@insult, @pos.x, @pos.y, ig.Font.ALIGN.CENTER)
            ig.game.font.alpha = 1
            @parent()


        update: ->
            if @idleTimer.delta() > @lifetime
                @kill()
                return

            @parent()



    window.EntityDustParticle = window.EntityParticle.extend
        lifetime: 1.0
        fadetime: 2.0

        gravityFactor: 0
        friction: {x: 40, y: 40}

        animSheet: new ig.AnimationSheet('media/dust-particles.png',4,4)

        init: (x, y, settings) ->
            @addAnim('idle', 1.0, [[0,1,2,3,4,5,6,7,8,9].random()])
            @currentAnim.gotoRandomFrame()

            @parent(x, y, settings)

        update: ->
            @vel.y = -4
            @parent()

    window.EntityDeathParticle = window.EntityParticle.extend
        lifetime: 10.0
        fadetime: 0.5

        friction: {x: 40, y: 40}

        bounciness: Math.random() * 0.25 + 0.25

        animSheet: new ig.AnimationSheet('media/death-particles.png',2,2)

        init: (x, y, settings) ->
            @addAnim('idle', 1.0, [[0,1,2,3,4,5,6,7,8,9].random()])
            @currentAnim.gotoRandomFrame()
            @vel.y = -100 + Math.random()*50
            @vel.x = -100 + Math.random()*200

            @parent(x, y, settings)

        update: ->
            @parent()





