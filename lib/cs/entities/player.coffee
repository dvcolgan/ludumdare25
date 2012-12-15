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

        init: (x, y, settings) ->
            @addAnim('idle', 0.2, [0,0,0,0,1,0,1,0,0,0,0,0,0,0,2,0,2,0])
            @addAnim('running', 0.1, [3,4,5,6,5,4])
            @addAnim('jumping', 0.2, [7])
            @addAnim('falling', 0.2, [8])
            @addAnim('armjump', 0.05, [8,9,10,9,7], true)
            @addAnim('rolling', 0.1, [11,12,13,14,15,16])
            @addAnim('panting', 0.3, [0,17,0,17,0,17,0,17,0,0,0,0], true)

            @parent(x, y, settings)

        check: (entity) ->
            if entity.name == 'bell'
                entity.ring()
                @state = 'panting'
                @anims.panting.rewind()
                @currentAnim = @anims.panting

        draw: ->
            @parent()

        handleMovementTrace: (res) ->

            if res.tile.x != 0 and @vel.x != 0 and @wallJumpXVel == 0
                @wallJumpXVel = @vel.x

            @parent(res)


            if res.tile.x == -1
                @touchingWall = 'left'
            else if res.tile.x == 1
                @touchingWall = 'right'
            else
                @touchingWall = 'none'




        update: ->

            # first determine state and animation, then determine movement
            # states:
            #   idle
            #   running
            #   jumping
            #   falling
            #   armhop
            #   rolling

            if @state == 'idle' # on the ground, not moving
                if @standing and ig.input.state('jump')
                    @state = 'jumping'
                    @anims.jumping.rewind()
                    @currentAnim = @anims.jumping
                    @vel.y -= @jumpAccel

                else if ig.input.state('left') or ig.input.state('right')
                    @state = 'running'
                    @anims.running.rewind()
                    @currentAnim = @anims.running


            else if @state == 'running'
                @currentAnim.frameTime = 0.3 - Math.abs(@vel.x / @maxVel.x) * 0.18
                if ig.input.state('down')
                    @state = 'rolling'
                    @anims.rolling.rewind()
                    @currentAnim = @anims.rolling

                else if ig.input.state('jump')
                    @state = 'jumping'
                    @anims.jumping.rewind()
                    @currentAnim = @anims.jumping
                    @vel.y -= @jumpAccel

                else if ig.input.state('left') or ig.input.state('right')
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
                    if @vel.x == 0
                        @state = 'idle'
                        @anims.idle.rewind()
                        @currentAnim = @anims.idle


            else if @state == 'jumping'
                if @vel.y > 0
                    @state = 'falling'
                    @anims.falling.rewind()
                    @currentAnim = @anims.falling

                else if not ig.input.state('jump')
                    @vel.y *= 0.7

                if ig.input.pressed('jump') and (@touchingWall == 'left' and ig.input.state('left')) or (@touchingWall == 'right' and ig.input.state('right'))
                    @vel.y -= Math.abs(@wallJumpXVel)
                    @anims.jumping.rewind()

                if ig.input.state('left') and not ig.input.state('right')
                    # allow for some amount of air strafe
                    @accel.x -= @runAccel * 0.1
                else if ig.input.state('right') and not ig.input.state('left')
                    @accel.x += @runAccel * 0.1


            else if @state == 'falling'
                if ig.input.pressed('jump') and (@touchingWall == 'left' and ig.input.state('left')) or (@touchingWall == 'right' and ig.input.state('right'))
                    @vel.y -= Math.abs(@wallJumpXVel)
                    @state = 'jumping'
                    @anims.jumping.rewind()
                    @currentAnim = @anims.jumping

                if ig.input.state('down')
                    @state = 'rolling'
                    @anims.rolling.rewind()
                    @currentAnim = @anims.rolling
                else if ig.input.state('up') and @vel.x != 0
                    @state = 'armjump'
                    @anims.armjump.rewind()
                    @currentAnim = @anims.armjump
                else if @standing
                    if @vel.x = 0
                        @state = 'idle'
                        @anims.idle.rewind()
                        @currentAnim = @anims.idle
                    else
                        @state = 'running'
                        @anims.running.rewind()
                        @currentAnim = @anims.running

            else if @state == 'armjump'
                if ig.input.state('up') and @currentAnim.frame == 2
                    @currentAnim.pause()
                else
                    @currentAnim.unpause()
                if @currentAnim.frame == 2
                    @size = { x:10, y:12 }
                    @offset = { x:2, y:4 }
                else
                    @size = { x:10, y:28 }
                    @offset = { x:2, y:4 }

                if ig.input.state('left') and not ig.input.state('right')
                    # allow for some amount of air strafe
                    @accel.x -= @runAccel * 0.1
                else if ig.input.state('right') and not ig.input.state('left')
                    @accel.x += @runAccel * 0.1
                if not ig.input.state('up') and @currentAnim.frame >= 4
                    if @vel.y > 0
                        @state = 'falling'
                        @anims.falling.rewind()
                        @currentAnim = @anims.falling
                    else if @vel.y < 0
                        @state = 'jumping'
                        @anims.jumping.rewind()
                        @currentAnim = @anims.jumping
                        
                else
                    if @currentAnim.frame > 0 and @standing
                        @vel.y -= @jumpAccel / 2

            else if @state == 'rolling'
                if not @standing
                    if ig.input.state('down')
                        @currentAnim.gotoFrame(0)
                        @currentAnim.pause()
                    else
                        @state = 'falling'
                        @anims.falling.rewind()
                        @currentAnim = @anims.falling

                else
                    @currentAnim.unpause()

                    if ig.input.state('down') and @currentAnim.frame == @currentAnim.numFrames() - 1
                        @currentAnim.gotoFrame(2)
                    else if @currentAnim.frame == @currentAnim.numFrames() - 1
                        if @standing
                            @state = 'running'
                            @anims.running.rewind()
                            @currentAnim = @anims.running
                        else
                            @state = 'falling'
                            @anims.falling.rewind()
                            @currentAnim = @anims.falling

            else if @state == 'panting'
                @accel.x = @vel.x = 0
                if @currentAnim.loopCount > 0
                    @state = 'idle'
                    @anims.idle.rewind()
                    @currentAnim = @anims.idle
                    ig.game.nextLevel()
                    


                    

            if @standing
                @friction.x = 400
            else
                @friction.x = 50

            if @vel.x > 0
                @flip = false
            if @vel.x < 0
                @flip = true

            @currentAnim.flip.x = @flip

            if @pos.x < 0
                @pos.x = 0
                @accel.x = @vel.x = 0

            if @standing or ig.input.pressed('jump')
                @wallJumpXVel = 0



            @parent()



